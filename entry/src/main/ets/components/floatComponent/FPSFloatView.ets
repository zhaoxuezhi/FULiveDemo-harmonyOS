import { hookAboutToDisAppear } from '../../pages/hook/WithComponentLifeCycleHook'
import { RenderKitService } from '../../service/RenderKitService'

export interface ViewFrame {
  x: number
  y: number
  width: number
  height: number
}

@Component
export struct FPSFloatView {
  @StorageProp('resolution') resolution: string = '720×1280'
  @StorageProp('FPSValue') FPSValue: number = 30
  @StorageProp('renderTime') renderTime: number = 0

  aboutToAppear(): void {
    RenderKitService.sharedInstance().showFPS = true;
  }

  @hookAboutToDisAppear
  aboutToDisappear(): void {
    RenderKitService.sharedInstance().showFPS = false;
  }

  build() {
    Text(`resolution:\n${this.resolution}\nfps:${this.FPSValue}\nrender time:\n${this.renderTime}ms`)
      .fontSize(13)
      .padding(5)
      .backgroundColor('#74555555')
      .fontColor(Color.White)
      .borderRadius(5)
  }
}