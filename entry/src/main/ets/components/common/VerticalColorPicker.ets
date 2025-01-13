@Component
export struct VerticalColorPicker {
  @Require @Prop @Watch('onPropertyDidChange') selectedIndex_from: number; // 当前选中的颜色索引
  @Require @Prop @Watch('onPropertyDidChange') colorList: string[][]; // 接收颜色数组
  @State private tempColorList: string[][] = [] // 真正用来渲染的数据源
  private onCircleIndex: number = 0 // 滚动过程中赋值，UI 上圈中的元素下标
  private selectedIndex: number = 0; // 当前选中的颜色索引
  @State private itemScales: string[] = [];  //动态计算的每个子视图的缩放比例
  private readonly itemWidth = 40
  private readonly itemSpace = 6
  private readonly listHeight = 5 * this.itemWidth + 4 * this.itemSpace; // List 的高度
  private scroller: Scroller = new Scroller();
  // 点击回调
  @Require onSelectColor: ((color: string[], index: number) => void) = () => {
  }

  onPropertyDidChange(properTyName: string) {
    if (properTyName === 'selectedIndex_from') {
      if (this.selectedIndex_from === this.selectedIndex) {
        return
      }
    }

    if (properTyName === 'selectedIndex_from' || properTyName === 'colorList' || properTyName === 'aboutToAppear') {
      // 前后各两个占位符
      this.tempColorList = [[], [], ...this.colorList, [], []]
      this.selectedIndex = this.selectedIndex_from
      // 数据源变更后，重新计算每个 item 的缩放比例，scrollToIndex 会触发 offset 变化，滚动过程会动态计算
      this.calculateScaleForItem()
      // 延迟执行以确认 list 已渲染
      if (properTyName === 'aboutToAppear') {
        setTimeout(() => {
          this.scroller.scrollToIndex(this.selectedIndex, true)
        }, 30)
      } else {
        this.scroller.scrollToIndex(this.selectedIndex, false)
      }
    }
  }

  aboutToAppear(): void {
    this.onPropertyDidChange('aboutToAppear')
  }

  // 计算每个 ColorPickerItem 的缩放比例
  calculateScaleForItem() {
    const currentOffsetY = this.scroller.currentOffset()?.yOffset || 0
    const centerOffset = this.listHeight / 2; // 滚动视图的中心位置
    const itemOffsets: number[] = [];
    for (let index = 0; index < this.tempColorList.length; index++) {
      const itemCenter =
        index * (this.itemWidth + this.itemSpace) + (this.itemWidth + this.itemSpace) / 2; // 计算每个项的中心位置
      const distanceFromCenter =
        Math.abs((currentOffsetY + centerOffset) - itemCenter); // 每个项距离视图中心的距离
      itemOffsets.push(distanceFromCenter);
    }

    // 计算缩放比例，距离中心越近，比例越大
    this.itemScales = itemOffsets.map((distance) => {
      const maxDistance = this.listHeight / 2;
      const scale = Math.max(0.3, 1 - (distance / maxDistance)); // 缩放比例介于 0.3 和 1 之间
      return `${scale * 100}%`; // 将比例转换为百分比字符串
    });
  }

