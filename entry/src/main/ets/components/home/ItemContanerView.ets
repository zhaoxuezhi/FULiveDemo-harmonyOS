import { configData, HomeItem, HomeItemGroup } from './DataConfig'

@Component
export struct ItemContainerView {
  @Require onItemClick: ((item: HomeItem) => void) | undefined = undefined
  @State groups: HomeItemGroup[] = []

  aboutToAppear(): void {
    this.groups = configData.map((group: HomeItemGroup): HomeItemGroup => {
      const newGroup: HomeItemGroup = {
        label: group.label,
        style: group.style,
        items: group.items.filter(item => item.enabled === true)
      } as HomeItemGroup
      return newGroup
    }).filter(group => group.items.length > 0)
  }

  build() {
    Scroll() {
      Column() {
        Image($r('app.media.headerBg'))
          .width('100%')
          .height('30%')
        ForEach(this.groups, (group: HomeItemGroup) => {
          Column() {
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
          .margin(10)
        })
      }
    }
    .width('100%')
    .edgeEffect(EdgeEffect.Spring)
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
    .padding(8)
    .onClick(() => {
      this.onItemClick?.(item)
    })
  }
}

