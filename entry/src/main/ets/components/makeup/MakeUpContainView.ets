import { SubMakeupView } from './SubMakeupView'
import { MakeUpView } from './MakeUpView'
import { MakeUpViewModelController, MakeUpVCInstance } from '../../viewModels/makeup/MakeUpViewModelController'

@Component
export struct MakeUpContainView {
  @State private showSubMakeupView: boolean = false
  // 是否重新创建 SubMakeupView
  @State private reCreateSubMakeupView: boolean = false
  // 标记子妆修改完成（点击返回）
  @State private subMakeupStatusDidValueKey: number = Math.random() * 100

  build() {
    RelativeContainer() {
      Row() {
        MakeUpView({
          subMarkupStatusDidChange: this.subMakeupStatusDidValueKey,
          onItemDidSelectAction: (isReset: boolean) => {
            // 重新创建 SubMakeupView
            this.reCreateSubMakeupView = true
            setTimeout(() => {
              this.reCreateSubMakeupView = false
            }, 300) //note: 这里时间不能太短，否则无法触发视图的重新渲染
          },
          onSliderDragEndAction: () => {
            // 重新创建 SubMakeupView
            this.reCreateSubMakeupView = true
            setTimeout(() => {
              this.reCreateSubMakeupView = false
            }, 300) //note: 这里时间不能太短，否则无法触发视图的重新渲染
          },
          onCustomBtnAction: () => {
            animateTo({
              duration: 100,
              tempo: 1,
              curve: Curve.Sharp,
              iterations: 1,
              playMode: PlayMode.Normal,
            }, () => {
              this.showSubMakeupView = true
              MakeUpVCInstance.onSubMakeupViewShowDelegateAction()
            })
          }
        })
      }
      .visibility(this.showSubMakeupView ? Visibility.Hidden : Visibility.Visible)
      .id('MakeUpView')
      .alignRules({
        top: { anchor: '__container__', align: this.showSubMakeupView ? VerticalAlign.Bottom : VerticalAlign.Top }
      })

      if (this.reCreateSubMakeupView) {
        // 移除视图
      } else {
        Row() {
          SubMakeupView({
            onBackBtnAction: () => {
              // 回调
              MakeUpVCInstance.onSubMakeupViewHiddenDelegateAction()
              animateTo({
                duration: 100,
                tempo: 1,
                curve: Curve.Sharp,
                iterations: 1,
                playMode: PlayMode.Normal,
              }, () => {
                this.showSubMakeupView = false
                // 更新主妆视图
                this.subMakeupStatusDidValueKey = Math.random() * 100
              })
            }
          })
        }
        .id('CustomizedMakeupView')
        .visibility(this.showSubMakeupView ? Visibility.Visible : Visibility.Hidden)
        .alignRules({
          top: { anchor: '__container__', align: this.showSubMakeupView ? VerticalAlign.Top : VerticalAlign.Bottom }
        })
      }
    }
    .height(this.showSubMakeupView ? 165 : 130)
  }
}