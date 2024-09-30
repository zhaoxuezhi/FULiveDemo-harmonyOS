import { FULogger, FUNMFileUtil, FUNMRenderKit } from '@faceunity/renderkit_nama'
import { FUBeautySkin, modelValueType } from '../../constants/BeautyConstants';
import { BeautySkinModel } from '../../models/beauty/BeautySkinModel'

const TAG: string = '[BeautySkinViewModel]';

export class BeautySkinViewModel {
  dataArray: BeautySkinModel[] = [];

  constructor() {
    let str: string | null = null;
    const sbPath = `${FUNMFileUtil.fileDir}/beauty/beauty_skin.json`;
    if (FUNMFileUtil.isExist(sbPath)) {
      str = FUNMFileUtil.readTextFormSandBox(sbPath);
    } else {
      str = FUNMFileUtil.readTextFromRawfile('beauty/beauty_skin.json');
    }
    if (str) {
      let maps: Record<string, modelValueType>[] = [];
      try {
        maps = JSON.parse(str);
      } catch (err) {
        FULogger.error(TAG,`JSON.parse fail，${JSON.stringify(err)}}`);
        FUNMFileUtil.clearSandBoxFile(sbPath);
        const rawStr = FUNMFileUtil.readTextFromRawfile('beauty/beauty_skin.json');
        if (rawStr) {
          maps = JSON.parse(rawStr)
        }
      }

      for (const map of maps) {
        const model = new BeautySkinModel(map);
        this.dataArray.push(model);
      }
    }
  }

  saveSkinDataPersistently() {
    const str = JSON.stringify(this.dataArray);
    FUNMFileUtil.writeFileToSandBox(`${FUNMFileUtil.fileDir}/beauty/beauty_skin.json`, str);
  }

  /// 设置单项美肤值
  /// @param value 当前选中单项的值
  setSkinValue(model: BeautySkinModel, value: number) {
    model.currentValue = value * model.ratio;
    this.setValue(model.currentValue, model.type);
  }

  /// 设置当前所有美肤值
  setAllSkinValues() {
    for (const model of this.dataArray) {
      this.setValue(model.currentValue, model.type);
    }
  }

  /// 恢复所有美肤值为默认
  recoverAllSkinValuesToDefault() {
    for (const model of this.dataArray) {
      model.currentValue = model.defaultValue;
      this.setValue(model.currentValue, model.type);
    }
  }

  private setValue(value: number, type: FUBeautySkin): void {
    const beauty = FUNMRenderKit.sharedInstance().beauty;
    if (beauty === undefined) {
      FULogger.error('The beauty of FUNMRenderKit is undefined');
      return;
    }

    switch (type) {
      case FUBeautySkin.BlurLevel:
        beauty.blurLevel = value;
        break;
      case FUBeautySkin.ColorLevel:
        beauty.colorLevel = value;
        break;
      case FUBeautySkin.RedLevel:
        beauty.redLevel = value;
        break;
      case FUBeautySkin.Sharpen:
        beauty.sharpen = value;
        break;
      case FUBeautySkin.FaceThreed:
        beauty.faceThreed = value;
        break;
      case FUBeautySkin.EyeBright:
        beauty.eyeBright = value;
        break;
      case FUBeautySkin.ToothWhiten:
        beauty.toothWhiten = value;
        break;
      case FUBeautySkin.RemovePouchStrength:
        beauty.removePouchStrength = value;
        break;
      case FUBeautySkin.RemoveNasolabialFoldsStrength:
        beauty.removeNasolabialFoldsStrength = value;
        break;
      case FUBeautySkin.AntiAcneSpot:
        beauty.antiAcneSpot = value;
        break;
      case FUBeautySkin.Clarity:
        beauty.clarity = value;
        break;
    }
  }
}
