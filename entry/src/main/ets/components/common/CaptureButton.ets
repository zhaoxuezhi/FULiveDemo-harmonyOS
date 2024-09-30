import { FULogger } from '@faceunity/renderkit_nama';

@Component
export struct CaptureButton {
  @State private isLongPressed: boolean = false;
  @State private progressValue: number = 0;
  private longPressTimer: number = 0;
  private timerGo: number = 0;
  private readonly LONG_PRESS_DURATION: number = 10; // 10s
  @State private animationPadding: number = 2
  @Require onClickCallback: () => void = () => {
  };
  @Require onLongPressStartCallback: () => void = () => {
  };
  @Require onLongPressEndCallback: () => void = () => {
  };

  build() {
    RelativeContainer() {
      Image($r("app.media.render_camera_capture"))
        .id('__Image__')
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            TapGesture()
              .onAction(() => {
                FULogger.info('CaptureButton', '响应了点击手势')
                this.onClickCallback();
              }),
            // TODO: 1.0.0版本暂时不支持视频录制，UI先不支持长按
            // LongPressGesture({ repeat: false, duration: 300 })
            //   .onAction((event: GestureEvent) => {
            //     FULogger.info('CaptureButton', '响应了长按手势 - 开始')
            //     this.startLongPress();
            //   })
            //   .onActionEnd(() => {
            //     FULogger.info('CaptureButton', '响应了长按手势 - 结束')
            //     this.endLongPress();
            //   })
            //   .onActionCancel(() => {
            //     FULogger.info('CaptureButton', '响应了长按手势 - 取消')
            //     this.endLongPress();
            //   })
          )
        )
      if (this.isLongPressed) {
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
      }
    }
    .padding(this.animationPadding)
  }

  aboutToDisappear() {
    clearTimeout(this.longPressTimer);
  }

  private startLongPress() {
    this.isLongPressed = true;
    this.progressValue = 0;
    this.timerGo = 0;
    this.onLongPressStartCallback();
    animateTo({
      duration: 100,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, () => {
      this.animationPadding = 0
    })


    // Start the timer
    this.longPressTimer = setInterval(() => {
      if (this.progressValue >= 100) {
        clearTimeout(this.longPressTimer);
        return
      }
      this.timerGo += 100
      // 计算出百分比, *100 总数
      this.progressValue = (this.timerGo / (this.LONG_PRESS_DURATION * 1000)) * 100
      console.log('this.progressValue = ', this.progressValue)
    }, 100)
  }

  private endLongPress() {
    if (this.isLongPressed) {
      this.isLongPressed = false;
      this.progressValue = 0;
      this.onLongPressEndCallback();

      clearTimeout(this.longPressTimer);

      animateTo({
        duration: 100,
        curve: Curve.Linear,
        iterations: 1,
        playMode: PlayMode.Normal,
      }, () => {
        this.animationPadding = 2
      })
    }
  }
}