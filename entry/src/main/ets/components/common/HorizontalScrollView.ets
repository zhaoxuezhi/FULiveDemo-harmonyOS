import { AssetsUtil } from '../../utils/AssetsUtil';
import { ThrottleManager } from '../../utils/ThrottleManager';

export interface HorizontalScrollViewItemInterface {
  id: string;
  imageUrl?: ResourceStr
  sandboxImageUrl?: string
  imgBgColor?: string
  label?: string
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
  // 外部传入的选中
  @Require @Prop @Watch('propertyDidChange') selectIndex_from: number
  // 样式
  viewShowType: HorizontalScrollViewShowType = HorizontalScrollViewShowType.Round
  // 是否显示标题
  showTitle: boolean = false
  // Item 之间的间距
  itemSpace: number = 8
  // 数据源
  @Prop items: HorizontalScrollViewItemInterface[] = []
  // 当前选中
  @State private selectIndex: number = 0
  // frame 定义
  frames: HorizontalScrollViewFrames = { imgWidth: 60 }
  private scroller: Scroller = new Scroller();
  // 是否点击触发的选中
  private isClickTriggerSelect: boolean = false
  // 节流
  private throttleClick: ThrottleManager | undefined
  // 是否可被选中
  shouldSelect: ((item: HorizontalScrollViewItemInterface, index: number) => boolean) = () => {
    return true
  }
  // 点击回调
  @Require onItemClick: ((item: HorizontalScrollViewItemInterface, index: number) => void) = () => {
  }

  aboutToAppear(): void {
    this.selectIndex = this.selectIndex_from
    setTimeout(() => {
      this.scroller.scrollToIndex(this.selectIndex > 3 ? this.selectIndex : 0)
    }, 100)
    // 防抖实现
    this.throttleClick = new ThrottleManager({
      callback: () => {
        this.onItemClick(this.items[this.selectIndex], this.selectIndex)
      },
      delay: 400, // 节流时长 ms
      leading: true, // 首次点击立即触发
      trailing: true  // 结束时触发最后一次
    })
  }

  propertyDidChange(propertyName: string) {
    console.info('[HorizontalScrollView] propertyDidChange:', propertyName)
    if (propertyName === 'selectIndex_from') {
      if (this.selectIndex !== this.selectIndex_from) {
        this.selectIndex = this.selectIndex_from
        if (this.isClickTriggerSelect === false) {
          // 如果是当前组件快速点击引起的 selectIndex 和 selectIndex_from 不同，不需要滚动定位
          this.scroller.scrollToIndex(this.selectIndex > 3 ? this.selectIndex : 0)
        }
      }
    }
    this.isClickTriggerSelect = false
  }

  build() {
    List({ space: this.itemSpace, scroller: this.scroller }) {
      ForEach(this.items, (item: HorizontalScrollViewItemInterface, index: number) => {
        ListItem() {
          ScrollItemView({
            imageWidth: this.frames.imgWidth,
            isSelected: this.selectIndex === index,
            item: item,
            viewShowType: this.viewShowType,
            showTitle: this.showTitle,
            onItemClick: () => {
              if (this.shouldSelect?.(item, index)) {
                this.isClickTriggerSelect = true
                this.selectIndex = index
                // 执行节流函数
                this.throttleClick!.execute()
              }
            }
          })
        }
      }, (item: HorizontalScrollViewItemInterface, index: number) => {
        // 为了避免每次选择后，整个列表重新渲染，key 添加选中状态，key 是动态的，否则无法触发重新渲染
        const key = item.id + '-' + (this.selectIndex === index ? '1' : '0')
        return key
      })
    }
    .alignListItem(ListItemAlign.Start)
    .height(this.showTitle ? this.frames.imgWidth + 25 : this.frames.imgWidth)
    .width('100%')
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .padding({ left: 12, right: 12 })
  }
}

@Component
struct ScrollItemView {
  @Require @Prop @Watch('propertyDidChange') item: HorizontalScrollViewItemInterface
  @Require @Prop isSelected: boolean
  viewShowType: HorizontalScrollViewShowType = HorizontalScrollViewShowType.Round
  showTitle: boolean = false
  @Require imageWidth: number = 60
  @State pixelMap: PixelMap | undefined = undefined;
  @Require onItemClick: (item: HorizontalScrollViewItemInterface) => void = () => {
  };

  aboutToAppear() {
    this.propertyDidChange('item')
  }

  aboutToDisappear(): void {
    this.pixelMap?.release()
  }

  async propertyDidChange(propertyName: string) {
    console.info('[ScrollItemView] propertyDidChange:', propertyName)
    if (propertyName === 'item') {
      console.info('[ScrollItemView] propertyDidChange:', JSON.stringify(this.item))
      if (this.item.sandboxImageUrl) {
        this.pixelMap = await AssetsUtil.loadPixelMapFromSandbox(this.item.sandboxImageUrl)
      }
    }
  }

  build() {
    RelativeContainer() {
      Image(this.pixelMap || this.item.imageUrl)
        .width(this.imageWidth)
        .height(this.imageWidth)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.viewShowType == HorizontalScrollViewShowType.Round ? this.imageWidth / 2 : 4)
        .backgroundColor(this.item.imgBgColor)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .id('Image')

      if (this.isSelected) {
        if (this.viewShowType == HorizontalScrollViewShowType.Round) {
          Circle()
            .width(this.imageWidth - 4)
            .height(this.imageWidth - 4)
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
            .width(this.imageWidth - 4)
            .height(this.imageWidth - 4)
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
        Text(this.item.label)
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
    .width(this.imageWidth)
    .height('100%')
    .onClick(() => {
      this.onItemClick(this.item)
    })
  }
}