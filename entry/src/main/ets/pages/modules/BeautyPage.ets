import { Permissions } from '@kit.AbilityKit';
import { FULogger, grantPermission } from '@faceunity/renderkit_nama';
import { RenderKitService } from '../../service/RenderKitService';
import { BeautyPageName } from '../../constants/Constants';
import { BeautyDataService } from '../../service/BeautyDataService';
import { NodeControllerService } from '../../service/NodeControllerService';

import {
    FUHeadToolBar,
    PixelBufferValues,
    RenderType,
    ResolutionValues
} from '../../components/headToolBar/FUHeadToolBar';
import { RouterParamsModel } from '../../router/RouterModel';
import { HeadToolBarController } from '../../components/headToolBar/HeadToolBarController';
import { DisplayXView, DisplayXViewController } from '../../components/common/DisplayXView';
import { PageBaseView } from '../../components/common/PageBaseView';

const xcomponentIdG: string = 'BeautyPageXcomponentId';
const xcomponentHeightRatio = 0.9;
const TAG: string = '[BeautyPage]';

const permissions: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_IMAGEVIDEO',
  'ohos.permission.WRITE_IMAGEVIDEO'
];

@Builder
export function PageBuilder(name: string, param: Object) {
  BeautyPage()
}

@Component
export struct BeautyPage {
  pageInfos: NavPathStack = new NavPathStack();
  @State showMediaRender: boolean = false;
  private displayXViewController: DisplayXViewController = new DisplayXViewController()
  private isFirstAppear: boolean = true;
  private headToolBarController: HeadToolBarController = new HeadToolBarController()

  build() {
    NavDestination() {
      PageBaseView(){
        this.relativeLayoutComponents()
      }
    }
    .onWillDisappear(async () => {
      BeautyDataService.sharedInstance().skinViewModel.saveSkinDataPersistently();
      BeautyDataService.sharedInstance().shapeViewModel.saveShapeDataPersistently();
      BeautyDataService.sharedInstance().filterViewModel.saveFilterDataPersistently();
      NodeControllerService.sharedInstance().destroyBeautyViewNodeController();
      RenderKitService.sharedInstance().releaseGLResource();
      await RenderKitService.sharedInstance().destroyRenderCamera();
    })
    .onShown(async () => {
      // NodeController 渲染设置
      this.showMediaRender = false;
      NodeControllerService.sharedInstance().updateBeautyViewNodeController(true);

      // 申请相机权限
      const res = await grantPermission(permissions);
      if (res) {
        FULogger.info(TAG, `权限申请成功  ${JSON.stringify(res)}`);
      } else {
        FULogger.error(TAG, `权限申请失败`);
        return
      }

      RenderKitService.sharedInstance().xcomponentId = xcomponentIdG;

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
      DisplayXView({ xcomponentId: xcomponentIdG, controller: this.displayXViewController })
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
              params: Object({ 'from': BeautyPageName })
            }
            this.pageInfos.pushPath({ name: 'SelectLocalMediaPage', param: routerParams })
            this.showMediaRender = true;
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
                this.displayXViewController.camaraResolutionDidChange({ width, height })
              });
            AppStorage.set('resolution', resolution);
          }
        }
      })
        .width('100%')
        .id('FUHeadToolBar')
        .alignRules({
          top: { anchor: "displayView", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .offset({ top: 15 })

      if (!this.showMediaRender) {
        NodeContainer(NodeControllerService.sharedInstance().getBeautyViewNodeController())
          .width('100%')
          .height(270)
          .id('__beautyView__')
          .alignRules({
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start }
          })
      }
    }
    .width('100%')
    .height('100%')
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
}