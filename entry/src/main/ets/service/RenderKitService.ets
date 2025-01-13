import {
  FUAIFACEALGORITHMCONFIG,
  FUAITYPE,
  FULogger,
  FULOGLEVEL,
  FUNMAIKit,
  FUNMAutoRenderDelegate,
  FUNMBeauty,
  FUNMBeautyPropertyMode,
  FUNMFaceProcessorDetectMode,
  FUNMFaceProcessorFaceLandmarkQuality,
  FUNMFileUtil,
  FUNMFPSDelegate,
  FUNMImageOrientation,
  FUNMImageUtil,
  FUNMModeKey,
  FUNMNumberUtil,
  FUNMOutputDataType,
  FUNMOutputType,
  FUNMRenderKit,
  FUNMRenderOutput,
  FUNMSetupConfig
} from '@faceunity/renderkit_nama';
import fs from '@ohos.file.fs';
import { VideoRecorder } from '@faceunity/mediakit';
import { g_auth_package } from '../auth/FUNMAuth';
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';

export const AutoRenderResolution: Size = { width: 1280, height: 720 };

const TAG: string = '[RenderKitService]';

export class RenderKitService implements FUNMAutoRenderDelegate, FUNMFPSDelegate {
  private static instance: RenderKitService | undefined = undefined;
  captureImageFromAutoRender: boolean = false;
  stopRecordVideoFromAutoRender: boolean = false;
  private _startRecordVideoFromAutoRender: boolean = false;
  private _shouldDoRender: boolean = true;
  private _recordFile: fileIo.File | undefined = undefined;
  private _recorder: VideoRecorder | undefined = undefined;
  private _videoFrameCount = 0;

  private constructor() {
  }

  set startRecordVideoFromAutoRender(value: boolean) {
    const creatFile = async () => {
      if (this._recordFile === undefined) {
        this._recordFile = FUNMFileUtil.createSafeFileToWrite(this.videoUri());
        if (this._recordFile === undefined) {
          FULogger.error('RenderKitService create _recordFile fail');
          return;
        }
        const camaraResolution = FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution;
        this._recorder = new VideoRecorder(camaraResolution.height, camaraResolution.width, 10000000, 30, 20971520, 0, 'video/avc');
        this._recorder.start(this._recordFile.fd);
        this._startRecordVideoFromAutoRender = true;
      }
    }

    if (value) {
      creatFile();
    } else {
      this._startRecordVideoFromAutoRender = false;
    }
  }

