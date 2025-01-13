import { FUNMFileUtil } from '@faceunity/renderkit_nama'
import { SubMakeupJsonModel } from './SubMakeupJsonModel'
import { SubMakeupItemModel } from './SubMakeupViewModel'

export interface MakeUpModel {
  name: string // 名称
  icon: string // icon
  value: number // 当前程度值
  selectedFilterLevel: number // 滤镜程度
  bundleName: string
  selectedFilter: string // 滤镜名称（v8.0.0之后不需要）
  isCombined: boolean // 是否v8.0.0之后新组合妆（只用一个bundle）
  isAllowedEdit: boolean // 是否允许自定义

  /**
   * 风格模板值（子妆的初始化值）
   * 只有非组合妆才有
   */
  foundationModel: MakeUpTemplateValueInterface // 粉底
  lipstickModel: MakeUpTemplateValueInterface // 口红
  blusherModel: MakeUpTemplateValueInterface // 腮红
  eyebrowModel: MakeUpTemplateValueInterface // 眉毛
  eyeShadowModel: MakeUpTemplateValueInterface // 眼影
  eyelinerModel: MakeUpTemplateValueInterface // 眼线
  eyelashModel: MakeUpTemplateValueInterface // 睫毛
  highlightModel: MakeUpTemplateValueInterface // 高光
  shadowModel: MakeUpTemplateValueInterface // 阴影
  pupilModel: MakeUpTemplateValueInterface // 美瞳

  /**
   * 最终选择的子妆 item
   * 只有非组合妆才有
   * 对于不可编辑的非组合妆，赖加载初始化
   * 对于可编辑的非组合妆，在 viewmodel 初始化时按照配置赋值 json 数据
   */
  select_foundationModel: SubMakeupItemModel // 粉底
  select_lipstickModel: SubMakeupItemModel // 口红
  select_blusherModel: SubMakeupItemModel // 腮红
  select_eyebrowModel: SubMakeupItemModel // 眉毛
  select_eyeShadowModel: SubMakeupItemModel // 眼影
  select_eyelinerModel: SubMakeupItemModel // 眼线
  select_eyelashModel: SubMakeupItemModel // 睫毛
  select_highlightModel: SubMakeupItemModel // 高光
  select_shadowModel: SubMakeupItemModel // 阴影
  select_pupilModel: SubMakeupItemModel // 美瞳
}

// 风格默认值
export interface MakeUpTemplateValueInterface {
  value: number // 妆容程度值 系数

  subMakeUpLabel_name?: string // 粉底、口红、腮红、眉毛....
  subMakeupItem_index?: number // MakeUpLabel 选项下选中的下标
  subMakeupItem_color_index?: number // 默认选择颜色索引

  // 口红
  isTwoColorLipstick?: boolean // 是否双色口红
  lipstickType?: number // 口红类型

  // 眉毛
  isBrowWarp?: boolean // 是否使用眉毛变形
  // @note 当isBrowWarp为NO时，设置眉毛类型无效果
  browWarpType?: number //眉毛类型（0柳叶眉  1上挑眉  2一字眉  3英气眉  4远山眉  5标准眉  6扶形眉  7剑眉  8日常风  9日系风）
}

export class MakeUpViewModel {
  dataArray: MakeUpModel[] = [];
  defaultSelectItem_index: number = 1
  selectMakeup_model: MakeUpModel = {} as MakeUpModel

