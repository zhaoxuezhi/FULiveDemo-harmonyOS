import { MakeUpVCInstance } from '../../viewModels/makeup/MakeUpViewModelController'
import { MakeUpModel } from '../../viewModels/makeup/MakeUpViewModel'
import {
    HorizontalScrollView,
    HorizontalScrollViewItemInterface,
    HorizontalScrollViewShowType
} from '../common/HorizontalScrollView'

@Component
export struct MakeUpView {
  @Require @Prop @Watch('onPropertyDidChange') subMarkupStatusDidChange: number
  // 模板选择
  @State @Watch('onPropertyDidChange') private selectItemIndex: number | undefined = undefined
  @State private selectMakeUpModel: MakeUpModel = {} as MakeUpModel
  @State private showSlider: boolean = false
  @State private customItemViewEnable: boolean = false
  @Require onCustomBtnAction: (() => void) = () => {
  }
  @Require onItemDidSelectAction: ((isReset: boolean) => void) = () => {
  }
  // 滑竿拖动结束后，需要更新子妆的每个滑竿值
  @Require onSliderDragEndAction: (() => void) = () => {
  }

  aboutToAppear(): void {
    this.selectItemIndex = MakeUpVCInstance.makeUpViewModel.defaultSelectItem_index
    this.onPropertyDidChange('selectItemIndex')
  }

  onPropertyDidChange(properTyName: string) {
    if (properTyName === 'selectItemIndex') {
      if (this.selectItemIndex === undefined) {
        this.selectMakeUpModel = {} as MakeUpModel
        this.showSlider = false
        return
      }

      // 更新数据源
      const item = MakeUpVCInstance.makeUpViewModel.dataArray[this.selectItemIndex]
      this.selectMakeUpModel = item
      MakeUpVCInstance.makeUpViewModel.selectMakeup_model = item

      // 更新自定义按钮是否可点击
      this.updateCustomItemViewEnable()

      if (MakeUpVCInstance.makeUpViewModel.isSelectResetMakeup()) {
        /**
         * 重置子妆为初始化状态
         * 卸妆：设置 makeup = undifine
         */
        MakeUpVCInstance.subMakeupViewModel.setUnCombinedAllowEditMakeupAllSubMakeUpToDefault()
        MakeUpVCInstance.onMakeupSelectDidChange()

        // 回调刷新子妆视图
        this.showSlider = false
        this.onItemDidSelectAction(true)

      } else if (MakeUpVCInstance.makeUpViewModel.selectMakeup_model.isCombined) {
        MakeUpVCInstance.onMakeupSelectDidChange()
        // 回调刷新子妆视图
        this.showSlider = true
        this.onItemDidSelectAction(false)

      } else {
        if (MakeUpVCInstance.makeUpViewModel.selectMakeup_model.isAllowedEdit) {
          // 更新子妆数据为子妆 json 数据源,
          MakeUpVCInstance.subMakeupViewModel.setUnCombinedAllowEditMakeupAllSubMakeUpToDefault()
        }
        // 点击妆容风格，子妆值为模板值
        MakeUpVCInstance.set_unCombined_makeUpValue_withTemplateValue()
        MakeUpVCInstance.onMakeupSelectDidChange()
        // 回调刷新子妆视图
        this.showSlider = true
        this.onItemDidSelectAction(false)
      }
    } else if (properTyName === 'subMarkupStatusDidChange') {
      // 如果子妆选中有效值 且当前选中是「卸妆」则一个都不选中
      if (MakeUpVCInstance.subMakeupViewModel.checkSubMakeupSelectIsValid() &&
        this.selectMakeUpModel.name === '卸妆') {
        this.selectItemIndex = undefined
      }
    }
  }

  updateCustomItemViewEnable() {
    if (MakeUpVCInstance.makeUpViewModel.isSelectResetMakeup()) {
      this.customItemViewEnable = true
    } else if (MakeUpVCInstance.makeUpViewModel.selectMakeup_model.isCombined) {
      this.customItemViewEnable = false
    } else if (MakeUpVCInstance.makeUpViewModel.selectMakeup_model.isAllowedEdit) {
      this.customItemViewEnable = true
    } else {
      this.customItemViewEnable = false
    }
  }

  @Builder
  customItemView() {
    RelativeContainer() {
      Image($rawfile('makeup/others/makeup_custom_nor@2x.png'))
        .size({ width: 60, height: '60' })
        .objectFit(ImageFit.Cover)
        .borderRadius(4)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .id('__Image__')

      Text('自定义')
        .fontSize(11)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .alignRules({
          middle: { anchor: '__Image__', align: HorizontalAlign.Center },
          top: { anchor: '__Image__', align: VerticalAlign.Bottom }
        })
        .offset({ y: 6 })
        .id('__Title__')

      Rect()
        .width(2)
        .height(50)
        .radius(2)
        .fill(Color.Grey)
        .alignRules({
          left: { anchor: '__Image__', align: HorizontalAlign.End },
          center: { anchor: '__Image__', align: VerticalAlign.Center }
        })
        .offset({ left: 10 })
        .id('__RectBorder__')
    }
    .width(80)
    .height('100%')
    .opacity(this.customItemViewEnable ? 1 : 0.5)
    .onClick(() => {
      if (this.customItemViewEnable) {
        this.onCustomBtnAction()
      }
    })
  }

  build() {
    RelativeContainer() {
      if (this.showSlider) {
        Slider({
          value: this.selectMakeUpModel?.value,
          min: 0,
          max: 1,
          step: 0.01,
          style: SliderStyle.OutSet,
          direction: Axis.Horizontal,
          reverse: false
        })
          .width('80%')
          .height(40)
          .blockColor('#5ec7fe')
          .trackColor(Color.White)
          .selectedColor('#5ec7fe')
          .showTips(true, `${(this.selectMakeUpModel.value * 100).toFixed()}`)
          .trackThickness(5)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.Moving || mode === SliderChangeMode.Click) {
              this.selectMakeUpModel.value = Number(value.toFixed(2))
              // 回调
              MakeUpVCInstance.onMakeupSliderValueDidChange()
            } else if (mode === SliderChangeMode.End) {
              this.onSliderDragEndAction()
            }
          })
          .id('__Slider__')
          .alignRules({
            middle: {
              anchor: '__container__',
              align: HorizontalAlign.Center
            },
            top: {
              anchor: '__container__',
              align: VerticalAlign.Top
            }
          })
      }

      Row() {
        this.customItemView()
        HorizontalScrollView({
          items: MakeUpVCInstance.makeUpViewModel.dataArray.map((item: MakeUpModel) => {
            const iconName: ResourceStr = $rawfile(`makeup/items/${item.icon}@2x.png`)
            return { id: item.name, imageUrl: iconName, label: item.name } as HorizontalScrollViewItemInterface
          }),
          selectIndex_from: this.selectItemIndex,
          frames: { imgWidth: 60 },
          viewShowType: HorizontalScrollViewShowType.Rectangle,
          showTitle: true,
          itemSpace: 10,
          onItemClick: (item: HorizontalScrollViewItemInterface, index: number) => {
            this.selectItemIndex = index
          }
        })
          .layoutWeight(1)
      }
      .id('__Row__')
      .alignRules({
        top: {
          anchor: '__container__',
          align: VerticalAlign.Top
        }
      })
      .offset({
        top: 40  // Slider bottom
      })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .height(60 + 25)
    }
    .width('100%')
  }
}