  get startRecordVideoFromAutoRender() {
    return this._startRecordVideoFromAutoRender;
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

  shouldDoRender(value: boolean, autoRender: boolean) {
    this._shouldDoRender = value;
    if (autoRender) {
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
    }
  }

  didAutoRender(renderOutput: FUNMRenderOutput) {
    this.captureImageFromAutoRenderHandle(renderOutput);
  }

  shouldDoAutoRender(): boolean {
    return this._shouldDoRender;
  }

  autoRenderFPSInfo(fps: number, renderTime: number) {
    AppStorage.set('FPSValue', FUNMNumberUtil.formatNumber(fps, 0, true));
    AppStorage.set('renderTime', FUNMNumberUtil.formatNumber(renderTime, 0, true));
  }

  // 初始化 RenderKit
  initRenderKit() {
    let byte = new Uint8Array(g_auth_package)
    const config = new FUNMSetupConfig(byte.buffer as ArrayBuffer, byte.length);
    FUNMRenderKit.setup(config);
    FUNMRenderKit.setLogLevel(FULOGLEVEL.FU_LOG_LEVEL_INFO);
    FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT;
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
    // faceAI 配置
    const faceAiConfig: FUAIFACEALGORITHMCONFIG =
      FUAIFACEALGORITHMCONFIG.FUAIFACE_DISABLE_DEL_SPOT | FUAIFACEALGORITHMCONFIG.FUAIFACE_DISABLE_ARMESHV2
    FUNMAIKit.shareKit().setFaceAlgorithmConfig(faceAiConfig)
    FUNMAIKit.loadAIModeWithAIType(FUAITYPE.FUAITYPE_FACEPROCESSOR, { rawfilePath: 'ai_face_processor.bundle' });
    FUNMAIKit.shareKit().maxTrackFaces = 2;
    FUNMAIKit.shareKit().faceProcessorDetectMode = FUNMFaceProcessorDetectMode.Video;
    FUNMAIKit.shareKit().faceProcessorFaceLandmarkQuality = FUNMFaceProcessorFaceLandmarkQuality.High;
    FUNMAIKit.shareKit().faceRaceDetect = true
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

  async changeCamaraResolution(resolution: Size, displayResolutionHandle: () => void) {
    FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = resolution;
    await FUNMRenderKit.stopAutoRender();
    RenderKitService.sharedInstance().clearXComponent();
    displayResolutionHandle();
    FUNMRenderKit.prepareChangeCamaraResolution();
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
    FUNMAIKit.shareKit().isFrontCamera = true;
    // 强制为前置
    FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera = true;
    // 强制为预置分辨率
    FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = AutoRenderResolution;
    FUNMRenderKit.prepareChangeCamaraResolution();
    AppStorage.set('resolution', '720×1280')
    const res = await FUNMRenderKit.startAutoRender();
    FULogger.info(TAG, `startAutoRender result：${res}`);
  }

  async startRender() {
    const res = await FUNMRenderKit.startAutoRender();
    FULogger.info(TAG, `startAutoRender result：${res}`);
  }

  async stopRender() {
    await FUNMRenderKit.stopAutoRender();
  }

  async destroyRenderKit() {
    await FUNMRenderKit.destroy();
  }

  async destroyRenderCamera() {
    await FUNMRenderKit.destroyAutoRenderCamera();
  }

  releaseGLResource() {
    FUNMRenderKit.releaseGLResource();
  }

  private async captureImageFromAutoRenderHandle(renderOutput: FUNMRenderOutput) {
    const outputType = FUNMRenderKit.sharedInstance().autoRenderConfig.outputType;
    if ((this.captureImageFromAutoRender || this.startRecordVideoFromAutoRender) &&
      outputType !== FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER) {
      FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT_WITH_NV21_BUFFER;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
    }

    if (this.captureImageFromAutoRender && renderOutput.dataType === FUNMOutputDataType.NV21_BUFFER &&
    renderOutput.pixelBuffer) {
      this.captureImageFromAutoRender = false;
      let pixelMap =
        FUNMImageUtil.getRGBAPixelMapFromPixelBuffer(renderOutput.pixelBuffer, image.PixelMapFormat.NV21,
          { width: renderOutput.outputSize.width, height: renderOutput.outputSize.height });
      const encodeBuffer = await FUNMImageUtil.encodePixelMapToGetFileBuffer(pixelMap, 'image/jpeg', 98);
      await pixelMap.release();
      await FUNMImageUtil.saveToPhotoAlbum(encodeBuffer);
      promptAction.showToast({ message: '照片保存成功！' });

      FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
    } else if (this.startRecordVideoFromAutoRender && renderOutput.dataType === FUNMOutputDataType.NV21_BUFFER &&
    renderOutput.pixelBuffer) {
      if (this.stopRecordVideoFromAutoRender) {
        this.stopRecordVideoFromAutoRender = false;
        this.startRecordVideoFromAutoRender = false;

        this._recorder?.stop();
        if (this._recordFile) {
          fs.closeSync(this._recordFile.fd);
          this._recordFile = undefined;
        }
        // 保存的视频帧数至少为1再保存到相册
        if (this._videoFrameCount >= 1) {
          await this.saveVideoToPhotoAlbum();
        }

        FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT;
        FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
      } else {
        this._recorder?.pushBuffer(renderOutput.pixelBuffer, renderOutput.pixelBuffer.byteLength);
        this._videoFrameCount++;
      }
    }
  }

  private async saveVideoToPhotoAlbum() {
    let context = getContext();
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
      photoAccessHelper.MediaAssetChangeRequest.createVideoAssetRequest(context, this.videoUri());
    try {
      await phAccessHelper.applyChanges(assetChangeRequest);
      promptAction.showToast({ message: '视频保存成功！' });
    } catch (err) {
      FULogger.error(TAG, 'save video fail', err.name, err.message);
      promptAction.showToast({ message: '视频保存失败！' });
    }
  }

  private videoUri(): string {
    return `${FUNMFileUtil.fileDir}/render.mp4`;
  }
}