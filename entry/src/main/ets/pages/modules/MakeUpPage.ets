import { FULogger, FUNMMakeup, FUNMRenderKit, grantPermission } from '@faceunity/renderkit_nama';
import {
  FUHeadToolBar,
  PixelBufferValues,
  RenderType,
  ResolutionValues
} from '../../components/headToolBar/FUHeadToolBar';
import { HeadToolBarController } from '../../components/headToolBar/HeadToolBarController';

import { JSON } from '@kit.ArkTS';
import { Permissions } from '@kit.AbilityKit';
import { RenderKitService } from '../../service/RenderKitService';
import { DisplayXView } from '../../components/common/DisplayXView';
import { PageBaseView } from '../../components/common/PageBaseView';
import { DynamicConfigInfo } from '../../DynamicConfigInfo';
import { RouterParamsModel } from '../../router/RouterModel';
import { MakeupPageName } from '../../constants/Constants';
import { NodeControllerService } from '../../service/NodeControllerService';
import { MakeUpViewModelController } from '../../viewModels/makeup/MakeUpViewModelController';

const xComponentIdG: string = 'MakeupPageXcomponentId';
const TAG: string = '[MakeUpPage]';
const permissions: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_IMAGEVIDEO',
  'ohos.permission.WRITE_IMAGEVIDEO'
];

@Builder
export function PageBuilder(_name: string, _param: Object) {
  MakeUpPage()
}

@Component
export struct MakeUpPage {
  @Consume('pathInfos') pathInfos: NavPathStack
  @State showMediaRender: boolean = false;
  // top ToolBar 控制
  headToolBarController: HeadToolBarController = new HeadToolBarController()
  // 视图控制器
  viewModelController: MakeUpViewModelController = MakeUpViewModelController.sharedInstance()
  private isFirstAppear: boolean = true;

  getToolBarRightItemConfig() {
    if (DynamicConfigInfo.makeupShowLocalMediaEntry) {
      return [
        RenderType.RenderType_Picture,
        RenderType.RenderType_Bugly,
        RenderType.RenderType_CameraSwitch
      ]
    }
    return [
      RenderType.RenderType_Bugly, RenderType.RenderType_CameraSwitch]
  }

  @Builder
  renderMainView() {
    RelativeContainer() {
      // display
      Row() {
        DisplayXView({
          xcomponentId: xComponentIdG
        })
      }
      .id('__FUNMDisplayView__')
      .height('100%')

      // toolbar
      Row() {
        FUHeadToolBar({
          controller: this.headToolBarController,
          leftRenderTypes: [
            RenderType.RenderType_Home
          ],
          rightRenderTypes: this.getToolBarRightItemConfig(),
          itemOnClick: (type: RenderType, value: ResolutionValues | PixelBufferValues | undefined) => {
            FULogger.info(TAG, 'FUHeadToolBar', `${type}`, `${value}`)
            if (type == RenderType.RenderType_CameraSwitch) {
              RenderKitService.sharedInstance().cameraSwitch();
              this.viewModelController.onCameraSwitch()
            } else if (type === RenderType.RenderType_Picture) {
              const routerParams: RouterParamsModel = {
                params: Object({ 'from': MakeupPageName })
              }
              this.pathInfos.pushPath({
                name: 'SelectLocalMediaPage', param: routerParams, onPop: (popInfo: PopInfo) => {
                  // TODO: 接受相册选择的资源
                  console.log(`popInfo :${JSON.stringify(popInfo.result)}}`)
                }
              })
              this.showMediaRender = true;
            }
          }
        })
          .width('100%')
      }
      .id('__FUHeadToolBar__')
      .offset({ top: 10 })

      // makeup
      Row() {
        if (!this.showMediaRender) {
          NodeContainer(NodeControllerService.sharedInstance().getMakeupViewNodeController())
            .width('100%')
        }
      }
      .id('__MakeupPageView__')
      .width('100%')
      .height(400)
      .alignRules({
        bottom: {
          anchor: '__container__',
          align: VerticalAlign.Bottom
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      PageBaseView() {
        this.renderMainView()
      }
    }
    .hideTitleBar(true)
    .onShown(async () => {
      this.showMediaRender = false;
      NodeControllerService.sharedInstance().updateMakeupViewNodeController(true)
      // 申请相机权限
      const res = await grantPermission(permissions);
      if (res) {
        FULogger.info(TAG, `权限申请成功  ${JSON.stringify(res)}`);
      } else {
        FULogger.error(TAG, `权限申请失败`);
        return
      }

      RenderKitService.sharedInstance().xcomponentId = xComponentIdG;

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
    .onAppear(() => {
      // 保存美颜值
      if (FUNMRenderKit.sharedInstance().beauty) {
        this.viewModelController.cache_beauty_filterName = FUNMRenderKit.sharedInstance()!.beauty!.filterName
        this.viewModelController.cache_beauty_filterLevel = FUNMRenderKit.sharedInstance()!.beauty!.filterLevel
      }
    })
    .onWillDisappear(async () => {
      //销毁, 需要判断是否有效，因为卸妆会将 makeup 赋值 undifine
      if(FUNMRenderKit.sharedInstance().makeup) {
        (FUNMRenderKit.sharedInstance().makeup as FUNMMakeup).destroy()
        FUNMRenderKit.sharedInstance().makeup = undefined
      }

      // 恢复美颜值
      if (FUNMRenderKit.sharedInstance().beauty) {
        FUNMRenderKit.sharedInstance()!.beauty!.filterName = this.viewModelController.cache_beauty_filterName
        FUNMRenderKit.sharedInstance()!.beauty!.filterLevel = this.viewModelController.cache_beauty_filterLevel
      }

      // 释放 viewmodel controller
      MakeUpViewModelController.destroy()
      // 释放 NodeController
      NodeControllerService.sharedInstance().destroyMakeupViewNodeController()

      RenderKitService.sharedInstance().releaseGLResource();
      await RenderKitService.sharedInstance().destroyRenderCamera();
    })
  }
}