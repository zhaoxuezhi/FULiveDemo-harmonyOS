export interface HorizontalScrollViewItemInterface {
  id: string;
  imageUrl?: ResourceStr
  imgBgColor?: string
  label?: string
}

interface ItemViewInterface {
  item: HorizontalScrollViewItemInterface;
  index?: number;
  isSelected?: boolean;
  onClick: (item: HorizontalScrollViewItemInterface) => void;
}

interface HorizontalScrollViewFrames {
  imgWidth: number
}

export enum HorizontalScrollViewShowType {
  Round,
  Rectangle
}

@Component
export struct HorizontalScrollView {
  // 当前选中
  @Link selectedItem: HorizontalScrollViewItemInterface
  // 样式
  viewShowType: HorizontalScrollViewShowType = HorizontalScrollViewShowType.Round
  // 是否显示标题
  showTitle: boolean = false
  // Item 之间的间距
  itemSpace: number = 8
  // 数据源
  @Prop items: HorizontalScrollViewItemInterface[] = []
  // frame 定义
  private frames: HorizontalScrollViewFrames = { imgWidth: 60 }

  build() {
    List({ space: this.itemSpace }) {
      ForEach(this.items, (item: HorizontalScrollViewItemInterface, index: number) => {
        ListItem() {
          this.ItemView({
            item: item,
            isSelected: this.selectedItem.id === item.id,
            onClick: (item: HorizontalScrollViewItemInterface): void => {
              this.selectedItem = item
            }
          })
        }
      }, (item: HorizontalScrollViewItemInterface, index: number) => {
        // 为了避免每次选择后，整个列表重新渲染，key 添加选中状态，key 是动态的，否则无法触发重新渲染
        const key = item.id + '-' + (this.selectedItem.id === item.id ? '1' : '0')
        return key
      })
    }
    .alignListItem(ListItemAlign.Start)
    .height(this.showTitle ? this.frames.imgWidth + 25 : this.frames.imgWidth)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  ItemView(props: ItemViewInterface) {
    RelativeContainer() {
      Image(props.item.imageUrl)
        .width(this.frames.imgWidth)
        .height(this.frames.imgWidth)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.viewShowType == HorizontalScrollViewShowType.Round ? this.frames.imgWidth / 2 : 4)
        .backgroundColor(props.item.imgBgColor)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .id('Image')

      if (props.isSelected) {
        if (this.viewShowType == HorizontalScrollViewShowType.Round) {
          Circle()
            .width(this.frames.imgWidth - 4)
            .height(this.frames.imgWidth - 4)
            .stroke('#5ec7fe')
            .strokeWidth(4)
            .fill(Color.Transparent)
            .alignRules({
              middle: { anchor: 'Image', align: HorizontalAlign.Center },
              center: { anchor: 'Image', align: VerticalAlign.Center }
            })
            .id('CircleBorder')
        } else {
          Rect()
            .width(this.frames.imgWidth - 4)
            .height(this.frames.imgWidth - 4)
            .radius(2)
            .stroke('#5ec7fe')
            .strokeWidth(4)
            .fill(Color.Transparent)
            .alignRules({
              middle: { anchor: 'Image', align: HorizontalAlign.Center },
              center: { anchor: 'Image', align: VerticalAlign.Center }
            })
            .id('RectBorder')
        }
      }
      if (this.showTitle) {
        Text(props.item.label)
          .fontSize(11)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .alignRules({
            middle: { anchor: 'Image', align: HorizontalAlign.Center },
            top: { anchor: 'Image', align: VerticalAlign.Bottom }
          })
          .offset({ y: 6 })
          .id('Title')
      }
    }
    .width(this.frames.imgWidth)
    .height('100%')
    .onClick(() => props.onClick(props.item))
  }
}
