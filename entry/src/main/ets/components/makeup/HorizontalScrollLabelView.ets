export interface HorizontalScrollLabelViewInterface {
  id: string
  label: string
  showBadge: boolean
}

@Component
export struct HorizontalScrollLabelView {
  // 当前选中
  @Require @Prop @Watch('propertyDidChange') selectIndex_from: number
  // Item 之间的间距
  itemSpace: number = 16
  // 数据源
  @Require @Prop items: HorizontalScrollLabelViewInterface[] = []
  @State private selectIndex: number = 0
  // 点击回调
  @Require onItemClick: ((item: HorizontalScrollLabelViewInterface, index: number) => void) = () => {
  }
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.selectIndex = this.selectIndex_from
    setTimeout(() => {
      this.scroller.scrollToIndex(this.selectIndex > 4 ? this.selectIndex : 0)
    }, 100)
  }

  propertyDidChange(propertyName: string) {
    if (propertyName === 'selectIndex_from') {
      if (this.selectIndex !== this.selectIndex_from) {
        this.selectIndex = this.selectIndex_from
        setTimeout(() => {
          this.scroller.scrollToIndex(this.selectIndex > 4 ? this.selectIndex : 0)
        }, 100)
      }
    }
  }

  build() {
    List({ space: this.itemSpace, scroller: this.scroller }) {
      ForEach(this.items, (item: HorizontalScrollLabelViewInterface, index: number) => {
        ListItem() {
          this.ItemView(item, index)
        }
      }, (item: HorizontalScrollLabelViewInterface, index: number) => {
        // 为了避免每次选择后，整个列表重新渲染，key 添加选中状态，key 是动态的，否则无法触发重新渲染
        const key = item.id + '-' + (this.selectIndex === index ? '1' : '0') + '-' + (item.showBadge ? '1' : '0')
        return key
      })
    }
    .alignListItem(ListItemAlign.Start)
    .height('100%')
    .width('100%')
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  ItemView(item: HorizontalScrollLabelViewInterface, index: number) {
    RelativeContainer() {
      Text(item.label)
        .fontSize(11)
        .fontColor(index === this.selectIndex ? '#5ec7fe' : Color.White)
        .textAlign(TextAlign.Center)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .id('Title')

      if (item.showBadge) {
        Circle()
          .size({ width: 4, height: 4 })
          .fill('#5ec7fe')
          .alignRules({
            right: { anchor: 'Title', align: HorizontalAlign.End },
            top: { anchor: 'Title', align: VerticalAlign.Top }
          })
          .offset({ right: -8, top: -8 })
          .id('Badge')
      }
    }
    .width(50)
    .onClick(() => {
      this.selectIndex = index
      this.onItemClick(item, index)
    })
  }
}
