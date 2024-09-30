import { PixelBufferValues } from './FUHeadToolBar'

@Component
export struct PixelBufferView {
  @State selectValue: PixelBufferValues = 'BGRA'
  itemOnClick: ((value: PixelBufferValues) => void) | undefined = undefined

  build() {
    Row() {
      ForEach(["BGRA", "YUV"],
        (item: string) => {
          Text(item)
            .backgroundColor(this.selectValue === item ? Color.White : Color.Transparent)
            .fontColor(this.selectValue === item ? '0x2C2E30' : Color.White)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .padding(3)
        },
      )
    }
    .borderRadius(4)
    .borderWidth(1.5)
    .borderColor(Color.White)
    .onClick(() => {
      this.selectValue = this.selectValue === 'BGRA' ? 'YUV' : 'BGRA'
      this.itemOnClick?.(this.selectValue)
    })
  }
}