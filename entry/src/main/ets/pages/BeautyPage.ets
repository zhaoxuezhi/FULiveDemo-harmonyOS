import { common, Permissions } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { FUNMDisplayView, grantPermission, FULogger, FUNMGlobalContext } from '@faceunity/renderkit_nama'
import { AutoRenderResolution, RenderKitService } from '../service/RenderKitService'
import { BeautySkinView } from '../components/beauty/BeautySkinView'
import { BeautyShapeView } from '../components/beauty/BeautyShapeView'
import { BeautyFilterView } from '../components/beauty/BeautyFilterView'
import { SELECTCOLOR } from '../constants/BeautyConstants';
import { BeautyDataService } from '../service/BeautyDataService';
import {
  FUHeadToolBar,
  PixelBufferValues,
  RenderType,
  ResolutionValues
} from '../components/headToolBar/FUHeadToolBar';
import { RouterParamsModel } from '../router/RouterModel';
import { HeadToolBarController } from '../components/headToolBar/HeadToolBarController';
import { CaptureButton } from '../components/common/CaptureButton';

const xcomponentIdG: string = 'BeautyPageXcomponentId';
const TAG: string = '[BeautyPage]';

export enum FUBeautyType {
  Skin,
  Shape,
  Filter
}

const permissions: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_IMAGEVIDEO',
  'ohos.permission.WRITE_IMAGEVIDEO'
];

@Builder
export function BeautyPageBuilder(name: string, param: Object) {
  BeautyPage()
}

@Component
export struct BeautyPage {
  pageInfos: NavPathStack = new NavPathStack();
  @State beautyType: FUBeautyType = FUBeautyType.Skin;
  private xController: XComponentController | undefined = undefined;
  private shouldDoRender: boolean = true;
  private isFirstAppear: boolean = true;
  private headToolBarController: HeadToolBarController = new HeadToolBarController()
  xcomponentOnloadCallBack = (controller: XComponentController) => {
    this.xController = controller;
  }

