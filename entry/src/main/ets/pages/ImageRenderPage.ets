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
import { RouterParamsModel } from '../router/RouterModel'
import { AssetsDataInterface } from '../utils/AssetsUtil'
import { FUBackButtonRow } from '../components/common/FUBackButton';
import { promptAction, window } from '@kit.ArkUI';
import { RenderKitService } from '../service/RenderKitService';
import { image } from '@kit.ImageKit';

@Builder
export function PageBuilder(name: string, param: RouterParamsModel | undefined) {
  ImageRenderPage({ routerParams: param })
}

const xcomponentIdG: string = 'ImageRenderPageXcomponentId';

@Component
export struct ImageRenderPage {
  routerParams: RouterParamsModel | undefined = undefined;
  private pageInfos: NavPathStack = new NavPathStack();
  private input: FUNMRenderInput | undefined = undefined;
  private renderTimer: number | undefined = undefined;
  private assetData: AssetsDataInterface | undefined = undefined;
  private captureImage: boolean = false;

  async aboutToAppear() {
    this.assetData = Object(this.routerParams?.params)?.assetData as AssetsDataInterface;

    const pixelMap = this.assetData.thumbnail;
    if (pixelMap === undefined) {
      return;
    }
    let input_buffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
    pixelMap.readPixelsToBufferSync(input_buffer);
    let info = pixelMap.getImageInfoSync();
    await pixelMap.release();

    const nInput = new FUNMNormalInput();
    nInput.pixelBuffer = input_buffer;
    nInput.pixelFormat = FUNMInputBufferFormat.RGBA_BUFFER;

    const configT = new FUNMRenderConfig();
    configT.xcomponentId = xcomponentIdG;
    configT.outputType = FUNMOutputType.XCOMPONENT;

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

  aboutToDisappear(): void {
    if (this.renderTimer != undefined) {
      clearInterval(this.renderTimer)
      this.renderTimer = undefined
    }
  }

  build() {
    NavDestination() {
      Column() {
        Blank()
          .width('100%')
          .backgroundColor(Color.Black)
          .height('5%')
        this.relativeLayoutComponents()
      }
      .backgroundColor(Color.Black)
      .width('100%')
      .height('100%')
    }
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
            clearInterval(this.renderTimer);
            this.renderTimer = undefined;
            FUNMRenderKit.clearRenderTasks();
            FUNMRenderKit.releaseGLResource();
            this.pageInfos.pop(true);
          }
        })
      }
      .id('__ir_FUBackButtonRow__')

      Button({ stateEffect: true }) {
        Image($r('app.media.demo_icon_save'))
      }
      .type(ButtonType.Circle)
      .backgroundColor(Color.White)
      .alignRules({
        bottom: { anchor: "imageRenderPageDisplayView", align: VerticalAlign.Bottom },
        middle: { anchor: "imageRenderPageDisplayView", align: HorizontalAlign.Center }
      })
      .width(80)
      .height(80)
      .id("saveButton")
      .offset({ x: 10, y: -20 })
      .onClick(() => {
        this.captureImage = true;
      })
    }
    .width('100%')
    .height('85%')
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