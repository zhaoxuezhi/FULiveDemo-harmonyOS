import { FUBackButtonRow } from '../components/common/FUBackButton';
import { RouterParamsModel } from '../router/RouterModel';
import FUSafeAreaUtil from '../utils/FUSafeAreaUtil';
import { AssetsDataInterface } from '../utils/AssetsUtil';

interface IPOP {
  from?: string
  assetsInterface?: AssetsDataInterface
}

@Builder
export function PageBuilder(name: string, param: RouterParamsModel | undefined) {
  AssetsPreView({ routerParams: param })
}

@Component
export struct AssetsPreView {
  routerParams: RouterParamsModel | undefined
  @State assetData: AssetsDataInterface | undefined = undefined

  aboutToAppear() {
    this.assetData = Object(this.routerParams?.params)?.assetData as AssetsDataInterface
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        if (this.assetData?.type === 'photo') {
          Image(this.assetData.thumbnail)
            .id('Image')
            .size({ width: '100%', height: '100%' })
            .objectFit(ImageFit.Contain)
        }

        if (this.assetData?.type === 'video') {
          Video({ src: this.assetData.uri, previewUri: this.assetData.thumbnail })
            .id('__video__')
            .size({ width: '100%', height: '100%' })
            .objectFit(ImageFit.Contain)
        }

        Row() {
          FUBackButtonRow()
        }
        .id('__FUBackButtonRow__')
        .margin({ top: FUSafeAreaUtil.getStatusBarHeight() })

        Text(JSON.stringify(this.assetData))
          .id('text')
          .fontColor(Color.White)
          .fontSize(13)
          .width('100%')
          .alignRules({
            top: {
              anchor: '__FUBackButtonRow__',
              align: VerticalAlign.Bottom
            }
          })
          .padding(20)
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Black)
  }
}
