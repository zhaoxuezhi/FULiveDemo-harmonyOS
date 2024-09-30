import { FULogger, FUNMBeauty, FUNMFileUtil, FUNMRenderKit } from '@faceunity/renderkit_nama'
import { FUBeautyShape, modelValueType } from '../../constants/BeautyConstants';
import { BeautyShapeModel } from '../../models/beauty/BeautyShapeModel'

const TAG: string = '[BeautyShapeViewModel]';

export class BeautyShapeViewModel {
  dataArray: BeautyShapeModel[] = [];

  constructor() {
    let str: string | null = null;
    const sbPath = `${FUNMFileUtil.fileDir}/beauty/beauty_shape.json`;
    if (FUNMFileUtil.isExist(sbPath)) {
      str = FUNMFileUtil.readTextFormSandBox(sbPath);
    } else {
      str = FUNMFileUtil.readTextFromRawfile('beauty/beauty_shape.json');
    }
    if (str) {
      let maps: Record<string, modelValueType>[] = [];
      try {
        maps = JSON.parse(str);
      } catch (err) {
        FULogger.error(TAG,`JSON.parse fail，${JSON.stringify(err)}}`);
        FUNMFileUtil.clearSandBoxFile(sbPath);
        const rawStr = FUNMFileUtil.readTextFromRawfile('beauty/beauty_shape.json');
        if (rawStr) {
          maps = JSON.parse(rawStr)
        }
      }

      for (const map of maps) {
        const model = new BeautyShapeModel(map);
        this.dataArray.push(model);
      }
    }
  }

  saveShapeDataPersistently() {
    const str = JSON.stringify(this.dataArray);
    FUNMFileUtil.writeFileToSandBox(`${FUNMFileUtil.fileDir}/beauty/beauty_shape.json`, str);
  }

  /// 设置单项美型值
  /// @param value 当前选中单项的值
  setShapeValue(model: BeautyShapeModel, value: number) {
    model.currentValue = value;
    this.setValue(model.currentValue, model.type);
  }

  /// 设置当前所有美型值
  setAllShapeValues() {
    for (const model of this.dataArray) {
      this.setValue(model.currentValue, model.type);
    }
  }

  /// 恢复所有美型值为默认
  recoverAllShapeValuesToDefault() {
    for (const model of this.dataArray) {
      model.currentValue = model.defaultValue;
      this.setValue(model.currentValue, model.type);
    }
  }

  private setValue(value: number, type: FUBeautyShape): void {
    const beauty = FUNMRenderKit.sharedInstance().beauty;
    if (beauty === undefined) {
      FULogger.error('The beauty of FUNMRenderKit is undefined');
      return;
    }

    switch (type) {
      case FUBeautyShape.CheekThinning:
        beauty.cheekThinning = value;
        break;
      case FUBeautyShape.CheekV:
        beauty.cheekV = value;
        break;
      case FUBeautyShape.CheekNarrow:
        beauty.cheekNarrow = value;
        break;
      case FUBeautyShape.CheekShort:
        beauty.cheekShort = value;
        break;
      case FUBeautyShape.CheekSmall:
        beauty.cheekSmall = value;
        break;
      case FUBeautyShape.Cheekbones:
        beauty.intensityCheekbones = value;
        break;
      case FUBeautyShape.LowerJaw:
        beauty.intensityLowerJaw = value;
        break;
      case FUBeautyShape.EyeEnlarging:
        beauty.eyeEnlarging = value;
        break;
      case FUBeautyShape.EyeCircle:
        beauty.intensityEyeCircle = value;
        break;
      case FUBeautyShape.Chin:
        beauty.intensityChin = value;
        break;
      case FUBeautyShape.Forehead:
        beauty.intensityForehead = value;
        break;
      case FUBeautyShape.Nose:
        beauty.intensityNose = value;
        break;
      case FUBeautyShape.Mouth:
        beauty.intensityMouth = value;
        break;
      case FUBeautyShape.LipThick:
        beauty.intensityLipThick = value;
        break;
      case FUBeautyShape.EyeHeight:
        beauty.intensityEyeHeight = value;
        break;
      case FUBeautyShape.Canthus:
        beauty.intensityCanthus = value;
        break;
      case FUBeautyShape.EyeLid:
        beauty.intensityEyeLid = value;
        break;
      case FUBeautyShape.EyeSpace:
        beauty.intensityEyeSpace = value;
        break;
      case FUBeautyShape.EyeRotate:
        beauty.intensityEyeRotate = value;
        break;
      case FUBeautyShape.LongNose:
        beauty.intensityLongNose = value;
        break;
      case FUBeautyShape.Philtrum:
        beauty.intensityPhiltrum = value;
        break;
      case FUBeautyShape.Smile:
        beauty.intensitySmile = value;
        break;
      case FUBeautyShape.BrowHeight:
        beauty.intensityBrowHeight = value;
        break;
      case FUBeautyShape.BrowSpace:
        beauty.intensityBrowSpace = value;
        break;
      case FUBeautyShape.BrowThick:
        beauty.intensityBrowThick = value;
        break;
    }
  }
}