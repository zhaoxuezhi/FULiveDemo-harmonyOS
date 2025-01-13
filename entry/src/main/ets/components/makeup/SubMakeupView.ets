import { MakeUpVCInstance } from '../../viewModels/makeup/MakeUpViewModelController'
import { SubMakeupItemModel, SubMakeupLabelModel, SubMakeupViewModel } from '../../viewModels/makeup/SubMakeupViewModel'
import {
    HorizontalScrollView as ScrollItem,
    HorizontalScrollViewItemInterface as ScrollItemInterface,
    HorizontalScrollViewShowType as ScrollItemShowType
} from '../common/HorizontalScrollView'
import {
    HorizontalScrollLabelView as ScrollLabel,
    HorizontalScrollLabelViewInterface as ScrollLabelInterface
} from './HorizontalScrollLabelView'

@Component
export struct SubMakeupView {
  // label view
  @State private selectScrollLabelIndex: number = 0
  @State private scrollLabelDataArr: ScrollLabelInterface[] = []
  // item view
  @State private scrollItemDataArr: ScrollItemInterface[] = []
  @State private scrollItemSelectIndex: number = 0
  // 滑竿
  @State private showSliderView: boolean = false
  @State private slideValue: number = 0
  // 点击返回
  @Require onBackBtnAction: (() => void) = () => {
  }

  aboutToAppear(): void {
    this.selectScrollLabelIndex = MakeUpVCInstance.subMakeupViewModel.selectLabel_index
    this.scrollLabelDataArr = MakeUpVCInstance.subMakeupViewModel.labelArrayViews
    this.scrollItemDataArr = MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_views
    this.scrollItemSelectIndex = MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_index

    // 更新滑竿值
    const selectSubItem_model = MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model
    this.showSliderView = SubMakeupViewModel.isResetSubMakeupItem(selectSubItem_model) ?
      false : true
    this.slideValue = selectSubItem_model.value
  }

  scrollLabelDidChange(item: ScrollItemInterface, index: number) {
    // 更新选中
    this.selectScrollLabelIndex = index

    // 更新数据源
    MakeUpVCInstance.subMakeupViewModel.selectLabel_index = index
    MakeUpVCInstance.subMakeupViewModel.selectLabel_model =
      MakeUpVCInstance.subMakeupViewModel.labelArray[index]
    const selectLabelModel: SubMakeupLabelModel =
      MakeUpVCInstance.subMakeupViewModel.selectLabel_model

    // 更新 items
    this.scrollItemDataArr = selectLabelModel.u_sgArr_views

    // 更新 item select index
    this.scrollItemSelectIndex = selectLabelModel.u_sgArr_select_index


    // 更新滑竿
    // 是否显示滑竿
    const showSliderView =
      SubMakeupViewModel.isResetSubMakeupItem(selectLabelModel.u_sgArr_select_model) ? false : true
    this.showSliderView = showSliderView
    this.slideValue = selectLabelModel.u_sgArr_select_model.value

    // 回调
    MakeUpVCInstance.onSubMakeupLabelDelegateAction(selectLabelModel)
  }

  scrollItemSelectDidChange(item: ScrollItemInterface, index: number) {
    // 更新 item select index
    this.scrollItemSelectIndex = index

    // 更新数据源
    MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_index = index
    MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_view = item
    MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model =
      MakeUpVCInstance.subMakeupViewModel.selectLabel_model.sgArr[index]

    const selectItemModel: SubMakeupItemModel =
      MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model

    // 是否显示滑竿
    const showSliderView = SubMakeupViewModel.isResetSubMakeupItem(selectItemModel) ? false : true
    this.showSliderView = showSliderView
    this.slideValue = selectItemModel.value

    // 是否 label badge
    for (let i = 0; i < this.scrollLabelDataArr.length; i++) {
      const l = this.scrollLabelDataArr[i]
      const label_model = MakeUpVCInstance.subMakeupViewModel.labelArray[i]
      if (SubMakeupViewModel.isResetSubMakeupItem(label_model.u_sgArr_select_model)) {
        l.showBadge = false
      } else {
        l.showBadge = true
      }
    }
    this.scrollLabelDataArr = [...this.scrollLabelDataArr]

    // 回调
    MakeUpVCInstance.onSubMakeupSelectDidChange()
    MakeUpVCInstance.onSubMakeupItemDelegateAction(selectItemModel)
  }

  @Builder
  backItemView() {
    RelativeContainer() {
      Image($rawfile('makeup/others/makeup_return_nor@2x.png'))
        .size({ width: 60, height: '60' })
        .objectFit(ImageFit.Cover)
        .borderRadius(4)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .id('Image')

      Rect()
        .width(2)
        .height(50)
        .radius(2)
        .fill(Color.Grey)
        .alignRules({
          left: { anchor: 'Image', align: HorizontalAlign.End },
          center: { anchor: 'Image', align: VerticalAlign.Center }
        })
        .offset({ left: 10 })
        .id('RectBorder')
    }
    .width(80)
    .height('100%')
    .onClick(() => {
      this.onBackBtnAction()
    })
  }

  build() {
    Column() {
      if (this.showSliderView) {
        Slider({
          value: this.slideValue,
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
          .showTips(true,
            `${((this.slideValue as number) * 100).toFixed()}`)
          .trackThickness(5)
          .onChange((value: number) => {
            this.slideValue = value
            MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model.value =
              Number(value.toFixed(2))
            // 回调
            MakeUpVCInstance.onSubMakeupSliderValueDidChange()
          })
      }

      Row() {
        this.backItemView()
        ScrollItem({
          items: this.scrollItemDataArr,
          selectIndex_from: this.scrollItemSelectIndex,
          frames: { imgWidth: 60 },
          viewShowType: ScrollItemShowType.Rectangle,
          itemSpace: 10,
          onItemClick: (item: ScrollItemInterface, index: number) => {
            this.scrollItemSelectDidChange(item, index)
          }
        })
          .layoutWeight(1)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .height(60)

      Rect()
        .width('100%')
        .height(2)
        .fill(Color.Grey)
        .margin({ top: 10, bottom: 10 })

      ScrollLabel({
        selectIndex_from: this.selectScrollLabelIndex,
        items: this.scrollLabelDataArr,
        onItemClick: (item: ScrollItemInterface, index: number) => {
          this.scrollLabelDidChange(item, index)
        }
      })
        .height(40)
    }
    .justifyContent(FlexAlign.End)
    .height('100%')
  }
}