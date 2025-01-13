@Component
export struct SelectSegmentModeView {
  @Require onGeneralClick?: () => void
  @Require onMeetingClick?: () => void

  build() {
    Column() {
      Button('通用分割版')
        .backgroundColor(Color.White)
        .fontColor(Color.Black)
        .fontSize(14)
        .borderRadius(8)
        .width('60%')
        .height(44)
        .onClick(() => {
          this.onGeneralClick?.();
        })
      Blank()
        .height(30)
      Button('视频会议版')
        .backgroundColor(Color.White)
        .fontColor(Color.Black)
        .fontSize(14)
        .borderRadius(8)
        .width('60%')
        .height(44)
        .onClick(() => {
          this.onMeetingClick?.();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#88000000')
    .justifyContent(FlexAlign.Center)
  }
}