  build() {
    NavDestination() {
      Column() {
        Blank()
          .width('100%')
          .backgroundColor(Color.Black)
          .height('5%')
        this.relativeLayoutComponents()
        this.bottomBeautyStyleComponents()
      }
      .backgroundColor(Color.Black)
      .width('100%')
      .height('100%')
    }
    .onWillAppear(async () => {
      console.info('PPPP onWillAppear');

      // 申请相机权限
      const res = await grantPermission(permissions);
      if (res) {
        FULogger.info(TAG, `权限申请成功  ${JSON.stringify(res)}`);
      } else {
        FULogger.error(TAG, `权限申请失败`);
        return
      }

      RenderKitService.sharedInstance().xcomponentId = xcomponentIdG;
    })
    .onWillDisappear(async () => {
      BeautyDataService.sharedInstance().skinViewModel.saveSkinDataPersistently();
      BeautyDataService.sharedInstance().shapeViewModel.saveShapeDataPersistently();
      BeautyDataService.sharedInstance().filterViewModel.saveFilterDataPersistently();
    })
    .onShown(async () => {
      if (this.isFirstAppear) {
        this.isFirstAppear = false;
        await RenderKitService.sharedInstance().startRenderWithDefaultSetting();
      } else {
        await RenderKitService.sharedInstance().startRender();
      }
    })
    .onHidden(async () => {
      await RenderKitService.sharedInstance().stopRender();
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
        resolution: this.calculateAppropriateDisplayPageSize(),
        onLoadCallBack: this.xcomponentOnloadCallBack
      })
        .width('100%')
        .height('100%')
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .id("displayView")

      FUHeadToolBar({
        controller: this.headToolBarController,
        leftRenderTypes: [
          RenderType.RenderType_Home,
        ],
        rightRenderTypes: [
          RenderType.RenderType_More,
          RenderType.RenderType_Bugly,
          RenderType.RenderType_CameraSwitch,
        ],
        itemOnClick: (type: RenderType, value: ResolutionValues | PixelBufferValues | undefined) => {
          FULogger.info(TAG, 'FUHeadToolBar', `${type}`, `${value}`)
          if (type == RenderType.RenderType_Picture) {
            const routerParams: RouterParamsModel = {
              params: Object({ 'from': 'sticker' })
            }
            this.pageInfos.pushPath({ name: 'SelectLocalMediaPage', param: routerParams })
            RenderKitService.sharedInstance().clearXComponent();
          } else if (type == RenderType.RenderType_CameraSwitch) {
            RenderKitService.sharedInstance().cameraSwitch();
          } else if (type == RenderType.RenderType_Resolution) {
            const resolution = value as ResolutionValues;
            const parts = resolution.split('×')
            if (parts.length != 2) {
              FULogger.error('resolution is error!!');
              return;
            }
            const width = Number(parts[1]);
            const height = Number(parts[0]);
            RenderKitService.sharedInstance()
              .changeCamaraResolution({ width: width, height: height }, () => {
                const size = this.calculateAppropriateDisplayPageSize(width / height);
                this.xController?.setXComponentSurfaceRect({
                  surfaceWidth: size.width,
                  surfaceHeight: size.height
                })
              });
            AppStorage.set('resolution', resolution);
          }
        }
      })
        .alignRules({
          top: { anchor: "displayView", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .width('100%')
        .id('FUHeadToolBar')
        .offset({ top: 15 })

      Stack() {
        BeautyFilterView()
          .visibility(this.beautyType === FUBeautyType.Filter ? Visibility.Visible : Visibility.Hidden)
          .width('100%')
          .height('100%')

        BeautyShapeView()
          .visibility(this.beautyType === FUBeautyType.Shape ? Visibility.Visible : Visibility.Hidden)
          .width('100%')
          .height('100%')

        BeautySkinView()
          .visibility(this.beautyType === FUBeautyType.Skin ? Visibility.Visible : Visibility.Hidden)
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height(130)
      .alignRules({
        bottom: { anchor: "displayView", align: VerticalAlign.Bottom },
        left: { anchor: "displayView", align: HorizontalAlign.Start }
      })
      .id("beautyView")

      Button({ stateEffect: true }) {
        Image($r('app.media.demo_icon_contrast'))
      }
      .alignRules({
        bottom: { anchor: "beautyView", align: VerticalAlign.Top },
        left: { anchor: "beautyView", align: HorizontalAlign.Start }
      })
      .width(40)
      .height(40)
      .id("compareButton")
      .offset({ x: 10, y: -20 })
      .onTouch((event: TouchEvent) => {
        switch (event.type) {
          case TouchType.Up:
          case TouchType.Cancel:
            if (!this.shouldDoRender) {
              RenderKitService.sharedInstance().shouldDoRender = true;
              this.shouldDoRender = true;
            }
            break;
          case TouchType.Down:
          case TouchType.Move:
            if (this.shouldDoRender) {
              RenderKitService.sharedInstance().shouldDoRender = false;
              this.shouldDoRender = false;
            }
            break;
        }
      });

      Row() {
        //TODO: 图片/视频采集回调函数实现
        CaptureButton({
          onClickCallback: () => {
            FULogger.info('YYYY 截图点击了');
            RenderKitService.sharedInstance().captureImageFromAutoRender = true;
          }, onLongPressStartCallback: () => {
          }, onLongPressEndCallback: () => {
          }
        })
          .size({ width: 70, height: 70 })
      }
      .id('captureButton')
      .alignRules({
        bottom: { anchor: 'beautyView', align: VerticalAlign.Top },
        middle: { anchor: 'beautyView', align: HorizontalAlign.Center }
      })
      .offset({ bottom: 10 })
    }
    .width('100%')
    .height('85%')
    .backgroundColor(Color.Black)
    .addGesture()
  }

  @Styles
  addGesture() {
    .gesture(
      TapGesture()
        .onAction(() => {
          // 如果moreView 显示，则隐藏，不显示 LightView
          // if (!this.headToolBarController.morePopViewIsShowing()) {
          //   this.lightingViewShow = true
          //   this.hiddenLightingViewDelay()
          // }
          this.headToolBarController.onScreenTopAction()
        }))
  }

  @Builder
  bottomBeautyStyleComponents() {
    Row() {
      Text('美肤')
        .fontSize(16)
        .width('33%')
        .textAlign(TextAlign.Center)
        .fontColor(this.beautyType === FUBeautyType.Skin ? SELECTCOLOR : Color.White)
        .onClick(() => {
          this.beautyType = FUBeautyType.Skin;
        })
      Text('美型')
        .fontSize(16)
        .width('33%')
        .textAlign(TextAlign.Center)
        .fontColor(this.beautyType === FUBeautyType.Shape ? SELECTCOLOR : Color.White)
        .onClick(() => {
          this.beautyType = FUBeautyType.Shape;
        })
      Text('滤镜')
        .fontSize(16)
        .width('33%')
        .textAlign(TextAlign.Center)
        .fontColor(this.beautyType === FUBeautyType.Filter ? SELECTCOLOR : Color.White)
        .onClick(() => {
          this.beautyType = FUBeautyType.Filter;
        })
    }
    .backgroundColor(Color.Black)
    .width('100%')
    .height('10%')
  }

  private calculateAppropriateDisplayPageSize(ratio?: number): Size {
    const windowRect = FUNMGlobalContext.getContext().getValue('mainWindowRect') as window.Rect;
    const height = windowRect.height * 0.85;
    if (ratio) {
      return { width: height / ratio, height: height };
    } else {
      const camaraRatio = AutoRenderResolution.width / AutoRenderResolution.height;
      return { width: height / camaraRatio, height: height };
    }
  }
}