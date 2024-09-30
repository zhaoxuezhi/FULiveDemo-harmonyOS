import { FUBackButtonRow } from '../components/common/FUBackButton';
import { RouterParamsModel } from '../router/RouterModel';
import FUSafeAreaUtil from '../utils/FUSafeAreaUtil';
import { requestMediaPermission } from '../utils/RequestPermission';
import { AssetsType, requestAssets } from '../utils/AssetsUtil';

interface IPOP {
  from: string
}

interface ButtonItem {
  type: AssetsType
  img: ResourceStr
  title: string
}

@Builder
export function PageBuilder(name: string, param: RouterParamsModel | undefined) {
  SelectLocalMediaPage({ routerParams: param })
}

@Component
export struct SelectLocalMediaPage {
  @Consume('pathInfos') pageInfos: NavPathStack
  private routerParams: RouterParamsModel | undefined

  aboutToAppear() {
    //TODO: 解析路由参数
    console.log(`from: ${(this.routerParams?.params as IPOP).from}`)
  }

  @Builder
  buttonItem(item: ButtonItem) {
    Row() {
      Image(item.img)
        .size({ width: 26, height: 25 })
        .objectFit(ImageFit.Contain)
      Text(item.title)
        .fontColor(Color.White)
        .fontSize(15)
        .margin({ left: 10 })
    }
    .size({ width: 235, height: 48 })
    .borderRadius(24)
    .backgroundImage($rawfile('pickerImage/media_picker_button_background@2x.png'))
    .backgroundImageSize({ width: 235, height: 48 })
    .justifyContent(FlexAlign.Center)
    .onClick(async () => {
      //TODO: 点击调用本地相册
      const res = await requestMediaPermission()
      if (res) {
        const assetData = await requestAssets({ type: item.type, onlyUri: false, compress: true })
        if (!assetData?.uri) {
          return
        }
        const routerParams: RouterParamsModel = {
          params: Object({ 'from': 'SelectLocalMediaPage', assetData })
        }
        // TODO：将选择的相册资源回传到对应的功能页面(待完善视频)
        //this.pageInfos.pop(routerParams)
        this.pageInfos.pushPath({ name: 'ImageRenderPage', param: routerParams })
      }
    })
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        Row() {
          FUBackButtonRow()
        }
        .id('__FUBackButtonRow__')

        Column({ space: 40 }) {
          // Text('请从相册选择图片或视频')
          Text('请从相册选择图片')
            .fontColor(Color.White)
            .margin({ bottom: 20 })

          this.buttonItem({
            type: 'photo',
            img: $rawfile('pickerImage/media_picker_image_selection@2x.png'),
            title: '选择图片'
          })
          // TODO: 1.0.0版本暂时不支持视频解析，UI先不支持选择视频
          // this.buttonItem({
          //   type: 'video',
          //   img: $rawfile('pickerImage/media_picker_video_selection@2x.png'),
          //   title: '选择视频'
          // })
        }
        .id('__mainView__')
        .alignRules({
          top: {
            anchor: '__FUBackButtonRow__',
            align: VerticalAlign.Bottom
          },
          bottom: {
            anchor: '__container__',
            align: VerticalAlign.Bottom
          }
        })
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      .backgroundColor(Color.Black)
      .padding({
        top: FUSafeAreaUtil.getStatusBarHeight(),
        bottom: FUSafeAreaUtil.getBottomBarHeight()
      })
    }
    .hideTitleBar(true)
  }
}
