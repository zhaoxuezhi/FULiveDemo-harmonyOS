import {
  FULogger,
  FUNMAIKit,
  FUNMCameraInput,
  FUNMDisplayView,
  FUNMFaceProcessorDetectMode,
  FUNMFileUtil,
  FUNMGlobalContext,
  FUNMImageOrientation,
  FUNMNumberUtil,
  FUNMOutputType,
  FUNMRenderConfig,
  FUNMRenderInput,
  FUNMRenderKit,
  FUNMRenderOutput,
  FU_TRANSFORM_MATRIX,
  NativeImage
} from '@faceunity/renderkit_nama';
import fs from '@ohos.file.fs';
import { VideoPlayer, VideoRecorder, VideoInfo } from '@faceunity/mediakit';
import { RouterParamsModel } from '../../router/RouterModel';
import { AssetsDataInterface, AssetsUtil } from '../../utils/AssetsUtil';
import { FUBackButtonRow } from '../../components/common/FUBackButton';
import { RenderKitService } from '../../service/RenderKitService';
import { ExportVideoView } from '../../components/media/ExportVideoView';
import { promptAction, window } from '@kit.ArkUI';
import { ImageRenderType } from '../../constants/Constants';
import { NodeControllerService } from '../../service/NodeControllerService';
import { SaveScreenshotCallBack } from '../../utils/CallBack';
import { fileIo } from '@kit.CoreFileKit';
import { VideoRenderViewModel, VideoRenderXcomponentIdG } from '../../viewModels/video/VideoRenderViewModel';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

const TAG: string = '[VideoRenderPage]';

@Builder
export function PageBuilder(name: string, param: Object) {
  VideoRenderPage({ routerParams: param })
}

@Component
export struct VideoRenderPage {
  routerParams: RouterParamsModel | undefined = undefined;
  renderType: ImageRenderType = ImageRenderType.Beauty;
  @State showExportView: boolean = false;
  @Provide progressValue: number = 0;
  @State private showPlayButton: boolean = true;
  private pageInfos: NavPathStack = new NavPathStack();
  private assetData: AssetsDataInterface | undefined = undefined;
  private viewModel: VideoRenderViewModel | undefined = new VideoRenderViewModel();
  private controller: XComponentController | undefined = undefined;
  private nativeImage: NativeImage | undefined = undefined;
  private input: FUNMRenderInput | undefined = undefined;
  private inputFile: fileIo.File | undefined = undefined;
  private inputFileSize: number = 0;
  private recordFile: fileIo.File | undefined = undefined;
  private renderBuffer: ArrayBuffer | undefined = undefined;
  private videoInfo: VideoInfo | undefined = undefined;
  private player: VideoPlayer | undefined = undefined;
  private recorder: VideoRecorder | undefined = undefined;
  private isPlaying = false;
  private isRecording = false;
  frameCallBack = (frameTime: number, duration: number, requireRGBABuffer: ArrayBuffer | undefined) => {
    const result = (frameTime / duration) * 100;
    const progress = FUNMNumberUtil.formatNumber(result, 0, true);
    this.progressValue = Number(progress);
    this.progressValue++;

    if (this.input) {
      FUNMRenderKit.renderWithInput(this.input).then((output: FUNMRenderOutput) => {
        if (this.isRecording) {
          this.renderBuffer = output.pixelBuffer;
          if (this.renderBuffer) {
            this.recorder?.pushBuffer(this.renderBuffer, this.renderBuffer.byteLength);
          }
        }
      }).catch((error: Error) => {
        FULogger.error(TAG, `renderWithInput error ${error.name} ${error.message}`);
      });
    }
  }
  finishCallBack = () => {
    const asyncBlock = async () => {
      if (this.isRecording) {
        this.stopRecord();
        await this.saveVideoToPhotoAlbum();
        this.isRecording = false;
      }

      this.isPlaying = false;
      this.previewing();
    }

    this.progressValue = 100;
    setTimeout(async () => {
      await asyncBlock();
    }, 100)
  }

