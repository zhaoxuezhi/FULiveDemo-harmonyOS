@Component
export struct ExportVideoView {
  @Consume progressValue: number;
  clickCancel: (() => void) | undefined = undefined;

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Progress({ value: this.progressValue, total: 100, type: ProgressType.Ring })
          .id('__Progress__')
          .alignRules({
            top: { anchor: "__Image__", align: VerticalAlign.Top },
            bottom: { anchor: "__Image__", align: VerticalAlign.Bottom },
            left: { anchor: "__Image__", align: HorizontalAlign.Start },
            right: { anchor: "__Image__", align: HorizontalAlign.End },
          })
          .color('#5ec7fe')
          .style({
            strokeWidth: 5
          })

        Text(`${this.progressValue}%`)
          .fontColor(Color.White)
          .font({size: 20})
          .textAlign(TextAlign.Center)
          .width('100%')
          .height(40)
      }

      Text('正在努力导出视频，请不要退出应用或锁屏')
        .fontColor(Color.White)
        .font({size: 14})
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(40)
        .margin({ top: 10 })

      Button('取消')
        .fontColor(Color.White)
        .borderWidth(1)
        .borderColor(Color.White)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.clickCancel) {
            this.clickCancel();
          }
        })
        .size({
          width: 100,
          height: 30
        })
        .margin({ top: 10 })
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#80000000')
    .width('100%')
    .height('100%')
  }
}