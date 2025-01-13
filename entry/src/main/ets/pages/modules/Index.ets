import { FULogger, FUNMFileUtil } from '@faceunity/renderkit_nama';
import { HomeItem } from '../../components/home/DataConfig';
import { ItemContainerView } from '../../components/home/ItemContanerView';
import { RouterPageConfig, RouterParamsModel } from '../../router/RouterModel';
import { RenderKitService } from '../../service/RenderKitService';
import { display, window } from '@kit.ArkUI';
import FUSafeAreaUtil from '../../utils/FUSafeAreaUtil';
import { BeautyDataService } from '../../service/BeautyDataService';
import { SimpleStickerPageType } from './SimpleStickerPage';

const TAG: string = '[IndexPage]';

@Entry
@Component
struct Index {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();

  async aboutToAppear() {
    RenderKitService.sharedInstance().initRenderKit();
    RenderKitService.sharedInstance().initAIKit();
    RenderKitService.sharedInstance().loadBeauty();
    BeautyDataService.sharedInstance().skinViewModel.setAllSkinValues();
    BeautyDataService.sharedInstance().shapeViewModel.setAllShapeValues();
    BeautyDataService.sharedInstance().filterViewModel.setCurrentFilter();
  }

  async aboutToDisappear() {
    await RenderKitService.sharedInstance().destroyRenderKit();
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        Blank()
          .backgroundColor(Color.Black)
          .width('100%')
          .height(40)
        Text('FULiveDemo 特效版')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.Black)
          .fontColor(Color.White)
          .width('100%')
          .height(56)
        Divider().strokeWidth(1).color('#302D33')

        ItemContainerView({
          onItemClick: (item: HomeItem) => {
            const pageName: string = RouterPageConfig.get(item.label) as string
            let routerParams: RouterParamsModel = {}

            // 哈哈镜
            if (pageName === 'DistortingMirrorPage') {
              routerParams = {
                params: Object({ pageType: SimpleStickerPageType.DISTORTING_MIRROR })
              }
            } else if (pageName === 'FunnyBigHead') {
              // 搞笑大头
              routerParams = {
                params: Object({ pageType: SimpleStickerPageType.FUNNY_BIG_HEAD })
              }
            }
            if (pageName) {
              this.pathInfos.pushPath({ name: pageName, param: routerParams })
            } else {
              FULogger.error(TAG, '跳转失败', '请先注册路由')
            }
          }
        })
          .layoutWeight(1)
      }
      .backgroundColor(0x090017)
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .onAppear(() => {
      window.getLastWindow(getContext(this), (error, topWindow) => {
        if (topWindow) {
          // 获取屏幕安全区域
          const area = topWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          FUSafeAreaUtil.setStatusBarHeight(px2vp(area.topRect.height))
          FUSafeAreaUtil.setBottomBarHeight(px2vp(area.bottomRect.height))
        }
      });
      FUSafeAreaUtil.setScreenHeight(display.getDefaultDisplaySync().height)
      FUSafeAreaUtil.setScreenWidth(display.getDefaultDisplaySync().width)
    })
  }
}