  async aboutToAppear() {
    this.renderType = Object(this.routerParams?.params)?.renderType;
    this.assetData = Object(this.routerParams?.params)?.assetData as AssetsDataInterface;

    // ================ NodeController 设置 ================
    switch (this.renderType) {
      case ImageRenderType.Beauty: {
        NodeControllerService.sharedInstance()
          .updateBeautyViewNodeController(false, new SaveScreenshotCallBack(() => {
            this.prepareStartRecord();
          }));
      }
        break;
      case ImageRenderType.Sticker:
        NodeControllerService.sharedInstance()
          .updateStickerViewNodeController(false, new SaveScreenshotCallBack(() => {
            this.prepareStartRecord();
            // TODO: 待完善
            // this.showExportView = true;
            // setInterval(() => {
            //   this.progressValue ++;
            // },33);
          }));
        break;
      case ImageRenderType.Makeup: {
        NodeControllerService.sharedInstance().updateMakeupViewNodeController(false, new SaveScreenshotCallBack(() => {
          this.prepareStartRecord();
        }))
        break
      }
    }

    // =======================================================

    const videoUri = this.assetData?.uri;
    if (videoUri === undefined) {
      FULogger.error(TAG, `videoUri is undefined`);
      return;
    }

    const nativeImage = new NativeImage();
    FUNMRenderKit.attachNativeImageToGL(nativeImage);
    this.nativeImage = nativeImage;

    this.inputFile = fileIo.openSync(videoUri, fileIo.OpenMode.READ_ONLY);
    let inputFileState = fileIo.statSync(this.inputFile.fd);
    if (inputFileState.size <= 0) {
      FULogger.error(TAG, 'player inputFile size is 0');
    }
    this.inputFileSize = inputFileState.size;

    this.player =
      new VideoPlayer(this.inputFile.fd, 0, this.inputFileSize, Number(this.nativeImage.GetSurfaceId()), false, this.frameCallBack,
        this.finishCallBack);
    this.videoInfo = this.player.getVideoInfo();

    const asset = await AssetsUtil.getAsset(videoUri);
    const videoSize = this.calculateAppropriateVideoSize();
    let thumbSize: Size = AssetsUtil.compressToTheRightSize({ width: videoSize.width, height: videoSize.height });
    const thumb = await asset?.getThumbnail(thumbSize)
    if (this.viewModel) {
      this.viewModel.thumbnail = thumb;
    }

    if (this.controller) {
      const displayViewSize = this.calculateAppropriateDisplayPageSize();
      this.controller.setXComponentSurfaceRect({ surfaceWidth: displayViewSize.width, surfaceHeight: displayViewSize.height });
    }

    this.setAIOrientationIfNeed(false);
    this.viewModel?.startPreviewing();
  }

  // ================ NodeController 展示 ================
  @Builder
  targetView() {
    if (this.renderType === ImageRenderType.Beauty) {
      NodeContainer(NodeControllerService.sharedInstance().getBeautyViewNodeController())
        .width('100%')
        .height(270)
    } else if (this.renderType === ImageRenderType.Sticker) {
      NodeContainer(NodeControllerService.sharedInstance().getStickerViewNodeController())
        .width('100%')
        .height(180)
    } else if (this.renderType === ImageRenderType.Makeup) {
      NodeContainer(NodeControllerService.sharedInstance().getMakeupViewNodeController())
        .width('100%')
        .height(400)
    }
  }

