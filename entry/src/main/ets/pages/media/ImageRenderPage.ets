import {
  FULogger,
  FUNMDisplayView,
  FUNMGlobalContext,
  FUNMImageOrientation,
  FUNMImageUtil,
  FUNMInputBufferFormat,
  FUNMNormalInput,
  FUNMOutputDataType,
  FUNMOutputType,
  FUNMRenderConfig,
  FUNMRenderInput,
  FUNMRenderKit,
  FUNMRenderOutput
} from '@faceunity/renderkit_nama';
import { RouterParamsModel } from '../../router/RouterModel';
import { AssetsDataInterface } from '../../utils/AssetsUtil';
import { FUBackButtonRow } from '../../components/common/FUBackButton';
import { RenderKitService } from '../../service/RenderKitService';
import { promptAction, window } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { ImageRenderType } from '../../constants/Constants';
import { NodeControllerService } from '../../service/NodeControllerService';
import { SaveScreenshotCallBack } from '../../utils/CallBack';

const xcomponentIdG: string = 'ImageRenderPageXcomponentId';

@Builder
export function PageBuilder(name: string, param: Object) {
  ImageRenderPage({ routerParams: param })
}

@Component
export struct ImageRenderPage {
  routerParams: RouterParamsModel | undefined = undefined;
  renderType: ImageRenderType = ImageRenderType.Beauty;
  private pageInfos: NavPathStack = new NavPathStack();
  private input: FUNMRenderInput | undefined = undefined;
  private renderTimer: number | undefined = undefined;
  private assetData: AssetsDataInterface | undefined = undefined;
  private captureImage: boolean = false;

  async aboutToAppear() {
    this.renderType = Object(this.routerParams?.params)?.renderType;
    this.assetData = Object(this.routerParams?.params)?.assetData as AssetsDataInterface;

    // ================ NodeController 设置 ================
    switch (this.renderType) {
      case ImageRenderType.Beauty: {
        NodeControllerService.sharedInstance()
          .updateBeautyViewNodeController(false, new SaveScreenshotCallBack(() => {
            this.captureImage = true;
          }));
      }
        break;
      case ImageRenderType.Sticker:
        NodeControllerService.sharedInstance()
          .updateStickerViewNodeController(false, new SaveScreenshotCallBack(() => {
            this.captureImage = true;
          }));
        break;
      case ImageRenderType.Makeup: {
        NodeControllerService.sharedInstance().updateMakeupViewNodeController(false, new SaveScreenshotCallBack(() => {
          this.captureImage = true;
        }))
        break
      }
    }
    // =====================================================

    const pixelMap = this.assetData.thumbnail;
    if (pixelMap === undefined) {
      return;
    }
    let input_buffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
    pixelMap.readPixelsToBufferSync(input_buffer);
    let info = pixelMap.getImageInfoSync();
    await pixelMap.release();

    const configT = new FUNMRenderConfig();
    configT.xcomponentId = xcomponentIdG;
    configT.outputType = FUNMOutputType.XCOMPONENT;

    const nInput = new FUNMNormalInput();
    nInput.pixelBuffer = input_buffer;
    nInput.pixelFormat = FUNMInputBufferFormat.RGBA_BUFFER;

    const input = new FUNMRenderInput(configT);
    input.normalInput = nInput;
    input.inputSize = { width: info.size.width, height: info.size.height };
    this.input = input;

    // TODO: 待完善
    RenderKitService.sharedInstance().finalImageOrientation(FUNMImageOrientation.UP);

    this.renderTimer = setInterval(async () => {
      if (this.input) {
        if (this.captureImage && this.input.renderConfig.outputType !== FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER) {
          this.input.renderConfig.outputType = FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER;
        }

        FUNMRenderKit.renderWithInput(this.input).then(async (output: FUNMRenderOutput) => {
          if (this.captureImage && output.dataType === FUNMOutputDataType.RGBA_BUFFER && output.pixelBuffer) {
            FULogger.info('YYYY 保存照片调用了');
            this.captureImage = false;
            let pixelMap =
              FUNMImageUtil.getRGBAPixelMapFromPixelBuffer(output.pixelBuffer, image.PixelMapFormat.RGBA_8888,
                { width: output.outputSize.width, height: output.outputSize.height });
            const encodeBuffer = await FUNMImageUtil.encodePixelMapToGetFileBuffer(pixelMap, 'image/jpeg', 98);
            await pixelMap.release();
            await FUNMImageUtil.saveToPhotoAlbum(encodeBuffer);
            promptAction.showToast({ message: '照片保存成功！' });

            if (this.input) {
              this.input.renderConfig.outputType = FUNMOutputType.XCOMPONENT;
            }
          }
        }).catch((Error: Error) => {
          FULogger.error(`保存照片失败了 ${Error.message}`)
        });
      }
    }, 166);
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
    }
    .onHidden(() => {
      if (this.renderTimer != undefined) {
        clearInterval(this.renderTimer)
        this.renderTimer = undefined
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
        viewId: xcomponentIdG,
        resolution: this.calculateAppropriateDisplayPageSize()
      })
        .width('100%')
        .height('100%')
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .id("imageRenderPageDisplayView")

      Row() {
        FUBackButtonRow({
          onBackAction: () => {
            this.pageInfos.pop(true);
          }
        })
      }
      .id('__ir_FUBackButtonRow__')

      // 加载目标模块主视图
      Row() {
        this.targetView();
      }
      .id('__targetView__')
      .alignRules({
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
    }
    .width('100%')
    .height('90%')
    .backgroundColor(Color.Black)
  }

  private calculateAppropriateDisplayPageSize(): Size {
    if (this.assetData?.size === undefined) {
      return { width: 720, height: 1280 };
    }
    const hwRatio = this.assetData?.size.height / this.assetData?.size.width;
    const windowRect = FUNMGlobalContext.getContext().getValue('mainWindowRect') as window.Rect;
    return { width: windowRect.width, height: windowRect.width * hwRatio };
  }
}