// @Entry
import { Permissions } from '@kit.AbilityKit';
import { FUAIHUMANSEGMODE, FUAITYPE, FULogger, FUNMAIKit, FUNMRenderKit, grantPermission } from '@faceunity/renderkit_nama';
import { FUHeadToolBar, PixelBufferValues, RenderType, ResolutionValues } from '../../components/headToolBar/FUHeadToolBar';
import { HeadToolBarController } from '../../components/headToolBar/HeadToolBarController';
import { RenderKitService } from '../../service/RenderKitService';
import { JSON } from '@kit.ArkTS';
import { PageBaseView } from '../../components/common/PageBaseView';
import { DisplayXView } from '../../components/common/DisplayXView';
import { RouterParamsModel } from '../../router/RouterModel';
import { AutoDismissToast } from '../../components/common/AutoDismissToast';
import { SegmentationView, SegmentationViewController } from '../../components/segmentation/SegmentationView';
import { SelectSegmentModeView } from '../../components/segmentation/SelectSegmentModeView';

const xcomponentIdG: string = 'DistortingMirrorPageXcomponentId';
const TAG: string = '[DistortingMirrorPage]';

const permissions: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_IMAGEVIDEO',
  'ohos.permission.WRITE_IMAGEVIDEO'
];

@Builder
export function PageBuilder(_name: string, param: RouterParamsModel) {
  SegmentationPage()
}

@Component
export struct SegmentationPage {
  @Consume('pathInfos') pageInfos: NavPathStack
  // top ToolBar 控制
  headToolBarController: HeadToolBarController = new HeadToolBarController()
  // 模板初始化数据
  private isFirstAppear: boolean = true;
  @State private toastMessage: string = ''
  @State private showSelectSegmentModeView: boolean = true
  private controller: SegmentationViewController = new SegmentationViewController();

  aboutToAppear(): void {
  }

  build() {
    NavDestination() {
      PageBaseView() {
        RelativeContainer() {
          // display
          DisplayXView({ xcomponentId: xcomponentIdG })
            .id('__FUNMDisplayView__')

          // toolbar
          FUHeadToolBar({
            controller: this.headToolBarController,
            leftRenderTypes: [
              RenderType.RenderType_Home,
            ],
            rightRenderTypes: [
              RenderType.RenderType_Bugly,
              RenderType.RenderType_CameraSwitch,
            ],
            itemOnClick: (type: RenderType, value: ResolutionValues | PixelBufferValues | undefined) => {
              FULogger.info(TAG, 'FUHeadToolBar', `${type}`, `${value}`)
              if (type == RenderType.RenderType_CameraSwitch) {
                RenderKitService.sharedInstance().cameraSwitch();
              }
            }
          })
            .zIndex(2)
            .id('__FUHeadToolBar__')
            .width('100%')
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              left: { anchor: '__container__', align: HorizontalAlign.Start },
            })
            .offset({ top: 15 })

          // 贴纸主视图
          SegmentationView({
            showSelectSegmentModeView: this.showSelectSegmentModeView,
            showToastCb: (toast: string) => {
              this.toastMessage = toast
            },
            controller: this.controller
          })
            .id('__DistortingMirrorView__')
            .height(180)
            .width('100%')
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            })

          // 模式选择
          if (this.showSelectSegmentModeView) {
            SelectSegmentModeView({
              onGeneralClick: () => {
                FUNMAIKit.loadAIHumanModelWithDataPath({ rawfilePath: 'ai_human_processor.bundle' },
                  FUAIHUMANSEGMODE.FUAIHUMAN_SEG_GPU_COMMON);
                this.showSelectSegmentModeView = false
              },
              onMeetingClick: () => {
                FUNMAIKit.loadAIHumanModelWithDataPath({ rawfilePath: 'ai_human_processor.bundle' },
                  FUAIHUMANSEGMODE.FUAIHUMAN_SEG_GPU_MEETING);
                this.showSelectSegmentModeView = false
              }
            })
              .id('__SelectSegmentModeView__')
              .width('100%')
              .alignRules({
                top: { anchor: '__container__', align: VerticalAlign.Top },
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              })
          }

          // 选中 item toast 提示
          AutoDismissToast({
            message: this.toastMessage
          })
            .id('__SelectItemToast__')
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
            })
        }
        .width('100%')
        .height('100%')
      }
    }
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onShown(async () => {
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
      if (this.controller.show) {
        this.controller.show();
      }
      RenderKitService.sharedInstance().gravityEnable(true);
    })
    .onHidden(async () => {
      if (this.controller.hidden) {
        this.controller.hidden();
      }
      await RenderKitService.sharedInstance().stopRender();
      RenderKitService.sharedInstance().gravityEnable(false);
    })
    .onWillDisappear(async () => {
      //重置效果
      if (FUNMRenderKit.sharedInstance().segmentation) {
        FUNMRenderKit.sharedInstance().segmentation?.destroy();
        FUNMRenderKit.sharedInstance().segmentation = undefined;
      }
      // 释放
      FUNMAIKit.unloadAIHumanModelIfNeeded()

      RenderKitService.sharedInstance().releaseGLResource();
      await RenderKitService.sharedInstance().destroyRenderCamera();
    })
  }
}