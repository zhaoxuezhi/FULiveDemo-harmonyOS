import { FUNMFileUtil } from '@faceunity/renderkit_nama'
import { HorizontalScrollLabelViewInterface } from '../../components/makeup/HorizontalScrollLabelView'
import { HorizontalScrollViewItemInterface } from '../../components/common/HorizontalScrollView'

export enum SubMakeupType {
  Foundation, // 粉底
  Lip, // 口红
  Blusher, // 腮红
  Eyebrow, // 眉毛
  EyeShadow, // 眼影
  Eyeliner, // 眼线
  Eyelash, // 睫毛
  Highlight, // 高光
  Shadow, // 阴影
  Pupil // 美瞳
}

export interface SubMakeupItemModel {
  type: SubMakeupType // 类型
  icon: string
  title: string
  bundleName: string
  value: number // 妆容程度值
  // color: number[] // 子妆当前颜色
  colors: number[][] // 可选颜色数组
  defaultColorIndex: number // 默认选择颜色索引

  // 口红
  isTwoColorLipstick: boolean // 是否双色口红
  lipstickType: number // 口红类型

  // 眉毛
  isBrowWarp: boolean // 是否使用眉毛变形
  // @note 当isBrowWarp为NO时，设置眉毛类型无效果
  browWarpType: number //眉毛类型（0柳叶眉  1上挑眉  2一字眉  3英气眉  4远山眉  5标准眉  6扶形眉  7剑眉  8日常风  9日系风）

  u_selectColor_index: number // 选择的 color index
}

export interface SubMakeupLabelModel {
  name: string
  sgArr: SubMakeupItemModel[]
  u_sgArr_views: HorizontalScrollViewItemInterface[] // 对应的视图 model
  u_sgArr_select_view: HorizontalScrollViewItemInterface // 记录当前分组下 sgArr 选中的视图 model
  u_sgArr_select_model: SubMakeupItemModel // 选中的数据源
  u_sgArr_select_index: number // 选中的下标
}

/*
 * colors: [1.0,0.43,0.44,1.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0]
 * 转化为:  ['rgba(1.0,0.43,0.44,1.0)','rgba(1.0,0.43,0.44,1.0)'] 格式，过滤掉 Alpha=0的数据
 */
export function formatColors(colors: number[]): string[] {
  const rgbaColors: string[] = [];
  for (let i = 0; i < colors.length; i += 4) {
    const r = Math.round(colors[i] * 255);
    const g = Math.round(colors[i + 1] * 255);
    const b = Math.round(colors[i + 2] * 255);
    const a = colors[i + 3];
    if (a !== 0) {
      rgbaColors.push(`rgba(${r},${g},${b},${a})`);
    }
  }
  return rgbaColors
}

/**
 * 这里的数据只在 非组合妆+可编辑状态下使用
 * 数据是复用的，点击切换后会重置到初始化状态，然后用模板值去设置对应值
 */
export class SubMakeupViewModel {
  labelArray: SubMakeupLabelModel[] = []
  labelArrayViews: HorizontalScrollLabelViewInterface[] = []
  // 选中的 label model
  selectLabel_model: SubMakeupLabelModel = {} as SubMakeupLabelModel
  selectLabel_index: number = 0

  constructor() {
    const str = FUNMFileUtil.readTextFromRawfile('makeup/CustomizedMakeup/customized_makeups.json');
    if (str) {
      this.labelArray = JSON.parse(str);
      this.labelArrayViews = this._scrollLabelDataSource()
      this.setUnCombinedAllowEditMakeupAllSubMakeUpToDefault()
    }
  }

  static isResetSubMakeupItem(item: SubMakeupItemModel) {
    if (item.icon === 'makeup_noitem') {
      return true
    }
    return false
  }

  /**
   * 获取子妆对应的 bundle 路径
   */
  static getSubMakeupBundlePathWithModel(subModel: SubMakeupItemModel) {
    switch (subModel.type) {
      case SubMakeupType.Foundation:
        // $rawfile('makeup/CustomizedMakeup/Foundataion/mu_style_foundation_01.bundle')
        return `makeup/CustomizedMakeup/Foundataion/${subModel.bundleName}.bundle`
      case SubMakeupType.Lip:
        // $rawfile('makeup/CustomizedMakeup/Lip/mu_style_foundation_01.bundle')
        return `makeup/CustomizedMakeup/Lip/${subModel.bundleName}.bundle`
      case SubMakeupType.Blusher:
        // $rawfile('makeup/CustomizedMakeup/Blusher/mu_style_blush_05.bundle')
        return `makeup/CustomizedMakeup/Blusher/${subModel.bundleName}.bundle`
      case SubMakeupType.Eyebrow:
        // $rawfile('makeup/CustomizedMakeup/Eyebrow/mu_style_eyebrow_04.bundle')
        return `makeup/CustomizedMakeup/Eyebrow/${subModel.bundleName}.bundle`
      case SubMakeupType.EyeShadow:
        // $rawfile('makeup/CustomizedMakeup/EyeShadow/mu_style_eyeshadow_07.bundle')
        return `makeup/CustomizedMakeup/EyeShadow/${subModel.bundleName}.bundle`
      case SubMakeupType.Eyeliner:
        // $rawfile('makeup/CustomizedMakeup/Eyeliner/mu_style_eyeliner_07.bundle')
        return `makeup/CustomizedMakeup/Eyeliner/${subModel.bundleName}.bundle`
      case SubMakeupType.Eyelash:
        // $rawfile('makeup/CustomizedMakeup/Eyelash/mu_style_eyelash_06.bundle')
        return `makeup/CustomizedMakeup/Eyelash/${subModel.bundleName}.bundle`
      case SubMakeupType.Highlight:
        // $rawfile('makeup/CustomizedMakeup/Highlight/mu_style_highlight_02.bundle')
        return `makeup/CustomizedMakeup/Highlight/${subModel.bundleName}.bundle`
      case SubMakeupType.Shadow:
        // $rawfile('makeup/CustomizedMakeup/Shadow/mu_style_contour_01.bundle')
        return `makeup/CustomizedMakeup/Shadow/${subModel.bundleName}.bundle`
      case SubMakeupType.Pupil:
        // $rawfile('makeup/CustomizedMakeup/Pupil/mu_style_eyepupil_09.bundle')
        return `makeup/CustomizedMakeup/Pupil/${subModel.bundleName}.bundle`
    }
    return undefined
  }

