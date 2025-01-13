import { FUNMAIKit } from '@faceunity/renderkit_nama'
import { RenderKitService } from '../../service/RenderKitService'

export interface ViewFrame {
  x: number
  y: number
  width: number
  height: number
}

const raceMap: Record<string, Object> = {
  '-1': 'unknow',
  '0': 'black',
  '1': 'white',
  '2': 'yellow',
  '3': 'brown'
};

@Component
export struct FPSFloatView {
  @StorageProp('resolution') @Watch('propertyDidChange') resolution: string = '720×1280'
  @StorageProp('FPSValue') @Watch('propertyDidChange') FPSValue: number = 30
  @StorageProp('renderTime') @Watch('propertyDidChange') renderTime: number = 0

  @State res: string = ''

  propertyDidChange() {
    // const faceNum: number = FUNMAIKit.shareKit().aiFaceProcessorNums()
    let raceResults: string[] = []
    // for (let i = 0; i < faceNum; i++) {
    //   const race = FUNMAIKit.shareKit().getFaceRaceResult(i)
    //   const raceString = `人脸 ${i + 1}: ${raceMap[race] || 'unknow'}`
    //   raceResults.push(raceString)
    // }
    const tempStr = `resolution:\n${this.resolution}\nfps:${this.FPSValue}\nrender time:\n${this.renderTime}ms` +
      (raceResults.length > 0 ? '\n' + raceResults.join('\n') : '')
    this.res = tempStr
  }

  aboutToAppear(): void {
    RenderKitService.sharedInstance().showFPS = true;
  }

  aboutToDisappear(): void {
    RenderKitService.sharedInstance().showFPS = false;
  }

  build() {
    Text(this.res)
      .fontSize(13)
      .padding(5)
      .backgroundColor('#74555555')
      .fontColor(Color.White)
      .borderRadius(5)
  }
}