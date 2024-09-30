import { configData, HomeItem, HomeItemGroup } from './DataConfig'

@Component
export struct ItemContainerView {
  // @Consume('pathInfos') pathInfos: NavPathStack

  @Require onItemClick : ((item : HomeItem) => void) | undefined = undefined

  private configData: HomeItemGroup[] = configData

  build() {
    Column({ space: 20 }) {
      ForEach(this.configData, (group: HomeItemGroup) => {
        Column({ space: 10 }) {
          Row() {
            Blank()
              .backgroundColor('#8824c4')
              .size({ width: 4, height: 20 })
              .borderRadius(2)
              .margin({ right: 10 })
            Text(group.label)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')

          if (group.style === '1x3') {
            Flex({
              wrap: FlexWrap.Wrap,
              justifyContent: FlexAlign.Start,
            }) {
              ForEach(group.items, (item: HomeItem) => {
                this.GridItem(item, 3)
              })
            }
          } else {
            ForEach(group.items, (item: HomeItem) => {
              this.GridItem(item, 1)
            })
          }
        }
      })
    }
    .width('100%')
    .padding(10)
  }

  @Builder
  GridItem(item: HomeItem, columns: number) {
    Stack() {
      if (columns == 1) {
        Image($rawfile('home/bg_jingpintiezhi@2x.png'))
          .size({ width: '100%', height: '100%' })
          .objectFit(ImageFit.Cover)
      }
      Column() {
        Blank()
          .layoutWeight(1)

        Image(item.img)
          .objectFit(ImageFit.Contain)
          .height(columns == 3 ? '30%' : '75%')
          .width('100%')

        Blank()
          .layoutWeight(1)

        Stack({ alignContent: Alignment.Bottom }) {
          Image($r('app.media.bottomImage'))
          Text(item.label)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .padding({ bottom: 3 })
        }
        .alignContent(Alignment.Center)
        .width('100%')
        .height('25%')
      }
      .backgroundColor(columns == 3 ? '#1F1D35' : null)
      .justifyContent(FlexAlign.SpaceBetween)
      .clip(true)
      .borderRadius(15)
      .size({ width: '100%', height: '100%' })
    }
    .width(columns === 3 ? '33%' : '100%')
    .height(140)
    .padding(10)
    .onClick(() => {
      // this.pathInfos.pushPath({ name: item.label })
      // this.pathInfos.pushPath({ name: 'BeautyPage' })
      this.onItemClick?.(item)
    })
  }
}

