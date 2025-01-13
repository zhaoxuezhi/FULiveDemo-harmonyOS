import { FULogger, FUNMFileUtil, FUNMRenderKit } from '@faceunity/renderkit_nama'
import { BeautyFilterModel } from '../../models/beauty/BeautyFilterModel'
import { modelValueType } from '../../constants/Constants';

const TAG: string = '[BeautyFilterViewModel]';
const filterJsonName = 'beauty/beauty_filter.json';
const sandboxJsonName = 'beauty/v8.13.0/beauty_filter.json';
const filterSelectedIndexJsonName = 'beauty/beauty_filter_selectedIndex.json';

export class BeautyFilterViewModel {
  dataArray: BeautyFilterModel[] = [];
  currentModel: BeautyFilterModel | undefined = undefined;
  selectedIndex: number = 0;

  constructor() {
    let str: string | null = null;
    const sbPath = `${FUNMFileUtil.fileDir}/${sandboxJsonName}`;
    if (FUNMFileUtil.isExist(sbPath)) {
      str = FUNMFileUtil.readTextFormSandBox(sbPath);
    } else {
      str = FUNMFileUtil.readTextFromRawfile(filterJsonName);
    }
    if (str) {
      let maps: Record<string, modelValueType>[] = JSON.parse(str);
      for (const map of maps) {
        const model = new BeautyFilterModel(map);
        this.dataArray.push(model);
      }
      this.currentModel = this.dataArray[0];
    }

    // 选中下标
    let selectedIndexStr: string | null = null;
    const filterSelectedIndexPath = `${FUNMFileUtil.fileDir}/beauty/beauty_filter_selectedIndex.json`;
    if (FUNMFileUtil.isExist(sbPath)) {
      selectedIndexStr = FUNMFileUtil.readTextFormSandBox(filterSelectedIndexPath);
    }
    this.selectedIndex = Number(selectedIndexStr);
    if (this.selectedIndex < 0 || this.selectedIndex >= this.dataArray.length)   {
      this.selectedIndex = 0;
      this.currentModel = this.dataArray[0];
      return;
    }
    this.currentModel = this.dataArray[this.selectedIndex];
  }

  saveFilterDataPersistently() {
    const str = JSON.stringify(this.dataArray);
    FUNMFileUtil.writeFileToSandBox(`${FUNMFileUtil.fileDir}/${sandboxJsonName}`, str);

    const selectedIndexStr = this.selectedIndex.toString();
    FUNMFileUtil.writeFileToSandBox(`${FUNMFileUtil.fileDir}/${filterSelectedIndexJsonName}`, selectedIndexStr);
  }

  static deleteFilterDataPersistently() {
    FUNMFileUtil.clearSandBoxFile(`${FUNMFileUtil.fileDir}/${sandboxJsonName}`);
    FUNMFileUtil.clearSandBoxFile(`${FUNMFileUtil.fileDir}/${filterSelectedIndexJsonName}`);
  } 

  /// 设置单项滤镜值
  /// @param value 当前选中单项的值
  setFilterValue(model: BeautyFilterModel, value: number, index: number) {
    this.selectedIndex = index;
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