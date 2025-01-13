// @Entry
import { Permissions } from '@kit.AbilityKit';
import { FULogger, FUNMAIKit, FUNMRenderKit, grantPermission } from '@faceunity/renderkit_nama';
import {
  FUHeadToolBar,
  PixelBufferValues,
  RenderType,
  ResolutionValues
} from '../../components/headToolBar/FUHeadToolBar';
import { HeadToolBarController } from '../../components/headToolBar/HeadToolBarController';
import { RenderKitService } from '../../service/RenderKitService';
import { JSON } from '@kit.ArkTS';
import { PageBaseView } from '../../components/common/PageBaseView';
import { DisplayXView } from '../../components/common/DisplayXView';
import { SimpleStickerView } from '../../components/simpleSticker/SimpleStickerView';
import { RouterParamsModel } from '../../router/RouterModel';
import { promptAction } from '@kit.ArkUI';
import { AutoDismissToast } from '../../components/common/AutoDismissToast';

const xcomponentIdG: string = 'DistortingMirrorPageXcomponentId';
const TAG: string = '[DistortingMirrorPage]';

const permissions: Array<Permissions> = [
  'ohos.permission.CAMERA',
  'ohos.permission.READ_IMAGEVIDEO',
  'ohos.permission.WRITE_IMAGEVIDEO'
];

export enum SimpleStickerPageType {
  DISTORTING_MIRROR, // 哈哈镜
  FUNNY_BIG_HEAD, // 搞笑大头
}

@Builder
export function PageBuilder(_name: string, param: RouterParamsModel) {
  SimpleStickerPage({ pageType: Object(param.params).pageType })
}

@Component
export struct SimpleStickerPage {
  @Consume('pathInfos') pageInfos: NavPathStack
  // top ToolBar 控制
  headToolBarController: HeadToolBarController = new HeadToolBarController()
  @Require @Prop pageType: SimpleStickerPageType
  // 模板初始化数据
  private isFirstAppear: boolean = true;
  @State private toastMessage: string = ''
  private preMaxTrackFaces: number = 1

  aboutToAppear(): void {
    if (this.pageType === undefined) {
      promptAction.showToast({ message: '参数错误！' });
    }
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
            .id('__FUHeadToolBar__')
            .width('100%')
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              left: { anchor: '__container__', align: HorizontalAlign.Start },
            })
            .offset({ top: 15 })

          // 贴纸主视图
          SimpleStickerView({
            pageType: this.pageType, showToastCb: (toast: string) => {
              this.toastMessage = toast
            }
          })
            .id('__DistortingMirrorView__')
            .height(180)
            .width('100%')
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            })

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
      RenderKitService.sharedInstance().gravityEnable(true);
    })
    .onHidden(async () => {
      await RenderKitService.sharedInstance().stopRender();
      RenderKitService.sharedInstance().gravityEnable(false);
    })
    .onWillAppear(() => {
      this.preMaxTrackFaces = FUNMAIKit.shareKit().maxTrackFaces
      if (this.pageType === SimpleStickerPageType.FUNNY_BIG_HEAD) {
        FUNMAIKit.shareKit().maxTrackFaces = 1
      }
    })
    .onWillDisappear(async () => {
      //重置哈哈镜效果
      if (FUNMRenderKit.sharedInstance().distortingMirror) {
        FUNMRenderKit.sharedInstance().distortingMirror?.destroy();
        FUNMRenderKit.sharedInstance().distortingMirror = undefined;
      }
      if (FUNMRenderKit.sharedInstance().funnyBigHead) {
        FUNMRenderKit.sharedInstance().funnyBigHead?.destroy();
        FUNMRenderKit.sharedInstance().funnyBigHead = undefined;
      }

      // 恢复最大人脸检测数量
      if (this.pageType === SimpleStickerPageType.FUNNY_BIG_HEAD) {
        FUNMAIKit.shareKit().maxTrackFaces = this.preMaxTrackFaces
      }

      RenderKitService.sharedInstance().releaseGLResource();
      await RenderKitService.sharedInstance().destroyRenderCamera();
    })
  }
}