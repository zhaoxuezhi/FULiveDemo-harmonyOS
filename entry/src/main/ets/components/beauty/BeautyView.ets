import { BeautyFilterView } from '../../components/beauty/BeautyFilterView';
import { BeautyShapeView } from '../../components/beauty/BeautyShapeView';
import { BeautySkinView } from '../../components/beauty/BeautySkinView';
import { SELECTCOLOR } from '../../constants/Constants';
import { RenderKitService } from '../../service/RenderKitService';
import { SaveScreenshotCallBack } from '../../utils/CallBack';
import { CaptureButton } from '../common/CaptureButton';

enum FUBeautyType {
  Skin,
  Shape,
  Filter,
  unkown
}

const animateParam: AnimateParam = { curve: Curve.Linear, duration: 200 };
const bottomMarginUnfold = 160;
const bottomMarginFold = 20;

@Component
export struct BeautyView {
  @Prop autoRender: boolean = true;
  @Prop callBackObject: SaveScreenshotCallBack | undefined;
  @State beautyType: FUBeautyType = FUBeautyType.unkown;
  @State captureButtonBottomMargin: number = bottomMarginFold;
  private shouldDoRender: boolean = true;
  private effect: object = TransitionEffect.translate({ x: 0, y: 190 });

  build() {
    Column() {
      this.beautyComponents();
      this.categoryComponents();
    }
    .justifyContent(FlexAlign.End)
    .clip(true)
    .width('100%')
    .height(270)
  }

  @Builder
  beautyComponents() {
    RelativeContainer() {
      if (this.beautyType !== FUBeautyType.unkown) {
        Column() {
          Row() {
            Button({ stateEffect: true }) {
              Image($r('app.media.demo_icon_contrast'))
            }
            .width(40)
            .height(40)
            .margin({ left: 16 })
            .onTouch((event: TouchEvent) => {
              switch (event.type) {
                case TouchType.Up:
                case TouchType.Cancel:
                  if (!this.shouldDoRender) {
                    RenderKitService.sharedInstance().shouldDoRender(true, this.autoRender);
                    this.shouldDoRender = true;
                  }
                  break;
                case TouchType.Down:
                case TouchType.Move:
                  if (this.shouldDoRender) {
                    RenderKitService.sharedInstance().shouldDoRender(false, this.autoRender);
                    this.shouldDoRender = false;
                  }
                  break;
              }
            });
          }
          .width('100%')
          .height(40)
          .justifyContent(FlexAlign.Start)
          .margin({ top: 10 })

          Stack() {
            BeautyFilterView()
              .visibility((this.beautyType === FUBeautyType.Filter) ? Visibility.Visible : Visibility.Hidden)
              .width('100%')
              .height('100%')

            BeautyShapeView()
              .visibility((this.beautyType === FUBeautyType.Shape) ? Visibility.Visible : Visibility.Hidden)
              .width('100%')
              .height('100%')

            BeautySkinView()
              .visibility((this.beautyType === FUBeautyType.Skin) ? Visibility.Visible : Visibility.Hidden)
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height(130)
          .margin({ top: 11 })
        }
        .width('100%')
        .height(190)
        .id('__beautyType__')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .transition(this.effect)
      }

      Row() {
        if (this.autoRender) {
          CaptureButton({
            onClickCallback: () => {
              RenderKitService.sharedInstance().captureImageFromAutoRender = true;
            }, onLongPressStartCallback: () => {
              RenderKitService.sharedInstance().startRecordVideoFromAutoRender = true;
            }, onLongPressEndCallback: () => {
              RenderKitService.sharedInstance().stopRecordVideoFromAutoRender = true;
            }
          })
            .size({ width: 70, height: 70 })
        } else {
          Button({ stateEffect: true }) {
            Image($r('app.media.demo_icon_save'))
          }
          .type(ButtonType.Circle)
          .backgroundColor(Color.White)
          .width(70)
          .height(70)
          .onClick(() => {
            if (this.callBackObject) {
              this.callBackObject.cb();
            }
          })
        }
      }
      .id('__beautyPageCaptureButton__')
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .offset({ bottom: this.captureButtonBottomMargin })
    }
    .width('100%')
    .height(230)
  }

  @Builder
  categoryComponents() {
    Row() {
      Text('美肤')
        .fontSize(16)
        .width('33%')
        .textAlign(TextAlign.Center)
        .fontColor((this.beautyType === FUBeautyType.Skin) ? SELECTCOLOR : Color.White)
        .onClick(() => {
          if (this.beautyType === FUBeautyType.Skin) {
            this.getUIContext()?.animateTo(animateParam, () => {
              this.captureButtonBottomMargin = bottomMarginFold;
              this.beautyType = FUBeautyType.unkown;
            })
          } else {
            if (this.beautyType !== FUBeautyType.unkown) {
              this.beautyType = FUBeautyType.Skin;
              return;
            }
            this.getUIContext()?.animateTo(animateParam, () => {
              this.captureButtonBottomMargin = bottomMarginUnfold;
              this.beautyType = FUBeautyType.Skin;
            })
          }
        })
      Text('美型')
        .fontSize(16)
        .width('33%')
        .textAlign(TextAlign.Center)
        .fontColor((this.beautyType === FUBeautyType.Shape) ? SELECTCOLOR : Color.White)
        .onClick(() => {
          if (this.beautyType === FUBeautyType.Shape) {
            this.getUIContext()?.animateTo(animateParam, () => {
              this.captureButtonBottomMargin = bottomMarginFold;
              this.beautyType = FUBeautyType.unkown;
            })
          } else {
            if (this.beautyType !== FUBeautyType.unkown) {
              this.beautyType = FUBeautyType.Shape;
              return;
            }
            this.getUIContext()?.animateTo(animateParam, () => {
              this.captureButtonBottomMargin = bottomMarginUnfold;
              this.beautyType = FUBeautyType.Shape;
            })
          }
        })
      Text('滤镜')
        .fontSize(16)
        .width('33%')
        .textAlign(TextAlign.Center)
        .fontColor((this.beautyType === FUBeautyType.Filter) ? SELECTCOLOR : Color.White)
        .onClick(() => {
          if (this.beautyType === FUBeautyType.Filter) {
            this.getUIContext()?.animateTo(animateParam, () => {
              this.captureButtonBottomMargin = bottomMarginFold;
              this.beautyType = FUBeautyType.unkown;
            })
          } else {
            if (this.beautyType !== FUBeautyType.unkown) {
              this.beautyType = FUBeautyType.Filter;
              return;
            }
            this.getUIContext()?.animateTo(animateParam, () => {
              this.captureButtonBottomMargin = bottomMarginUnfold;
              this.beautyType = FUBeautyType.Filter;
            })
          }
        })
    }
    .backgroundColor(Color.Black)
    .width('100%')
    .height(40)
  }
}