  /**
   * 校验子妆是否选中有效值
   * describe: xxx
   */
  checkSubMakeupSelectIsValid(): boolean {
    for (let i = 0; i < this.labelArray.length; i++) {
      const labelModel: SubMakeupLabelModel = this.labelArray[i]
      if (labelModel.u_sgArr_select_index > 0) {
        return true
      }
    }
    return false
  }

  // 是否需要显示颜色选择器
  needShowColorPicker(): boolean {
    if (this.selectLabel_model.u_sgArr_select_model &&
      !SubMakeupViewModel.isResetSubMakeupItem(this.selectLabel_model.u_sgArr_select_model) &&
    this.selectLabel_model.u_sgArr_select_model.colors &&
    this.selectLabel_model.u_sgArr_select_model.colors.length &&
      this.selectLabel_model.u_sgArr_select_model.type !== SubMakeupType.Foundation) {
      return true
    }
    return false
  }

  /**
   * 设置 非组合妆+可编辑 妆的所有子妆值为默认值(json值)
   */
  setUnCombinedAllowEditMakeupAllSubMakeUpToDefault() {
    for (let i = 0; i < this.labelArray.length; i++) {
      const labelModel: SubMakeupLabelModel = this.labelArray[i]

      // 更新 badge
      const label_view: HorizontalScrollLabelViewInterface = this.labelArrayViews[i]
      label_view.showBadge = false

      // 设置 label UI 数据源
      if (!labelModel.u_sgArr_views || labelModel.u_sgArr_views.length === 0) {
        labelModel.u_sgArr_views = this._scrollItemDataSource(labelModel)
      }

      // 每个 label 子项选中「卸妆」
      labelModel.u_sgArr_select_index = 0
      labelModel.u_sgArr_select_view = labelModel.u_sgArr_views[labelModel.u_sgArr_select_index]
      labelModel.u_sgArr_select_model = labelModel.sgArr[labelModel.u_sgArr_select_index]

      // 设置每个子 item 默认选中的颜色值，取 json 配置项
      for (let j = 0; j < labelModel.sgArr.length; j++) {
        const item: SubMakeupItemModel = labelModel.sgArr[j]
        item.u_selectColor_index = item.defaultColorIndex
      }

      // 设置默认选中 label
      if (i === this.selectLabel_index) {
        this.selectLabel_model = labelModel
      }
    }
  }

  private _scrollItemId(item: SubMakeupItemModel, index: number): string {
    if (item.colors && item.colors.length > item.defaultColorIndex) {
      const defaultColor: number[] = item.colors[item.defaultColorIndex]
      const imgBgColor = formatColors(defaultColor)?.[0] || ''
      if (item.icon) {
        return `${item.icon}-${imgBgColor}-${index}`
      }
      return `${imgBgColor}-${index}`
    } else {
      return `${item.icon}-${index}`
    }
  }

  private _scrollLabelId(item: SubMakeupLabelModel, index: number): string {
    return `${item.name}_${index}`
  }

  private _scrollItemDataSource(model: SubMakeupLabelModel): HorizontalScrollViewItemInterface[] {
    if (model.name === '粉底') {
      // 粉底没有图片，只有背景颜色
      return model.sgArr.map((item: SubMakeupItemModel, index) => {
        if (SubMakeupViewModel.isResetSubMakeupItem(item)) {
          // 如果是卸妆，用默认图片
          const imageUrl = $rawfile(`makeup/subItems/${item.icon}@2x.png`)
          return { id: this._scrollItemId(item, index), imageUrl } as HorizontalScrollViewItemInterface
        }
        const defaultColor: number[] = item.colors[item.defaultColorIndex]
        const imgBgColor = formatColors(defaultColor)?.[0]
        return { id: this._scrollItemId(item, index), imgBgColor } as HorizontalScrollViewItemInterface
      })
    }
    return model.sgArr.map((item: SubMakeupItemModel, index) => {
      const path = `makeup/subItems/${item.icon}@2x.png`
      const imageUrl = $rawfile(path)
      return { id: this._scrollItemId(item, index), imageUrl } as HorizontalScrollViewItemInterface
    })
  }

  private _scrollLabelDataSource(): HorizontalScrollLabelViewInterface[] {
    return this.labelArray.map((item: SubMakeupLabelModel, index: number) => {
      return {
        id: this._scrollLabelId(item, index),
        label: item.name
      } as HorizontalScrollLabelViewInterface
    })
  }
}