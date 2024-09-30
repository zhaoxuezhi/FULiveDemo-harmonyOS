import {
  FUNMRenderKit,
  FUNMSetupConfig,
  FULOGLEVEL,
  FUNMAIKit,
  FUAITYPE,
  FUNMFaceProcessorDetectMode,
  FUNMBeautyPropertyMode,
  FUNMModeKey,
  FUNMBeauty,
  FUNMRenderInput,
  FUNMRenderOutput,
  FUNMFaceProcessorFaceLandmarkQuality,
  FUNMAutoRenderDelegate,
  FUNMFPSDelegate,
  FUNMNumberUtil,
  FUNMOutputType,
  FUNMOutputDataType,
  FUNMImageUtil,
  FULogger,
  FUNMImageOrientation
} from '@faceunity/renderkit_nama'
import { g_auth_package } from '../auth/FUNMAuth'
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';

export const AutoRenderResolution: Size = { width: 1280, height: 720 };

export class RenderKitService implements FUNMAutoRenderDelegate, FUNMFPSDelegate {
  captureImageFromAutoRender: boolean = false;
  private _shouldDoRender: boolean = true;
  private static instance: RenderKitService | undefined = undefined;

  set shouldDoRender(value: boolean) {
    this._shouldDoRender = value;
    FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
  }

  set showFPS(value: boolean) {
    FUNMRenderKit.sharedInstance().fpsDelegate = value ? this : undefined;
  }

  set xcomponentId(value: string) {
    FUNMRenderKit.sharedInstance().xcomponentId = value;
  }

  static sharedInstance(): RenderKitService {
    if (!RenderKitService.instance) {
      RenderKitService.instance = new RenderKitService();
    }
    return RenderKitService.instance;
  }

  private constructor() {
  }

  didAutoRender(renderOutput: FUNMRenderOutput) {
    this.captureImageFromAutoRenderHandle(renderOutput);
  }

  shouldDoAutoRender(): boolean {
    return this._shouldDoRender;
  }

  renderFPSInfo(fps: number, renderTime: number) {
    AppStorage.set('FPSValue', FUNMNumberUtil.formatNumber(fps, 0, true));
    AppStorage.set('renderTime', FUNMNumberUtil.formatNumber(renderTime, 0, true));
  }

  // 初始化 RenderKit
  initRenderKit() {
    let byte = new Uint8Array(g_auth_package)
    const config = new FUNMSetupConfig(byte.buffer as ArrayBuffer, byte.length);
    FUNMRenderKit.setup(config);
    FUNMRenderKit.setLogLevel(FULOGLEVEL.FU_LOG_LEVEL_INFO);
    FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera = true;
    FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = AutoRenderResolution;
    FUNMRenderKit.sharedInstance().autoRenderConfig.fps = 30;
    FUNMRenderKit.sharedInstance().renderDelegate = this;

    // 创建滤镜道具(AR面具)
    // const filter = new FUNMItem({rawfilePath:'filter.bundle'});
    // FUNMRenderKit.sharedInstance().comicFilter = filter;
  }

  // 初始化AIKit
   initAIKit() {
    FUNMAIKit.loadAIModeWithAIType(FUAITYPE.FUAITYPE_FACEPROCESSOR, { rawfilePath: 'ai_face_processor.bundle' });
    FUNMAIKit.shareKit().maxTrackFaces = 2;
    FUNMAIKit.shareKit().faceProcessorDetectMode = FUNMFaceProcessorDetectMode.Video;
    FUNMAIKit.shareKit().faceProcessorFaceLandmarkQuality = FUNMFaceProcessorFaceLandmarkQuality.High;
  }

  loadBeauty() {
    if (!FUNMRenderKit.sharedInstance().beauty) {
      // 创建美颜道具
      const beauty = new FUNMBeauty({ rawfilePath: 'face_beautification.bundle' });
      beauty.heavyBlur = 0;
      // 默认均匀磨皮
      beauty.blurType = 3;
      // 默认精细变形
      beauty.faceShape = 4;

      // TODO: 高性能设备设置去黑眼圈、去法令纹、大眼、嘴型最新效果
      beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode2, FUNMModeKey.RemovePouchStrength);
      beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode2, FUNMModeKey.RemoveNasolabialFoldsStrength);
      beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode3, FUNMModeKey.EyeEnlarging);
      beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode3, FUNMModeKey.IntensityMouth);
      FUNMRenderKit.sharedInstance().beauty = beauty;
    }
  }

  unloadBeauty() {
    FUNMRenderKit.sharedInstance().beauty = undefined;
  }

  async cameraSwitch() {
    const camera = FUNMRenderKit.sharedInstance().camera;
    if (camera) {
      const isFrontCamera = !camera.isFrontCamera;
      FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera = isFrontCamera;
      await FUNMRenderKit.stopAutoRender();
      await FUNMRenderKit.startAutoRender();
      FUNMAIKit.shareKit().isFrontCamera = isFrontCamera;
    }
  }

  async changeCamaraResolution(resolution: Size, displayResolutionHandle:() => void) {
    FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = resolution;
    await FUNMRenderKit.stopAutoRender();
    RenderKitService.sharedInstance().clearXComponent();
    displayResolutionHandle();
    await FUNMRenderKit.startAutoRender();
  }

  clearXComponent() {
    FUNMRenderKit.clearXComponent();
  }

  gravityEnable(gravityEnable: boolean) {
    FUNMAIKit.shareKit().gravityEnable = gravityEnable;
  }

  finalImageOrientation(orientation: FUNMImageOrientation) {
    FUNMAIKit.shareKit().finalImageOrientation = orientation;
  }

  async startRenderWithDefaultSetting() {
    // 强制为前置
    FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera = true;
    // 强制为预置分辨率
    FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = AutoRenderResolution;
    AppStorage.set('resolution', '720×1280')
    await FUNMRenderKit.startAutoRender();
  }

  async startRender() {
    await FUNMRenderKit.startAutoRender();
  }

  async stopRender() {
    await FUNMRenderKit.stopAutoRender();
  }

  async destroyRenderKit() {
    await FUNMRenderKit.destroy();
  }

  private async captureImageFromAutoRenderHandle(renderOutput: FUNMRenderOutput) {
    const outputType = FUNMRenderKit.sharedInstance().autoRenderConfig.outputType;
    if (this.captureImageFromAutoRender && outputType !== FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER) {
      FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
    }

    if (this.captureImageFromAutoRender && renderOutput.dataType === FUNMOutputDataType.RGBA_BUFFER && renderOutput.pixelBuffer) {
      FULogger.info('YYYY 保存照片调用了');
      this.captureImageFromAutoRender = false;
      let pixelMap = FUNMImageUtil.getRGBAPixelMapFromPixelBuffer(renderOutput.pixelBuffer, image.PixelMapFormat.RGBA_8888,
        { width: renderOutput.outputSize.width, height: renderOutput.outputSize.height });
      const encodeBuffer = await FUNMImageUtil.encodePixelMapToGetFileBuffer(pixelMap, 'image/jpeg', 98);
      await pixelMap.release();
      await FUNMImageUtil.saveToPhotoAlbum(encodeBuffer);
      promptAction.showToast({ message: '照片保存成功！' });

      FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
    }
  }
}