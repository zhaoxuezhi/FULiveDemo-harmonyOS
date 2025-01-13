import { FUNMDisplayView, FUNMGlobalContext } from '@faceunity/renderkit_nama';
import { AutoRenderResolution } from '../../service/RenderKitService';
import { window } from '@kit.ArkUI';

@Component
export struct DisplayXView {
  @Require xcomponentId : string = ''
  // 视图控制器
  controller : DisplayXViewController | undefined
  // 保存当前视图的 px size
  selfPxSize : Size | undefined

  private xController: XComponentController | undefined = undefined;
  xcomponentOnloadCallBack = (controller: XComponentController) => {
    this.xController = controller;
  }

  aboutToAppear(): void {
    if(this.controller) {
      this.controller.camaraResolutionDidChange = (resolution : Size) => {
        const size =
          this.calculateAppropriateDisplayPageSize(this.selfPxSize, resolution);
        this.xController?.setXComponentSurfaceRect({
          surfaceWidth: size.width,
          surfaceHeight: size.height
        })
      }
    }
  }

  @Styles
  getSelfFrame() {
    .onAreaChange((_: Area, newArea: Area) => {
      this.selfPxSize = {width : vp2px(newArea.width as number),height: vp2px(newArea.height as number) }
      const size =
        this.calculateAppropriateDisplayPageSize(this.selfPxSize);
      this.xController?.setXComponentSurfaceRect({
        surfaceWidth: size.width,
        surfaceHeight: size.height
      })
    })
  }

  build() {
    Row() {
      FUNMDisplayView({
        viewId: this.xcomponentId,
        resolution: this.calculateAppropriateDisplayPageSize(),
        onLoadCallBack: this.xcomponentOnloadCallBack
      })
        .width('100%')
    }
    .backgroundColor(Color.Red)
    .width('100%')
    .height('100%')
    .getSelfFrame()
  }

  private calculateAppropriateDisplayPageSize(xViewSize?: Size, resolution?: Size): Size {
    if (!xViewSize || !xViewSize.width || !xViewSize.height) {
      const windowRect = FUNMGlobalContext.getContext().getValue('mainWindowRect') as window.Rect;
      xViewSize = { width: windowRect.width, height: windowRect.height }
    }
    if (!resolution || !resolution.width || !resolution.height) {
      resolution = AutoRenderResolution
    }
    // 分辨率是横向的，1280*720，表示输出图片的 size={width: 720,height: 1280}
    const imageSize : Size = { width : resolution.height, height : resolution.width}
    const imageRatio = imageSize.width / imageSize.height;
    const areaRatio = xViewSize.width / xViewSize.height;

    let finalWidth = 0, finalHeight = 0;

    if (imageRatio > areaRatio) {
      // 如果图片更宽，则高度适配区域高度，宽度等比例放大
      finalHeight = xViewSize.height;
      finalWidth = xViewSize.height * imageRatio;
    } else {
      // 如果图片更高，则宽度适配区域宽度，高度等比例放大
      finalWidth = xViewSize.width;
      finalHeight = xViewSize.width / imageRatio;
    }

    return {
      width: Math.round(finalWidth),
      height: Math.round(finalHeight)
    };
  }
}

export class DisplayXViewController {
  // 分辨率变化后回调
  camaraResolutionDidChange = (resolution : Size) => {}
}
