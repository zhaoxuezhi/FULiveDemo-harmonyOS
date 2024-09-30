import { FULogger, FUNMFileUtil, FUNMRenderKit } from '@faceunity/renderkit_nama'
import { BeautyFilterModel } from '../../models/beauty/BeautyFilterModel'
import { modelValueType } from '../../constants/BeautyConstants';

const TAG: string = '[BeautyFilterViewModel]';

export class BeautyFilterViewModel {
  dataArray: BeautyFilterModel[] = [];
  currentModel: BeautyFilterModel | undefined = undefined;

  constructor() {
    let str: string | null = null;
    const sbPath = `${FUNMFileUtil.fileDir}/beauty/beauty_filter.json`;
    if (FUNMFileUtil.isExist(sbPath)) {
      str = FUNMFileUtil.readTextFormSandBox(sbPath);
    } else {
      str = FUNMFileUtil.readTextFromRawfile('beauty/beauty_filter.json');
    }
    if (str) {
      let maps: Record<string, modelValueType>[] = [];
      try {
        maps = JSON.parse(str);
      } catch (err) {
        FULogger.error(TAG,`JSON.parse fail，${JSON.stringify(err)}}`);
        FUNMFileUtil.clearSandBoxFile(sbPath);
        const rawStr = FUNMFileUtil.readTextFromRawfile('beauty/beauty_filter.json');
        if (rawStr) {
          maps = JSON.parse(rawStr)
        }
      }

      for (const map of maps) {
        const model = new BeautyFilterModel(map);
        this.dataArray.push(model);
      }
      this.currentModel = this.dataArray[0];
    }
  }

  saveFilterDataPersistently() {
    const str = JSON.stringify(this.dataArray);
    FUNMFileUtil.writeFileToSandBox(`${FUNMFileUtil.fileDir}/beauty/beauty_filter.json`, str);
  }

  /// 设置单项滤镜值
  /// @param value 当前选中单项的值
  setFilterValue(model: BeautyFilterModel, value: number) {
    this.currentModel = model;
    model.filterLevel = value;
    this.setFilter(model.filterLevel, model.filterName);
  }

  /// 设置当前滤镜
  setCurrentFilter() {
    if (this.currentModel) {
      this.setFilter(this.currentModel.filterLevel, this.currentModel.filterName);
    } else {
      FULogger.error('currentModel is empty when BeautyFilterViewModel sets setCurrentFilter');
    }
  }

  private setFilter(level: number, filterName: string): void {
    const beauty = FUNMRenderKit.sharedInstance().beauty;
    if (beauty === undefined) {
      FULogger.error('The beauty of FUNMRenderKit is undefined');
      return;
    }

    beauty.filterName = filterName;
    beauty.filterLevel = level;
  }
}