import {
  FU_TRANSFORM_MATRIX,
  FULogger,
  FUNMAISegment,
  FUNMColor,
  FUNMFileUtil,
  FUNMImageUtil,
  FUNMRenderKit,
  NamaImage,
  NativeImage,
} from '@faceunity/renderkit_nama';

import { CaptureButton } from '../common/CaptureButton';
import { HorizontalScrollView, HorizontalScrollViewItemInterface } from '../common/HorizontalScrollView';
import { RouterParamsModel } from '../../router/RouterModel';
import { AssetsDataInterface, AssetsUtil } from '../../utils/AssetsUtil';
import { SegmentationController } from '../../viewModels/SegmentationController';
import image from '@ohos.multimedia.image';
import { VideoInfo, VideoPlayer } from '@faceunity/mediakit';
import { fileIo } from '@kit.CoreFileKit';

const TAG: string = '[SegmentationView]';

export interface SegmentationModel {
  name: string,
  isCustom: boolean,
  videoPath: string,
  imagePath: string
}

@Component
export struct SegmentationView {
  controller: SegmentationViewController | undefined = undefined;
  @Consume('pathInfos') pageInfos: NavPathStack
  // 模板选择
  @State @Watch('onPropertyDidChange') selectItemIndex: number = 0
  @Require @Prop @Watch('onPropertyDidChange') showSelectSegmentModeView: boolean = true
  @State items: HorizontalScrollViewItemInterface[] = []
  private player: VideoPlayer | undefined = undefined;
  private inputFile: fileIo.File | undefined = undefined;
  private nativeImage: NativeImage | undefined = undefined;
  private videoInfo: VideoInfo | undefined = undefined;
  private videoImage: NamaImage | undefined = undefined;
  private isPlayVideo: boolean = false;
  private models: SegmentationModel[] = []
  private selectMediaController: SegmentationController = new SegmentationController()
  @Require showToastCb: (toast: string) => void = () => {
  };

  async onPropertyDidChange(properTyName: string) {
    if (properTyName === 'selectItemIndex') {
      this.updateFUItem()
    } else if (properTyName === 'showSelectSegmentModeView') {
      if (this.showSelectSegmentModeView) {
        this.selectItemIndex = 0
      } else {
        const hasCustomItem = await this.hasCustomItem()
        this.selectItemIndex = hasCustomItem ? 3 : 2
      }
    }
  }

  async hasCustomItem(): Promise<boolean> {
    // 校验本地是否有截图
    const thumbImgPath = this.selectMediaController.thumbImgPath()
    const originalImgPath = this.selectMediaController.originalImgPath()
    const videoPath = this.selectMediaController.videoPath()

    const thumbImgExist = await AssetsUtil.checkFileExistsInSandbox(thumbImgPath)
    const originalImgExist = await AssetsUtil.checkFileExistsInSandbox(originalImgPath)
    const videoExist = await AssetsUtil.checkFileExistsInSandbox(videoPath)
    if (thumbImgExist && originalImgExist) {
      return true
    } else if (thumbImgExist && videoExist) {
      return true
    }
    return false
  }

  async reInitItems() {
    // 校验本地是否有截图
    const thumbImgPath = this.selectMediaController.thumbImgPath()
    const originalImgPath = this.selectMediaController.originalImgPath()
    const videoPath = this.selectMediaController.videoPath()

    const thumbImgExist = await AssetsUtil.checkFileExistsInSandbox(thumbImgPath)
    const originalImgExist = await AssetsUtil.checkFileExistsInSandbox(originalImgPath)
    const videoExist = await AssetsUtil.checkFileExistsInSandbox(videoPath)

    let customItem: SegmentationModel | undefined = undefined
    if (thumbImgExist && originalImgExist) {
      // 1. 初始化 SegmentationModel
      customItem = {
        name: `customItem-${Date.now()}`,
        isCustom: true,
        videoPath: '',
        imagePath: originalImgPath,
      }
    } else if (thumbImgExist && videoExist) {
      customItem = {
        name: `customItem-${Date.now()}`,
        isCustom: true,
        videoPath: videoPath,
        imagePath: '',
      }
    }

    const str = FUNMFileUtil.readTextFromRawfile('segmentation/segmentation.json');
    if (str) {
      this.models = JSON.parse(str);
      const tempModels: SegmentationModel[] = JSON.parse(str);
      if (customItem) {
        tempModels.splice(2, 0, customItem)
      }
      this.models = [...tempModels]

      const tempItems = this.models.map((item: SegmentationModel, index: number) => {
        let imageUrl: image.PixelMap | Resource | undefined = undefined
        let sandboxImageUrl: string | undefined = undefined
        if (item.isCustom) {
          sandboxImageUrl = this.selectMediaController.thumbImgPath()
        } else {
          imageUrl = $rawfile(`segmentation/images/${item.name}.png`)
        }
        return {
          id: item.name,
          imageUrl,
          sandboxImageUrl
        } as HorizontalScrollViewItemInterface
      })

      this.items = [...tempItems]
    }
  }

