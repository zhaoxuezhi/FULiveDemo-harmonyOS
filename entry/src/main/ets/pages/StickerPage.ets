// @Entry
import { common, Permissions } from '@kit.AbilityKit';
import { Size, window } from '@kit.ArkUI';
import {
  FULogger,
  FUNMDisplayView,
  FUNMGlobalContext,
  FUNMItem,
  FUNMRenderKit,
  grantPermission
} from '@faceunity/renderkit_nama';
import { HorizontalScrollView, HorizontalScrollViewItemInterface } from '../components/sticker/HorizontalScrollView';
import {
  FUHeadToolBar,
  PixelBufferValues,
  RenderType,
  ResolutionValues
} from '../components/headToolBar/FUHeadToolBar';
import { RouterParamsModel } from '../router/RouterModel';
import { HeadToolBarController } from '../components/headToolBar/HeadToolBarController';
import { FULightingView } from '../components/lightingView/LightingView';
import FUSafeAreaUtil from '../utils/FUSafeAreaUtil';
import { AutoRenderResolution, RenderKitService } from '../service/RenderKitService';
import { JSON } from '@kit.ArkTS';
import { CaptureButton } from '../components/common/CaptureButton';

const xcomponentIdG: string = 'BeautyPageXcomponentId';
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
  // 模板选择
  @State @Watch('onPropertyDidChange') selectItem: HorizontalScrollViewItemInterface | undefined =
    { id: 'CatSparks', imageUrl: $rawfile('sticker/images/CatSparks.png') }
  // 亮度调节控制
  @State lightingViewShow: boolean = false
  @State @Watch('onPropertyDidChange') lightingValue: number = 0
  @State timerId: number | undefined = undefined
  // top ToolBar 控制
  headToolBarController: HeadToolBarController = new HeadToolBarController()
  // 模板初始化数据
  private isFirstAppear: boolean = true;
  private currentItem: FUNMItem | undefined = undefined;
  private items: HorizontalScrollViewItemInterface[] = [
    { id: 'reset_item', imageUrl: $rawfile('sticker/images/reset_item.png') },
    { id: 'CatSparks', imageUrl: $rawfile('sticker/images/CatSparks.png') },
    { id: 'fu_zh_fenshu', imageUrl: $rawfile('sticker/images/fu_zh_fenshu.png') },
    { id: 'sdlr', imageUrl: $rawfile('sticker/images/sdlr.png') },
    { id: 'xlong_zh_fu', imageUrl: $rawfile('sticker/images/xlong_zh_fu.png') },
    { id: 'newy1', imageUrl: $rawfile('sticker/images/newy1.png') },
    { id: 'redribbt', imageUrl: $rawfile('sticker/images/redribbt.png') },
    { id: 'DaisyPig', imageUrl: $rawfile('sticker/images/DaisyPig.png') },
    { id: 'sdlu', imageUrl: $rawfile('sticker/images/sdlu.png') },
  ];

  onPropertyDidChange(properTyName: string) {
    if (properTyName === 'lightingValue') {
      console.log('properTyName = ', properTyName, 'this.lightingValue = ', this.lightingValue)
      this.hiddenLightingViewDelay()

    } else if (properTyName === 'selectItem') {
      this.updateSticker()
    }
  }

  updateSticker() {
    if (this.selectItem?.id === 'reset_item') {
      FUNMRenderKit.sharedInstance().sticker = undefined;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
      this.destroyCurrentItemIfNeed();
    } else if (this.selectItem?.id) {
      const rawfilePath = `sticker/bundles/${this.selectItem?.id}.bundle`;
      const sticker = new FUNMItem({ rawfilePath: rawfilePath });
      FUNMRenderKit.sharedInstance().sticker = sticker;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
      this.destroyCurrentItemIfNeed();
      this.currentItem = sticker;
    }
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
      Column() {
        RelativeContainer() {
          // display
          Row() {
            FUNMDisplayView({ viewId: xcomponentIdG, resolution: this.calculateAppropriateDisplayPageSize() })
              .width('100%')
          }
          // .addGesture()
          .id('__FUNMDisplayView__')
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })

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
                    params: Object({ 'from': 'sticker' })
                  }
                  this.pageInfos.pushPath({
                    name: 'SelectLocalMediaPage', param: routerParams, onPop: (popInfo: PopInfo) => {
                      // TODO: 接受相册选择的资源
                      console.log(`popInfo :${JSON.stringify(popInfo.result)}}`)
                    }
                  })
                  RenderKitService.sharedInstance().clearXComponent();
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
          })
          .offset({ top: 15 })

          // 视频/图片采集
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
          .id('__CaptureButton__')
          .alignRules({
            bottom: { anchor: '__FUNMDisplayView__', align: VerticalAlign.Bottom },
            middle: { anchor: '__FUNMDisplayView__', align: HorizontalAlign.Center }
          })
          .offset({ bottom: 10 })

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
        }
        .layoutWeight(1)

        HorizontalScrollView({
          items: this.items,
          selectedItem: this.selectItem,
          frames: { imgWidth: 60 },
        })
          .padding({ top: 10 })
      }
      .padding({ top: FUSafeAreaUtil.getStatusBarHeight(), bottom: FUSafeAreaUtil.getBottomBarHeight() || 30 })
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
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
    .onShown(async () => {
      if (this.isFirstAppear) {
        this.isFirstAppear = false;
        await RenderKitService.sharedInstance().startRenderWithDefaultSetting();
      } else {
        await RenderKitService.sharedInstance().startRender();
      }
      this.updateSticker()
      RenderKitService.sharedInstance().gravityEnable(true);
    })
    .onHidden(async () => {
      await RenderKitService.sharedInstance().stopRender();
      RenderKitService.sharedInstance().gravityEnable(false);
    })
    .onWillDisappear(async () => {
      console.info('PPPP onWillDisappear');

      //重置贴纸效果
      FUNMRenderKit.sharedInstance().sticker = undefined;
      this.destroyCurrentItemIfNeed();
    })
  }

  private calculateAppropriateDisplayPageSize(): Size {
    const ratio = AutoRenderResolution.width / AutoRenderResolution.height;
    const windowRect = FUNMGlobalContext.getContext().getValue('mainWindowRect') as window.Rect;
    return { width: windowRect.width, height: windowRect.width * ratio };
  }

  private destroyCurrentItemIfNeed() {
    if (this.currentItem !== undefined) {
      this.currentItem.destroy();
      this.currentItem = undefined;
    }
  }
}