  constructor() {
    const str = FUNMFileUtil.readTextFromRawfile('makeup/CombinationMakeup/combination_makeups.json');
    if (str) {
      this.dataArray = JSON.parse(str);
      this.selectMakeup_model = this.dataArray[this.defaultSelectItem_index]

      // 设置子妆
      for (let i = 0; i < this.dataArray.length; i++) {
        const model = this.dataArray[i]
        /**
         * 卸妆和组合妆不需要模版值
         */
        if (!MakeUpViewModel.isResetMakeup(model) && !model.isCombined) {
          // 没有风格的美妆都有对应的多个子项，保存在每种风格的 json 文件里
          // const rawPath: ResourceStr = $rawfile('makeup/CombinationMakeup/JSON/ziyun.json')
          const jsonStr: string =
            FUNMFileUtil.readTextFromRawfile(`makeup/CombinationMakeup/JSON/${model.bundleName}.json`) || '';
          const jsonData = JSON.parse(jsonStr) as SubMakeupJsonModel

          // 粉底
          const foundationModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_foundation ?? 0).toFixed(2)),
            subMakeUpLabel_name: '粉底'
          } as MakeUpTemplateValueInterface;
          model.foundationModel = foundationModel;

          // 口红
          const lipstickModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_lip ?? 0).toFixed(2)),
            isTwoColorLipstick: jsonData.is_two_color,
            lipstickType: jsonData.lip_type,
            subMakeUpLabel_name: '口红'
          } as MakeUpTemplateValueInterface;
          model.lipstickModel = lipstickModel;

          // 腮红
          const blusherModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_blusher ?? 0).toFixed(2)),
            subMakeUpLabel_name: '腮红'
          } as MakeUpTemplateValueInterface;
          model.blusherModel = blusherModel;

          // 眉毛
          const eyebrowModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_eyeBrow ?? 0).toFixed(2)),
            isBrowWarp: jsonData.brow_warp,
            browWarpType: jsonData.brow_warp_type,
            subMakeUpLabel_name: '眉毛'
          } as MakeUpTemplateValueInterface;
          model.eyebrowModel = eyebrowModel;

          // 眼影
          const eyeShadowModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_eye ?? 0).toFixed(2)),
            subMakeUpLabel_name: '眼影'
          } as MakeUpTemplateValueInterface;
          model.eyeShadowModel = eyeShadowModel;

          // 眼线
          const eyelinerModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_eyeLiner ?? 0).toFixed(2)),
            subMakeUpLabel_name: '眼线'
          } as MakeUpTemplateValueInterface;
          model.eyelinerModel = eyelinerModel;

          // 睫毛
          const eyelashModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_eyelash ?? 0).toFixed(2)),
            subMakeUpLabel_name: '睫毛'
          } as MakeUpTemplateValueInterface;
          model.eyelashModel = eyelashModel;

          // 高光
          const highlightModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_highlight ?? 0).toFixed(2)),
            subMakeUpLabel_name: '高光'
          } as MakeUpTemplateValueInterface;
          model.highlightModel = highlightModel;

          // 阴影
          const shadowModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_shadow ?? 0).toFixed(2)),
            subMakeUpLabel_name: '阴影'
          } as MakeUpTemplateValueInterface;
          model.shadowModel = shadowModel;

          // 美瞳
          const pupilModel: MakeUpTemplateValueInterface = {
            value: Number((jsonData.makeup_intensity_pupil ?? 0).toFixed(2)),
            subMakeUpLabel_name: '美瞳'
          } as MakeUpTemplateValueInterface;
          model.pupilModel = pupilModel;

          // 允许自定义组合妆包含的各个子妆对应自定义子妆索引和颜色索引
          if (model.name === "性感") {
            foundationModel.subMakeupItem_index = 1;
            lipstickModel.subMakeupItem_index = 1;
            lipstickModel.subMakeupItem_color_index = 0;
            blusherModel.subMakeupItem_index = 2;
            blusherModel.subMakeupItem_color_index = 0;
            eyebrowModel.subMakeupItem_index = 1;
            eyebrowModel.subMakeupItem_color_index = 0;
            eyeShadowModel.subMakeupItem_index = 2;
            eyeShadowModel.subMakeupItem_color_index = 0;
            eyelinerModel.subMakeupItem_index = 1;
            eyelinerModel.subMakeupItem_color_index = 0;
            eyelashModel.subMakeupItem_index = 4;
            eyelashModel.subMakeupItem_color_index = 0;
            highlightModel.subMakeupItem_index = 2;
            highlightModel.subMakeupItem_color_index = 0;
            shadowModel.subMakeupItem_index = 1;
            shadowModel.subMakeupItem_color_index = 0;
            pupilModel.subMakeupItem_index = 0;
            pupilModel.subMakeupItem_color_index = 0;
          } else if (model.name === "甜美") {
            foundationModel.subMakeupItem_index = 2;
            lipstickModel.subMakeupItem_index = 1;
            lipstickModel.subMakeupItem_color_index = 1;
            blusherModel.subMakeupItem_index = 4;
            blusherModel.subMakeupItem_color_index = 1;
            eyebrowModel.subMakeupItem_index = 4;
            eyebrowModel.subMakeupItem_color_index = 0;
            eyeShadowModel.subMakeupItem_index = 1;
            eyeShadowModel.subMakeupItem_color_index = 0;
            eyelinerModel.subMakeupItem_index = 2;
            eyelinerModel.subMakeupItem_color_index = 1;
            eyelashModel.subMakeupItem_index = 2;
            eyelashModel.subMakeupItem_color_index = 0;
            highlightModel.subMakeupItem_index = 1;
            highlightModel.subMakeupItem_color_index = 1;
            shadowModel.subMakeupItem_index = 1;
            shadowModel.subMakeupItem_color_index = 0;
            pupilModel.subMakeupItem_index = 0;
            pupilModel.subMakeupItem_color_index = 0;
          } else if (model.name === "邻家") {
            foundationModel.subMakeupItem_index = 3;
            lipstickModel.subMakeupItem_index = 1;
            lipstickModel.subMakeupItem_color_index = 2;
            blusherModel.subMakeupItem_index = 1;
            blusherModel.subMakeupItem_color_index = 2;
            eyebrowModel.subMakeupItem_index = 2;
            eyebrowModel.subMakeupItem_color_index = 0;
            eyeShadowModel.subMakeupItem_index = 1;
            eyeShadowModel.subMakeupItem_color_index = 0;
            eyelinerModel.subMakeupItem_index = 6;
            eyelinerModel.subMakeupItem_color_index = 2;
            eyelashModel.subMakeupItem_index = 1;
            eyelashModel.subMakeupItem_color_index = 0;
            highlightModel.subMakeupItem_index = 0;
            highlightModel.subMakeupItem_color_index = 0;
            shadowModel.subMakeupItem_index = 0;
            shadowModel.subMakeupItem_color_index = 0;
            pupilModel.subMakeupItem_index = 0;
            pupilModel.subMakeupItem_color_index = 0;
          } else if (model.name === "欧美") {
            foundationModel.subMakeupItem_index = 2;
            lipstickModel.subMakeupItem_index = 1;
            lipstickModel.subMakeupItem_color_index = 3;
            blusherModel.subMakeupItem_index = 2;
            blusherModel.subMakeupItem_color_index = 3;
            eyebrowModel.subMakeupItem_index = 1;
            eyebrowModel.subMakeupItem_color_index = 0;
            eyeShadowModel.subMakeupItem_index = 4;
            eyeShadowModel.subMakeupItem_color_index = 0;
            eyelinerModel.subMakeupItem_index = 5;
            eyelinerModel.subMakeupItem_color_index = 3;
            eyelashModel.subMakeupItem_index = 5;
            eyelashModel.subMakeupItem_color_index = 0;
            highlightModel.subMakeupItem_index = 2;
            highlightModel.subMakeupItem_color_index = 3;
            shadowModel.subMakeupItem_index = 1;
            shadowModel.subMakeupItem_color_index = 3;
            pupilModel.subMakeupItem_index = 0;
            pupilModel.subMakeupItem_color_index = 0;
          } else if (model.name === "妩媚") {
            foundationModel.subMakeupItem_index = 4;
            lipstickModel.subMakeupItem_index = 1;
            lipstickModel.subMakeupItem_color_index = 4;
            blusherModel.subMakeupItem_index = 3;
            blusherModel.subMakeupItem_color_index = 4;
            eyebrowModel.subMakeupItem_index = 1;
            eyebrowModel.subMakeupItem_color_index = 0;
            eyeShadowModel.subMakeupItem_index = 2;
            eyeShadowModel.subMakeupItem_color_index = 1;
            eyelinerModel.subMakeupItem_index = 3;
            eyelinerModel.subMakeupItem_color_index = 2;
            eyelashModel.subMakeupItem_index = 3;
            eyelashModel.subMakeupItem_color_index = 0;
            highlightModel.subMakeupItem_index = 1;
            highlightModel.subMakeupItem_color_index = 4;
            shadowModel.subMakeupItem_index = 0;
            shadowModel.subMakeupItem_color_index = 0;
            pupilModel.subMakeupItem_index = 0;
            pupilModel.subMakeupItem_color_index = 0;
          }
        }
      }
    }
  }

  static isResetMakeup = (model: MakeUpModel) => {
    if (model && model.icon === 'makeup_noitem') {
      return true
    }
    return false
  }

  /**
   * 获取当前主妆某一项的模版值
   * describe: xxx
   */
  getMakeupTemplateModelWithLabel(labelName: string): MakeUpTemplateValueInterface {
    const selectMakeupModel = this.selectMakeup_model
    if (labelName === '粉底') {
      return selectMakeupModel.foundationModel
    } else if (labelName === '口红') {
      return selectMakeupModel.lipstickModel
    } else if (labelName === '腮红') {
      return selectMakeupModel.blusherModel
    } else if (labelName === '眉毛') {
      return selectMakeupModel.eyebrowModel
    } else if (labelName === '眼影') {
      return selectMakeupModel.eyeShadowModel
    } else if (labelName === '眼线') {
      return selectMakeupModel.eyelinerModel
    } else if (labelName === '睫毛') {
      return selectMakeupModel.eyelashModel
    } else if (labelName === '高光') {
      return selectMakeupModel.highlightModel
    } else if (labelName === '阴影') {
      return selectMakeupModel.shadowModel
    } else if (labelName === '美瞳') {
      return selectMakeupModel.pupilModel
    }
    return {} as MakeUpTemplateValueInterface
  }

  // 是否选中了卸妆
  isSelectResetMakeup = (): boolean => {
    return MakeUpViewModel.isResetMakeup(this.selectMakeup_model);
  }
}