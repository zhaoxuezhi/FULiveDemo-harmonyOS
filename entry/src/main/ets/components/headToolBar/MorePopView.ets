import { ViewFrame } from '../floatComponent/FPSFloatView'
import { RenderType, ResolutionValues } from './FUHeadToolBar'

@Component
export struct MorePopView {
  @Prop resolutionValue: ResolutionValues
  onItemClick: ((type: RenderType, value: ResolutionValues | undefined) => void) | undefined
  // 触发 MorePopView 显示的组件相对于屏幕的 frame
  @Require triggerViewFrame: ViewFrame = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }
  @State globalPositionX: number = 0

  @Styles
  getSelfFrame() {
    .onAreaChange((_: Area, newArea: Area) => {
      this.globalPositionX = newArea.globalPosition.x as number
    })
  }

  @Builder
  renderResolutionView() {
    Row() {
      ForEach(["480×640", "720×1280", "1080×1920"],
        (item: string) => {
          Text(item)
            .backgroundColor(this.resolutionValue === item ? Color.White : Color.Transparent)
            .fontColor(this.resolutionValue === item ? '0x2C2E30' : Color.White)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .padding({
              top: 8,
              bottom: 8,
            })
            .width('33.3%')
            .onClick(() => {
              this.resolutionValue = item as "480×640" | "720×1280" | "1080×1920"
              this.onItemClick?.(RenderType.RenderType_Resolution, this.resolutionValue)
            })
        },
      )
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(4)
    .borderWidth(1.5)
    .borderColor(Color.White)
  }

  build() {
    Column() {
      Row() {
        Polygon({ width: 24, height: 14 })
          .points([[12, 0], [0, 14], [24, 14]])
          .fill('#74555555')
          .position({
            // 触发弹窗视图相对于屏幕的坐标 - self 相对于屏幕的坐标 - 微调
            x: this.triggerViewFrame.x - this.globalPositionX - 15
          })
      }
      .width('100%')
      .height(14)

      Column() {
        this.renderResolutionView()
        Divider()
          .margin({ top: 15, bottom: 15 })
        Row() {
          // Text('载入图片或视频')
          Text('载入图片')
            .fontSize(13)
            .fontColor(Color.White)
          Image($rawfile('common/render_select_media@2x.png'))
            .width(7)
            .height(13)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          this.onItemClick?.(RenderType.RenderType_Picture, undefined)
        })
      }
      .padding(15)
      .backgroundColor('#74555555')
      .borderRadius(5)
      .onClick(() => {})
    }
    .padding({ left: 20 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .getSelfFrame()
  }
}