  build() {
    RelativeContainer() {
      List({ space: this.itemSpace, scroller: this.scroller }) {
        ForEach(this.tempColorList, (colors: string[], index: number) => {
          ListItem() {
            ColorPickerItem({
              scaleValue: this.itemScales[index],
              colors: colors
            })
              .width(this.itemWidth)
              .height(this.itemWidth)
              .onClick(() => {
                if (colors.length) {
                  // 滚动会触发 onScrollIndex
                  this.scroller.scrollToIndex(index - 2, true)
                }
              })
          }
        }, (item: string[], index) => `${item}_${index}`);
      }
      .id('__List__')
      .size({ width: '100%', height: '100%' })
      .scrollBar(BarState.Off)
      .alignListItem(ListItemAlign.Center)
      .onDidScroll((_scrollOffset: number, _scrollState: ScrollState) => {
        this.calculateScaleForItem()
      })
      .onScrollIndex((_start: number, _end: number, center: number) => {
        // 滚动时会不断回调，当前显示的三个位置的元素下标，center 即为视图圈中的位置
        this.onCircleIndex = center

        // 滚动过程色值变化回调
        if(this.selectedIndex !== this.onCircleIndex - 2) {
          this.selectedIndex = this.onCircleIndex - 2
          this.onSelectColor(this.colorList[this.selectedIndex], this.selectedIndex)
        }
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Up) {
          // 滚动到距离最近的 item 位置，scrollToIndex 对应 onScrollIndex 的 _start 位置
          this.scroller.scrollToIndex(this.onCircleIndex - 2, true)
        }
      })

      // 圆框标记当前选中颜色
      Circle()
        .id('__Circle__')
        .alignRules({
          center: { anchor: '__List__', align: VerticalAlign.Center },
          middle: { anchor: '__List__', align: HorizontalAlign.Center }
        })
        .width('100%')
        .aspectRatio(1)
        .backgroundColor(Color.Transparent)
        .fill(Color.Transparent)
        .stroke(Color.White)
        .strokeWidth(4)
        .hitTestBehavior(HitTestMode.None)
    }
    .height(this.listHeight)
    .width(this.itemWidth)
  }
}

@Component
struct ColorPickerItem {
  @Require @Prop scaleValue: string
  @Require @Prop colors: string[];

  build() {
    RelativeContainer() {
      // 用来定位组件，不会显示出来
      Row()
        .id('__Row__')
        .backgroundColor(Color.Transparent)
        .width('100%')
        .height('100%')

      if (this.colors.length === 1) {
        Circle()
          .id('__Circle_0__')
          .alignRules({
            center: { 'anchor': '__Row__', align: VerticalAlign.Center },
            middle: { 'anchor': '__Row__', align: HorizontalAlign.Center }
          })
          .width(this.scaleValue)
          .height(this.scaleValue)
          .fill(this.colors[0])
      }
      if (this.colors.length === 2) {
        /*
         * 子视图上下布局，width: 100% ，height：50%
         * Column 的 width/height 变化时，子视图通过 % 设置 size 自动响应父视图的 size 变化
         */
        Column() {
          ForEach(this.colors, (color: string) => {
            Rect()
              .fill(color)
              .width('100%')
              .height('50%')
          })
        }
        .id('__Column_2__')
        .alignRules({
          center: { 'anchor': '__Row__', align: VerticalAlign.Center },
          middle: { 'anchor': '__Row__', align: HorizontalAlign.Center }
        })
        .width(this.scaleValue)
        .height(this.scaleValue)
        .borderRadius('200%') // 为什么是 200% ？ 当 width 和 height 变化时，borderRadius 如果设置了 50%，并不会实时计算 50%，而是以初始化 size 计算的
        .clip(true)
      }
      if (this.colors.length === 3) {
        Column() {
          ForEach(this.colors, (color: string) => {
            Rect()
              .fill(color)
              .width('100%')
              .height('33.33%')
          })
        }
        .id('__Column_3__')
        .alignRules({
          center: { 'anchor': '__Row__', align: VerticalAlign.Center },
          middle: { 'anchor': '__Row__', align: HorizontalAlign.Center }
        })
        .width(this.scaleValue)
        .height(this.scaleValue)
        .borderRadius('200%')
        .clip(true)
      }
      if (this.colors.length === 4) {
        Flex({
          wrap: FlexWrap.Wrap,
          justifyContent: FlexAlign.Start,
        }) {
          ForEach(this.colors, (color: string, _index: number) => {
            Rect()
              .fill(color)
              .width('50%')
              .height('50%')
          })
        }
        .id('__Flex_4__')
        .alignRules({
          center: { 'anchor': '__Row__', align: VerticalAlign.Center },
          middle: { 'anchor': '__Row__', align: HorizontalAlign.Center }
        })
        .width(this.scaleValue)
        .height(this.scaleValue)
        .borderRadius('200%')
        .clip(true)
      }
    }
  }
}