import { PixelBufferView } from './PixelBufferView';
import { MorePopView } from './MorePopView';
import { FPSFloatView, ViewFrame } from '../floatComponent/FPSFloatView';
import { HeadToolBarController } from './HeadToolBarController';

export enum RenderType {
  RenderType_Home,
  RenderType_Bugly,
  RenderType_CameraSwitch,
  RenderType_More,
  RenderType_PixelBuffer,
  RenderType_Resolution,
  RenderType_Picture
}

export type ResolutionValues = "480×640" | "720×1280" | "1080×1920"

export type PixelBufferValues = 'BGRA' | 'YUV'


const ImageMap: Map<RenderType, ResourceStr> = new Map([
  [RenderType.RenderType_Home, $rawfile('common/render_back_home@2x.png')],
  [RenderType.RenderType_Bugly, $rawfile('common/render_bugly@2x.png')],
  [RenderType.RenderType_CameraSwitch, $rawfile('common/render_camera_switch@2x.png')],
  [RenderType.RenderType_More, $rawfile('common/render_more@2x.png')],
  [RenderType.RenderType_Picture, $rawfile('common/render_picture@2x.png')]
]);

// 组件的封装
@Component
export struct FUHeadToolBar {
  @Consume('pathInfos') pathInfos: NavPathStack
  @Prop leftRenderTypes: RenderType[];
  @Prop rightRenderTypes: RenderType[];
  @State showMorePopView: boolean = false
  @State showFpsView: boolean = false
  @State resolutionValue: ResolutionValues = '720×1280'
  controller: HeadToolBarController = new HeadToolBarController();
  itemRelateWindowFrame: ViewFrame | undefined
  itemOnClick: ((type: RenderType, value: ResolutionValues | PixelBufferValues | undefined) => void) | undefined

  aboutToAppear(): void {
    if (this.controller) {
      this.controller.onScreenTopAction = () => {
        if (this.showMorePopView) {
          this.showMorePopView = false
        }
      }
      this.controller.morePopViewIsShowing = (): boolean => {
        return this.showMorePopView
      }
    }
  }

  // 处理点击事件
  handleClick(event: ClickEvent, renderType: RenderType) {
    if (this.showMorePopView) {
      this.showMorePopView = false;
      return
    }
    if (renderType == RenderType.RenderType_Bugly) {
      this.showFpsView = !this.showFpsView
    } else if (renderType == RenderType.RenderType_Home) {
      this.pathInfos.pop()
    } else if (renderType == RenderType.RenderType_More) {
      this.itemRelateWindowFrame = {
        x: Number(event.target.area.globalPosition.x || 0),
        y: Number(event.target.area.globalPosition.y || 0),
        width: Number(event.target.area.width),
        height: Number(event.target.area.height)
      }
      this.showMorePopView = !this.showMorePopView
    } else {
      this.itemOnClick?.(renderType, undefined)
    }
  }

  @Builder
  renderToolItemView() {
    Row() {
      // 左边组件
      ForEach(this.leftRenderTypes, (item: RenderType) => {
        if (item == RenderType.RenderType_PixelBuffer) {
          PixelBufferView({
            selectValue: 'YUV',
            itemOnClick: (value: PixelBufferValues) => {
              if (this.showMorePopView) {
                this.showMorePopView = false;
              }
              this.itemOnClick?.(item, value)
            }
          })
        } else {
          Image(ImageMap.get(item))
            .width(33)
            .height(33)
            .margin({ right: 20 })
            .objectFit(ImageFit.Contain)
            .onClick((event: ClickEvent) => {
              this.handleClick(event, item)
            })
        }
      },
        (item: RenderType) => item.toString()
      )

      // 占位符
      Blank()
        .layoutWeight(1)

      // 右边组件
      ForEach(this.rightRenderTypes, (item: RenderType, index: number) => {
        FUHeadToolBarRightItem({
          imageResource: ImageMap.get(item),
          rightMargin: index < (this.rightRenderTypes.length - 1) ? 20 : 0,
          type: item,
          onClickCB: (event: ClickEvent, renderType: RenderType) => {
            this.handleClick(event, renderType)
          }
        })
      }, (item: RenderType) => item.toString())
    }
    .alignItems(VerticalAlign.Center)
    .padding({ left: 10, right: 10 })
    .width('100%')
  }

  build() {
    Column() {
      this.renderToolItemView()
      Stack() {
        if (this.showFpsView) {
          FPSFloatView()
            .padding({ left: 15, top: 10 })
            .width('100%')
            .height(100)
        }
        if (this.showMorePopView) {
          // 内部有坐标计算 itemRelateWindowFrame 以window坐标来计算的
          MorePopView({
            resolutionValue: this.resolutionValue,
            triggerViewFrame: this.itemRelateWindowFrame,
            onItemClick: (type: RenderType, value: ResolutionValues | undefined) => {
              if (type === RenderType.RenderType_Resolution) {
                this.resolutionValue = value as ResolutionValues
              }
              this.itemOnClick?.(type, value)
            }
          })
            .width('80%')
            .margin({ top: 5 })
        }
      }
      .alignContent(Alignment.TopStart)
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct FUHeadToolBarRightItem {
  imageResource: ResourceStr = '';
  rightMargin = 0;
  type: RenderType = RenderType.RenderType_Home;
  onClickCB: ((event: ClickEvent, renderType: RenderType) => void) | undefined = undefined;
  @State enableValue: boolean = true;

  build() {
    Image(this.imageResource)
      .width(33)
      .height(33)
      .margin({ right: this.rightMargin })
      .objectFit(ImageFit.Contain)
      .enabled(this.enableValue)
      .onClick((event: ClickEvent) => {
        if (this.type === RenderType.RenderType_CameraSwitch) {
          this.enableValue = false;
          setTimeout(() => {
            this.enableValue = true;
          }, 1000);
        }
        if (this.onClickCB) {
          this.onClickCB(event, this.type)
        }
      })
  }
}