  async aboutToAppear() {
    if (this.controller) {
      this.controller.show = () => {
        if (this.isPlayVideo) {
          this.player?.start(false);
        }
      };
      this.controller.hidden = () => {
        if (this.isPlayVideo) {
          this.player?.stop();
        }
      };
    }
    await this.selectMediaController.loadCacheData()
    await this.reInitItems()
    this.updateFUItem()
  }

  aboutToDisappear(): void {
    if (this.nativeImage) {
      FUNMRenderKit.detachNativeImageFromGL(this.nativeImage);
      this.nativeImage.Release();
      this.nativeImage = undefined;
    }
    this.selectMediaController.destroy()
  }

  build() {
    Column() {
      CaptureButton()
        .size({ width: 70, height: 70 })
        .margin({ bottom: 20 })

      HorizontalScrollView({
        items: this.items,
        selectIndex_from: this.selectItemIndex,
        shouldSelect: (item: HorizontalScrollViewItemInterface, index: number) => {
          const model = this.models[index]
          if (model.name === 'add_item') {
            this.gotoSelectMediaPage()
            return false
          } else {
            return true
          }
        },
        onItemClick: (item: HorizontalScrollViewItemInterface, index: number) => {
          const model = this.models[index]
          if (model.name === 'add_item') {
          } else {
            this.selectItemIndex = index
          }
        }
      })
        .padding({ top: 10 })
        .backgroundColor(Color.Black)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  gotoSelectMediaPage() {
    const routerParams: RouterParamsModel = {
      params: Object({ 'from': 'SegmentationView' })
    }
    this.pageInfos.pushPath({
      name: 'SelectLocalMediaPage', param: routerParams, onPop: (popInfo: PopInfo) => {
        console.info('[SegmentationView] onPop popInfo:', JSON.stringify(popInfo))
        const assetData: AssetsDataInterface = Object(popInfo.result)?.assetData
        if (assetData?.uri) {
          console.info('[SegmentationView] selected asset uri:', assetData.uri)
          this.selectMediaController.setAssetUri(assetData.uri, async () => {
            // 校验本地是否有截图
            const thumbImgPath = this.selectMediaController.thumbImgPath()
            const originalImgPath = this.selectMediaController.originalImgPath()
            const videoPath = this.selectMediaController.videoPath()

            console.info('[SegmentationView] check paths:', {
              thumbImgPath,
              originalImgPath,
              videoPath
            })

            const thumbImgExist = await AssetsUtil.checkFileExistsInSandbox(thumbImgPath)
            const originalImgExist = await AssetsUtil.checkFileExistsInSandbox(originalImgPath)
            const videoExist = await AssetsUtil.checkFileExistsInSandbox(videoPath)

            console.info('[SegmentationView] file exists status:', {
              thumbImgExist,
              originalImgExist,
              videoExist
            })

            if (thumbImgExist && originalImgExist || thumbImgExist && videoExist) {
              console.info('[SegmentationView] reInitItems and update selectItemIndex')
              await this.reInitItems()
              if (this.selectItemIndex !== 2) {
                this.selectItemIndex = 2
              } else {
                this.selectItemIndex = 0
                setTimeout(() => {
                  this.selectItemIndex = 2
                }, 100)
              }
            }
          })
        }
      }
    })
  }

  updateFUItem() {
    if (this.isPlayVideo) {
      this.player?.stop();
      this.stopVideoPlay();
    }

    this.destroyCurrentItemIfNeed();
    const model = this.models[this.selectItemIndex]
    if (model.name === 'reset_item') {
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    } else if (model.name === 'add_item') {
      // 不做处理

    } else if (model.isCustom) {
      const rawfilePath = 'segmentation/bundles/bg_segment.bundle';
      const fuItem = new FUNMAISegment({ rawfilePath: rawfilePath });
      if (model.videoPath) {
        this.customVideoForBackground(model.videoPath, fuItem);
      } else {
        this.customImageForBackground(model.imagePath, fuItem);
      }
      // 不同页面类型设置不同的item
      FUNMRenderKit.sharedInstance().segmentation = fuItem;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    } else {
      const rawfilePath = `segmentation/bundles/${model.name}.bundle`;
      const fuItem = new FUNMAISegment({ rawfilePath: rawfilePath });
      // 不同页面类型设置不同的item
      FUNMRenderKit.sharedInstance().segmentation = fuItem;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
      if (model.name === 'human_outline_740') {
        // 特殊分割道具
        fuItem.lineGap = 2.8;
        fuItem.lineSize = 2.8;
        const color = FUNMColor.make(255 / 255.0, 180 / 255.0, 0.0, 1.0)
        color.ignoreAlpha = true
        fuItem.lineColor = color
      }
    }

    // toast 提示
    if (model.name === 'hez_ztt_fu') {
      this.showToastCb('张嘴试试')
    } else {
      this.showToastCb('')
    }
  }

  private destroyCurrentItemIfNeed() {
    if (FUNMRenderKit.sharedInstance().segmentation) {
      FUNMRenderKit.sharedInstance().segmentation?.destroy();
      FUNMRenderKit.sharedInstance().segmentation = undefined;
    }
  }

  private customVideoForBackground(videoPath: string, segment: FUNMAISegment) {
    if (!this.selectMediaController.assetMataInfo) {
      FULogger.error(TAG, 'customVideoForBackground assetMataInfo is undefined');
      return;
    }

    if (this.nativeImage) {
      FUNMRenderKit.detachNativeImageFromGL(this.nativeImage);
      this.nativeImage.Release();
      this.nativeImage = undefined;
    }
    this.nativeImage = new NativeImage();
    FUNMRenderKit.attachNativeImageToGL(this.nativeImage);

    this.inputFile = fileIo.openSync(videoPath, fileIo.OpenMode.READ_ONLY);
    let inputFileState = fileIo.statSync(this.inputFile.fd);
    if (inputFileState.size <= 0) {
      FULogger.error(TAG, 'player inputFile size is 0');
      return;
    }
    const size = inputFileState.size;

    const frameCallBack = (frameTime: number, duration: number, requireRGBABuffer: ArrayBuffer | undefined) => {
      segment.prepareAddTexture();
      segment.addTexture(this.videoImage!);
    };
    const finishCallBack = () => {
      this.player?.start(false);
    };
    this.player = new VideoPlayer(this.inputFile.fd, 0, size, this.nativeImage.GetSurfaceId(), false, frameCallBack,
      finishCallBack);
    this.videoInfo = this.player.getVideoInfo();
    const videoSize = this.calculateAppropriateVideoSize();
    this.videoImage =
      new NamaImage(videoSize.width, videoSize.height, this.nativeImage!, this.calculateAppropriateMatrix());
    this.player?.start(false);
    this.isPlayVideo = true;
  }

  private stopVideoPlay() {
    this.isPlayVideo = false;
    if (this.inputFile) {
      fileIo.closeSync(this.inputFile);
      this.inputFile = undefined;
    }
  }

  private async customImageForBackground(imagePath: string, segment: FUNMAISegment) {
    if (!this.selectMediaController.assetMataInfo) {
      FULogger.error(TAG, 'customImageForBackground assetMataInfo is undefined');
      return;
    }

    const pixelMap: image.PixelMap = FUNMImageUtil.decodeToGetRGBAPixelMapFromSandBoxFile(imagePath);
    if (pixelMap === undefined) {
      return;
    }
    let pmBuffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
    pixelMap.readPixelsToBufferSync(pmBuffer);
    await pixelMap.release();

    try {
      const width = this.selectMediaController.assetMataInfo?.width;
      const height = this.selectMediaController.assetMataInfo?.height;
      const image = new NamaImage(width, height, pmBuffer, FU_TRANSFORM_MATRIX.DEFAULT);
      segment.prepareAddTexture();
      segment.addTexture(image);
    } catch (err) {
      FULogger.error(TAG, `${JSON.stringify(err)}}`);
    }
  }

  private calculateAppropriateVideoSize(): Size {
    if (this.videoInfo === undefined) {
      FULogger.error(TAG, 'calculateAppropriateVideoSize videoInfo is undefined');
      return { width: 1, height: 1 };
    }

    if (this.videoInfo.rotation === 0 || this.videoInfo.rotation === 180) {
      return { width: this.videoInfo.width, height: this.videoInfo.height };
    } else {
      return { width: this.videoInfo.height, height: this.videoInfo.width };
    }
  }

  private calculateAppropriateMatrix(): FU_TRANSFORM_MATRIX {
    if (this.videoInfo === undefined) {
      FULogger.error(TAG, 'calculateAppropriateVideoSize videoInfo is undefined');
      return FU_TRANSFORM_MATRIX.DEFAULT;
    }

    if (this.videoInfo?.rotation === 0) {
      return FU_TRANSFORM_MATRIX.CCROT0_FLIPVERTICAL;
    } else if (this.videoInfo?.rotation === 90) {
      return FU_TRANSFORM_MATRIX.CCROT270_FLIPVERTICAL;
    } else if (this.videoInfo?.rotation === 180) {
      return FU_TRANSFORM_MATRIX.CCROT180_FLIPVERTICAL;
    } else if (this.videoInfo?.rotation === 270) {
      return FU_TRANSFORM_MATRIX.CCROT90_FLIPVERTICAL;
    } else {
      return FU_TRANSFORM_MATRIX.DEFAULT;
    }
  }
}

export class SegmentationViewController {
  show: (() => void) | undefined = undefined;
  hidden: (() => void) | undefined = undefined;
}