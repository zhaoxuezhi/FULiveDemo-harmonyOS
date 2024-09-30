@Component
export struct FULightingView {
  minValue: number = -2
  maxValue: number = 2
  @Link value: number
  @Prop show: boolean

  build() {
    Column() {
      Image($rawfile('lighting/lighting_sun@2x.png'))
        .size({ width: 20, height: 20 })
        .objectFit(ImageFit.Contain)
      RelativeContainer() {
        Slider({
          value: this.value,
          min: this.minValue,
          max: this.maxValue,
          step: 0.01,
          style: SliderStyle.OutSet,
          direction: Axis.Vertical
        })
          .id('Slider')
          .blockColor(Color.White)
          .trackColor(Color.White)
          .selectedColor(Color.White)
          .showSteps(false)
          .showTips(false)
          .trackThickness(10)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.value = value
          })
        Text()
          .id('middle')
          .size({ width: 10, height: 4 })
          .backgroundColor(Color.White)
          .borderRadius(2)
          .alignRules({
            middle: {
              anchor: 'Slider',
              align: HorizontalAlign.Center
            },
            center: {
              anchor: 'Slider',
              align: VerticalAlign.Center
            }
          })
      }

      Image($rawfile('lighting/lighting_mon@2x.png'))
        .size({ width: 20, height: 20 })
        .objectFit(ImageFit.Contain)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .size({ width: '100%', height: '100%' })
  }
}