  // =====================================================

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Blank()
            .width('100%')
            .backgroundColor(Color.Black)
            .height('5%')
          this.relativeLayoutComponents()
          Blank()
            .width('100%')
            .backgroundColor(Color.Black)
            .height('5%')
        }
        .backgroundColor(Color.Black)
        .width('100%')
        .height('100%')

        if (this.showExportView) {
          ExportVideoView({
            clickCancel: () => {
              this.prepareStopRecord();
            }
          })
            .width('100%')
            .height('100%')
        }
      }
    }
    .onShown(() => {
      this.setAIOrientationIfNeed(false);
      this.viewModel?.startPreviewing();
    })
    .onHidden(() => {
      this.showPlayButton = true;
      this.viewModel?.stopPreviewing();

      if (this.isPlaying) {
        this.player?.stop();
      }

      if (this.isRecording) {
        this.prepareStopRecord();
      }
    })
    .onWillDisappear(() => {
      this.viewModel?.destroy();
      this.viewModel = undefined;
      // 恢复默认设置
      RenderKitService.sharedInstance().finalImageOrientation(FUNMImageOrientation.UP);

      if (this.nativeImage) {
        FUNMRenderKit.detachNativeImageFromGL(this.nativeImage);
        this.nativeImage.Release();
        this.nativeImage = undefined;
      }

      if (this.inputFile) {
        fileIo.closeSync(this.inputFile);
        this.inputFile = undefined;
      }

      FUNMRenderKit.clearRenderTasks();
      FUNMRenderKit.releaseGLResource();
    })
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }

  @Builder
  relativeLayoutComponents() {
    RelativeContainer() {
      FUNMDisplayView({
        viewId: VideoRenderXcomponentIdG,
        onLoadCallBack: (controller: XComponentController) => {
          this.controller = controller;
        },
      })
        .width('100%')
        .height('100%')
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .id("__videoImageRenderPageDisplayView__")

      Row() {
        FUBackButtonRow({
          onBackAction: () => {
            this.pageInfos.pop(true);
          }
        })
      }
      .id('__vrFUBackButtonRow__')

      // 加载目标模块主视图
      Row() {
        this.targetView();
      }
      .id('__videoTargetView__')
      .alignRules({
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })

      if (this.showPlayButton) {
        Button() {
          Image($r('app.media.play_icon'))
        }
        .backgroundColor(Color.Transparent)
        .width(85)
        .height(85)
        .alignRules({
          center: { anchor: "__container__", align: VerticalAlign.Center },
          middle: { anchor: "__container__", align: HorizontalAlign.Center }
        })
        .id("__videoPlayButton__")
        .onClick(() => {
          this.playVideo();
        })
      }
    }
    .width('100%')
    .height('90%')
    .backgroundColor(Color.Black)
  }

  private async prepareStartRecord() {
    if (this.isPlaying) {
      this.player?.stop();
      this.isPlaying = false;
    }

    if (this.recordFile === undefined) {
      this.recordFile = FUNMFileUtil.createSafeFileToWrite(this.videoUri());
      if (this.recordFile === undefined) {
        FULogger.error('recordVide create recordFile fail');
        return;
      }
    }

    this.isRecording = true;
    this.showExportView = true;
    this.progressValue = 0;
    const videoSize = this.calculateAppropriateVideoSize();
    if (this.recorder === undefined) {
      if (this.videoInfo === undefined) {
        FULogger.error('videoInfo is undefined, can not init VideoRecorder');
        return;
      }
      this.recorder =
        new VideoRecorder(videoSize.width, videoSize.height, this.videoInfo.duration, this.videoInfo.frameRate, this.videoInfo.bitRate,
          this.videoInfo.isHDRVivid, this.videoInfo.videoCodecMime);
    }
    this.recorder.start(this.recordFile.fd);
    this.playVideo();
  }

  private async prepareStopRecord() {
    this.isRecording = false;
    this.player?.stop();
    this.stopRecord();
    this.previewing();
  }

  private stopRecord() {
    this.recorder?.stop();
    this.renderBuffer = undefined;
    this.closeRecordFile();
    this.showExportView = false;
  }

  private playVideo() {
    this.showPlayButton = false;
    this.viewModel?.stopPreviewing();
    this.isPlaying = true;
    FUNMRenderKit.clearRenderTasks();
    FUNMAIKit.shareKit().faceProcessorDetectMode = FUNMFaceProcessorDetectMode.Video;
    FUNMAIKit.resetTrackedResult();

    if (this.input === undefined) {
      const configT = new FUNMRenderConfig();
      configT.xcomponentId = VideoRenderXcomponentIdG;
      configT.outputType = FUNMOutputType.XCOMPONENT;

      const cInput = new FUNMCameraInput();
      cInput.nativeImage = this.nativeImage;

      const input = new FUNMRenderInput(configT);
      input.cameraInput = cInput;
      input.inputSize = { width: this.videoInfo?.width ?? 0, height: this.videoInfo?.height ?? 0 };
      this.input = input;

      if (this.videoInfo?.rotation === 0) {
        this.input.textureMatrix = FU_TRANSFORM_MATRIX.CCROT0;
      } else if (this.videoInfo?.rotation === 90) {
        this.input.textureMatrix = FU_TRANSFORM_MATRIX.CCROT270;
        this.input.inputSize =
          { width: this.videoInfo?.height ?? 0, height: this.videoInfo?.width ?? 0 };
      } else if (this.videoInfo?.rotation === 180) {
        this.input.textureMatrix = FU_TRANSFORM_MATRIX.CCROT180;
      } else if (this.videoInfo?.rotation === 270) {
        this.input.textureMatrix = FU_TRANSFORM_MATRIX.CCROT90;
        this.input.inputSize =
          { width: this.videoInfo?.height ?? 0, height: this.videoInfo?.width ?? 0 };
      }
      this.input.bufferMatrix = FU_TRANSFORM_MATRIX.CCROT0_FLIPVERTICAL;
    }

    if (this.isRecording) {
      this.input.renderConfig.outputType = FUNMOutputType.NV21_BUFFER;
    } else {
      this.input.renderConfig.outputType = FUNMOutputType.XCOMPONENT;
    }

    this.setAIOrientationIfNeed(true);
    this.player?.start(!this.isRecording);
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

  private previewing() {
    FUNMRenderKit.clearRenderTasks();
    FUNMAIKit.shareKit().faceProcessorDetectMode = FUNMFaceProcessorDetectMode.Image;
    this.setAIOrientationIfNeed(false);
    this.showPlayButton = true;
    this.viewModel?.startPreviewing();
  }

  private calculateAppropriateDisplayPageSize(): Size {
    const videoSize = this.calculateAppropriateVideoSize();
    const hwRatio = videoSize.height / videoSize.width;
    const windowRect = FUNMGlobalContext.getContext().getValue('mainWindowRect') as window.Rect;
    return { width: windowRect.width, height: windowRect.width * hwRatio };
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

  private setAIOrientationIfNeed(isPlaying: boolean) {
    if (this.renderType === ImageRenderType.Sticker) {
      FUNMRenderKit.clearRenderTasks();
      RenderKitService.sharedInstance()
        .finalImageOrientation(isPlaying ? FUNMImageOrientation.Down : FUNMImageOrientation.UP);
    }
  }

  private closeRecordFile() {
    if (this.recordFile) {
      fs.closeSync(this.recordFile.fd);
      this.recordFile = undefined;
    }
  }

  private videoUri(): string {
    return `${FUNMFileUtil.fileDir}/video.mp4`;
  }
}