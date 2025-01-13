// @Entry
import { Permissions } from '@kit.AbilityKit';
import { FULogger, FUNMRenderKit, grantPermission } from '@faceunity/renderkit_nama';
import {
    FUHeadToolBar,
    PixelBufferValues,
    RenderType,
    ResolutionValues
} from '../../components/headToolBar/FUHeadToolBar';
import { RouterParamsModel } from '../../router/RouterModel';
import { HeadToolBarController } from '../../components/headToolBar/HeadToolBarController';
import { FULightingView } from '../../components/lightingView/LightingView';
import { RenderKitService } from '../../service/RenderKitService';
import { JSON } from '@kit.ArkTS';
import { StickerPageName } from '../../constants/Constants';
import { NodeControllerService } from '../../service/NodeControllerService';
import { PageBaseView } from '../../components/common/PageBaseView';
import { DisplayXView } from '../../components/common/DisplayXView';

const xcomponentIdG: string = 'StickerPageXcomponentId';
const TAG: string = '[StickerPage]';

const permissions: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_IMAGEVIDEO',
  'ohos.permission.WRITE_IMAGEVIDEO'
];

@Builder
export function PageBuilder(name: string, param: Object) {
  StickerPage()
}

@Component
export struct StickerPage {
  @Consume('pathInfos') pageInfos: NavPathStack
  @State showMediaRender: boolean = false;
  // 亮度调节控制
  @State lightingViewShow: boolean = false
  @State @Watch('onLightingValueDidChange') lightingValue: number = 0
  @State timerId: number | undefined = undefined
  // top ToolBar 控制
  headToolBarController: HeadToolBarController = new HeadToolBarController()
  // 模板初始化数据
  private isFirstAppear: boolean = true;

  onLightingValueDidChange(properTyName: string) {
    console.log('properTyName = ', properTyName, 'this.lightingValue = ', this.lightingValue)
    this.hiddenLightingViewDelay()
  }

  hiddenLightingViewDelay() {
    if (this.timerId) {
      clearTimeout(this.timerId)
    }
    this.timerId = setTimeout(() => {
      this.lightingViewShow = false
    }, 2000)
  }

  @Styles
  addGesture() {
    .gesture(
      TapGesture()
        .onAction(() => {
          // 如果moreView 显示，则隐藏，不显示 LightView
          if (!this.headToolBarController.morePopViewIsShowing()) {
            this.lightingViewShow = true
            this.hiddenLightingViewDelay()
          }
          this.headToolBarController.onScreenTopAction()
        }))
  }

  build() {
    NavDestination() {
      PageBaseView() {
        RelativeContainer() {
          // display
          Row() {
            DisplayXView({ xcomponentId: xcomponentIdG })
          }
          // .addGesture()
          .id('__FUNMDisplayView__')

          // toolbar
          Row() {
            FUHeadToolBar({
              controller: this.headToolBarController,
              leftRenderTypes: [
                RenderType.RenderType_Home,
              ],
              rightRenderTypes: [
                RenderType.RenderType_Picture,
                RenderType.RenderType_Bugly,
                RenderType.RenderType_CameraSwitch,
              ],
              itemOnClick: (type: RenderType, value: ResolutionValues | PixelBufferValues | undefined) => {
                FULogger.info(TAG, 'FUHeadToolBar', `${type}`, `${value}`)
                //TODO: 处理不同类型的点击事件
                if (type == RenderType.RenderType_Picture) {
                  const routerParams: RouterParamsModel = {
                    params: Object({ 'from': StickerPageName })
                  }
                  this.pageInfos.pushPath({
                    name: 'SelectLocalMediaPage', param: routerParams, onPop: (popInfo: PopInfo) => {
                      // TODO: 接受相册选择的资源
                      console.log(`popInfo :${JSON.stringify(popInfo.result)}}`)
                    }
                  })
                  this.showMediaRender = true;
                } else if (type == RenderType.RenderType_CameraSwitch) {
                  RenderKitService.sharedInstance().cameraSwitch();
                }
              }
            })
              .width('100%')
          }
          .id('__FUHeadToolBar__')
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
          })
          .offset({ top: 15 })

          // 亮度条
          if (this.lightingViewShow) {
            Row() {
              FULightingView({
                show: this.lightingViewShow,
                value: this.lightingValue
              })
                .size({ width: 30, height: '30%' })
            }
            .id('__FULightingView__')
            .alignRules({
              top: { anchor: '__FUHeadToolBar__', align: VerticalAlign.Bottom },
              right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .offset({ top: 70, right: 15 })
          }

          // 贴纸主视图
          Row() {
            if (!this.showMediaRender) {
              NodeContainer(NodeControllerService.sharedInstance().getStickerViewNodeController())
                .width('100%')
                .height(180)
            }
          }
          .id('__NodeContainer__')
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          })
        }
        .width('100%')
        .height('100%')
      }
    }
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onShown(async () => {
      this.showMediaRender = false;
      NodeControllerService.sharedInstance().updateStickerViewNodeController(true);

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

      RenderKitService.sharedInstance().gravityEnable(true);
    })
    .onHidden(async () => {
      await RenderKitService.sharedInstance().stopRender();
      RenderKitService.sharedInstance().gravityEnable(false);
    })
    .onWillDisappear(async () => {
      //重置贴纸效果
      const currentItem = FUNMRenderKit.sharedInstance().sticker;
      FUNMRenderKit.sharedInstance().sticker = undefined;
      if (currentItem) {
        currentItem.destroy();
      }
      NodeControllerService.sharedInstance().destroyStickerViewNodeController();

      RenderKitService.sharedInstance().releaseGLResource();
      await RenderKitService.sharedInstance().destroyRenderCamera();
    })
  }
}