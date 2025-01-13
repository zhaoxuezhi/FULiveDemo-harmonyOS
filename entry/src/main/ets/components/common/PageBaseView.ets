import FUSafeAreaUtil from "../../utils/FUSafeAreaUtil"

@Component
export struct PageBaseView {
  @BuilderParam child: () => void
  build() {
    Column(){
      this.child()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .padding({ top: FUSafeAreaUtil.getStatusBarHeight(), bottom: FUSafeAreaUtil.getBottomBarHeight() })
  }
}