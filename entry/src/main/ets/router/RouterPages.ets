import { FUBackButtonRow } from '../components/common/FUBackButton'
import { BeautyPage } from '../pages/BeautyPage'
import { SelectLocalMediaPage } from '../pages/SelectLocalMediaPage'
import { StickerPage } from '../pages/StickerPage'
import FUSafeAreaUtil from '../utils/FUSafeAreaUtil'
import { RouterParamsModel } from './RouterModel'

@Component
export struct NavDestinationPage {
  @Require name: string = ''
  params: RouterParamsModel | undefined

  build() {
    if (this.name === '美颜') {
      BeautyPage()
    } else if (this.name === '道具贴纸') {
      StickerPage()
    } else if (this.name === 'SelectLocalMediaPage') {
      SelectLocalMediaPage({
        routerParams: this.params
      })
    } else {
      Column() {
        FUBackButtonRow()
        Text('敬请期待')
          .fontColor(Color.White)
          .fontSize(24)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: '50%' })
      }
      .backgroundColor(Color.Black)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .size({ width: '100%', height: '100%' })
      .padding({
        top: FUSafeAreaUtil.getStatusBarHeight(),
        bottom: FUSafeAreaUtil.getBottomBarHeight()
      })
    }
  }
}

