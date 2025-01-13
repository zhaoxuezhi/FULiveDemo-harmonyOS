import { FULogger } from '@faceunity/renderkit_nama'
import { RenderKitService } from '../../service/RenderKitService'
import { SaveScreenshotCallBack } from '../../utils/CallBack'
import { MakeUpVCInstance } from '../../viewModels/makeup/MakeUpViewModelController'
import { formatColors, SubMakeupItemModel, SubMakeupLabelModel } from '../../viewModels/makeup/SubMakeupViewModel'
import { CaptureButton } from '../common/CaptureButton'
import { VerticalColorPicker } from '../common/VerticalColorPicker'
import { MakeUpContainView } from './MakeUpContainView'
import { AutoDismissToast } from '../common/AutoDismissToast'

@Component
export struct MakeupPageView {
  @Prop autoRender: boolean;
  @Prop callBackObject: SaveScreenshotCallBack | undefined;
  @State colorPickerColors: string[][] = []
  // colorPicker
  @State private colorPickerSelectIndex: number = 0
  // 选中 item Toast 提示
  @State private selectSubItemName: string = ''
  // 子妆视图是否显示
  private subMakeupViewIsShowing = false

  aboutToAppear(): void {
    MakeUpVCInstance.onSubMakeupItemDelegateAction = (item: SubMakeupItemModel) => {
      this._updateColorPicker()
      this.selectSubItemName = item.title
    }
    MakeUpVCInstance.onSubMakeupLabelDelegateAction = (_label: SubMakeupLabelModel) => {
      this._updateColorPicker()
    }
    MakeUpVCInstance.onSubMakeupViewHiddenDelegateAction = () => {
      this.subMakeupViewIsShowing = false
      this._updateColorPicker()
    }
    MakeUpVCInstance.onSubMakeupViewShowDelegateAction = () => {
      this.subMakeupViewIsShowing = true
      this._updateColorPicker()
    }
  }

  build() {
    Column() {
      RelativeContainer() {
        if (this.colorPickerColors.length) {
          Row() {
            VerticalColorPicker({
              colorList: this.colorPickerColors,
              selectedIndex_from: this.colorPickerSelectIndex,
              onSelectColor: (_colors: string[], index: number) => {
                this.colorPickerSelectIndex = index
                MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model.u_selectColor_index =
                  index
                // 更新数据源 & 回调
                MakeUpVCInstance.onSubMakeupColorPickerValueDidChange()
              }
            })
          }
          .id('__VerticalColorPicker__')
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
          })
          .offset({ right: 15, bottom: 15 })
        }

        // 选中 item toast 提示
        Row() {
          AutoDismissToast({
            message: this.selectSubItemName
          })
        }
        .id('__SelectItemToast__')
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })

        // 视频/图片采集
        Row() {
          //TODO: 图片/视频采集回调函数实现
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
        .id('__CaptureButton__')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .offset({ bottom: 10 })
      }
      .layoutWeight(1)

      // 美妆选择器
      MakeUpContainView()
        .backgroundColor(Color.Black)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  private _updateColorPicker() {
    // 更新 colorPicker 值
    if (MakeUpVCInstance.subMakeupViewModel.needShowColorPicker() && this.subMakeupViewIsShowing) {
      // 更新 colorPicker 数据源
      const colorsArr = MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model.colors
      //格式为： [['rgba(1.0,0.43,0.44,1.0)','rgba(1.0,0.43,0.44,1.0)'], ['rgba(1.0,0.43,0.44,1.0)','rgba(1.0,0.43,0.44,1.0)'],['rgba(1.0,0.43,0.44,1.0)','rgba(1.0,0.43,0.44,1.0)']]
      const colorArray: string[][] = [];
      for (let i = 0; i < colorsArr.length; i++) {
        const tempColors = formatColors(colorsArr[i])
        if (tempColors.length) {
          colorArray.push(tempColors);
        }
      }
      this.colorPickerColors = colorArray

      // 更新 colorPicker 选中
      this.colorPickerSelectIndex =
        MakeUpVCInstance.subMakeupViewModel.selectLabel_model.u_sgArr_select_model.u_selectColor_index

    } else {
      this.colorPickerColors = []
    }
  }
}