import { SubMakeupItemModel, SubMakeupLabelModel, SubMakeupType, SubMakeupViewModel } from './SubMakeupViewModel';
import { MakeUpModel, MakeUpTemplateValueInterface, MakeUpViewModel } from './MakeUpViewModel';
import {
  FUNMItem,
  FUNMMakeup,
  FUNMMakeupLipType,
  FUNMRenderKit,
  FUNMColor
} from '@faceunity/renderkit_nama';
import { HorizontalScrollLabelViewInterface } from '../../components/makeup/HorizontalScrollLabelView';

class MakeUpViewModelController {
  private static instance: MakeUpViewModelController | undefined;
  subMakeupViewModel: SubMakeupViewModel;
  makeUpViewModel: MakeUpViewModel;
  // 保存进入页面时候的美妆初始值
  cache_beauty_filterName: string = ''
  cache_beauty_filterLevel: number = 0

  constructor() {
    this.subMakeupViewModel = new SubMakeupViewModel();
    this.makeUpViewModel = new MakeUpViewModel();
  }

  static sharedInstance(): MakeUpViewModelController {
    if (!MakeUpViewModelController.instance) {
      MakeUpViewModelController.instance = new MakeUpViewModelController();
    }
    return MakeUpViewModelController.instance;
  }

  static destroy() {
    MakeUpViewModelController.instance = undefined;
  }

  // 函数命名规则：xxxDelegateAction，是需要在 page 页面实现的，xxxAction 是需要当前 controller 实现的

  // 子妆 item 点击了
  onSubMakeupItemDelegateAction = (_item: SubMakeupItemModel) => {
  }
  // 子妆 label 点击了
  onSubMakeupLabelDelegateAction = (_item: SubMakeupLabelModel) => {
  }
  // 子妆 点击了返回
  onSubMakeupViewHiddenDelegateAction = () => {
  }
  // 子妆 点击了自定义
  onSubMakeupViewShowDelegateAction = () => {
  }

  // 相机切换
  onCameraSwitch() {
    const isFlipPoints: boolean = FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera ? false : true
    FUNMRenderKit.sharedInstance().makeup!.isFlipPoints = isFlipPoints
  }

  /**
   * 用模板值初始化当前选择风格
   * 每个主妆对应的每个子妆
   */
  set_unCombined_makeUpValue_withTemplateValue() {
    const selectMakeup = this.makeUpViewModel.selectMakeup_model
    if (selectMakeup.isCombined) {
      // 组合妆没有子项，不需要更新
      return
    }

    const labelArray = this.subMakeupViewModel.labelArray
    // 当前选中的主妆 value 值
    const makeupValue = selectMakeup.value

    /**
     * 对于不可编辑的非组合妆，每个子妆 select_xxx 通过懒加载的方式初始化，然后赋值模版值
     * describe: xxx
     */
    if (!selectMakeup.isAllowedEdit) {
      for (let i = 0; i < labelArray.length; i++) {
        const labelModel: SubMakeupLabelModel = labelArray[i]
        const labelName = labelModel.name
        const templateValue: MakeUpTemplateValueInterface =
          this.makeUpViewModel.getMakeupTemplateModelWithLabel(labelModel.name)
        const newValue = Number((templateValue?.value * makeupValue).toFixed(2))
        if (labelName === '粉底') {
          if (!selectMakeup.select_foundationModel) {
            selectMakeup.select_foundationModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_foundationModel.value = newValue
        } else if (labelName === '口红') {
          if (!selectMakeup.select_lipstickModel) {
            selectMakeup.select_lipstickModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_lipstickModel.value = newValue
          selectMakeup.select_lipstickModel.isTwoColorLipstick = templateValue?.isTwoColorLipstick ?? false
          selectMakeup.select_lipstickModel.lipstickType = templateValue?.lipstickType ?? 0
        } else if (labelName === '腮红') {
          if (!selectMakeup.select_blusherModel) {
            selectMakeup.select_blusherModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_blusherModel.value = newValue
        } else if (labelName === '眉毛') {
          if (!selectMakeup.select_eyebrowModel) {
            selectMakeup.select_eyebrowModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_eyebrowModel.value = newValue
          selectMakeup.select_eyebrowModel.isBrowWarp = templateValue?.isBrowWarp ?? false
          selectMakeup.select_eyebrowModel.browWarpType = templateValue?.browWarpType ?? 0
        } else if (labelName === '眼影') {
          if (!selectMakeup.select_eyeShadowModel) {
            selectMakeup.select_eyeShadowModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_eyeShadowModel.value = newValue
        } else if (labelName === '眼线') {
          if (!selectMakeup.select_eyelinerModel) {
            selectMakeup.select_eyelinerModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_eyelinerModel.value = newValue
        } else if (labelName === '睫毛') {
          if (!selectMakeup.select_eyelashModel) {
            selectMakeup.select_eyelashModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_eyelashModel.value = newValue
        } else if (labelName === '高光') {
          if (!selectMakeup.select_highlightModel) {
            selectMakeup.select_highlightModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_highlightModel.value = newValue
        } else if (labelName === '阴影') {
          if (!selectMakeup.select_shadowModel) {
            selectMakeup.select_shadowModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_shadowModel.value = newValue
        } else if (labelName === '美瞳') {
          if (!selectMakeup.select_pupilModel) {
            selectMakeup.select_pupilModel = {} as SubMakeupItemModel
          }
          selectMakeup.select_pupilModel.value = newValue
        }
      }
      return
    }

    /**
     * 可编辑非组合妆，子妆 select_xxx , 在 viewModel 中 setUnCombinedAllowEditMakeupAllSubMakeUpToDefault 已经赋值
     * describe: xxx
     */
    const labelArrayViews = this.subMakeupViewModel.labelArrayViews
    for (let i = 0; i < labelArray.length; i++) {
      const labelModel: SubMakeupLabelModel = labelArray[i]
      const templateValue: MakeUpTemplateValueInterface =
        this.makeUpViewModel.getMakeupTemplateModelWithLabel(labelModel.name)

      /**
       * 代码执行到这里的时候，labelModel.u_sgArr_select_model 一定不是 undefined，在 viewModel 初始化时已经赋值了
       * 只更新模版值指定选中的 item 项目
       */
      if (templateValue.subMakeupItem_index && templateValue.subMakeupItem_index > 0) {
        labelModel.u_sgArr_select_index = templateValue.subMakeupItem_index
        labelModel.u_sgArr_select_view = labelModel.u_sgArr_views[labelModel.u_sgArr_select_index]
        labelModel.u_sgArr_select_model = labelModel.sgArr[labelModel.u_sgArr_select_index]
        //note: 子妆的 value 是最终渲染的值，templateValue 相当于主妆容的 value 值
        labelModel.u_sgArr_select_model.value = templateValue?.value * makeupValue
      }

      if (labelModel.name === '口红') {
        labelModel.u_sgArr_select_model.isTwoColorLipstick = templateValue?.isTwoColorLipstick ?? false
        labelModel.u_sgArr_select_model.lipstickType = templateValue?.lipstickType ?? 0
      } else if (labelModel.name === '眉毛') {
        labelModel.u_sgArr_select_model.isBrowWarp = templateValue?.isBrowWarp ?? false
        labelModel.u_sgArr_select_model.browWarpType = templateValue?.browWarpType ?? 0
      }

      // 更新 badge
      const label_view: HorizontalScrollLabelViewInterface = labelArrayViews[i]
      label_view.showBadge = SubMakeupViewModel.isResetSubMakeupItem(labelModel.u_sgArr_select_model) ? false : true

      // 设置选中 item 默认选中的颜色值
      if (templateValue.subMakeupItem_color_index !== labelModel.u_sgArr_select_model.defaultColorIndex) {
        labelModel.u_sgArr_select_model.u_selectColor_index = templateValue?.subMakeupItem_color_index ?? 0
      }

      // 给当前 makeup 绑定当前选中的子妆 item，改变主妆的程度值时需要更新每个子妆的的程度值
      this._bindSubMakeupToMakeup(selectMakeup, labelModel.u_sgArr_select_model, labelModel.name)
    }
  }

  // 主 bundle 变更
  onMakeupSelectDidChange() {
    // 先释放
    if(FUNMRenderKit.sharedInstance().makeup) {
      FUNMRenderKit.sharedInstance().makeup?.destroy()
      FUNMRenderKit.sharedInstance().makeup = undefined
    }

    // 卸妆
    if (this.makeUpViewModel.isSelectResetMakeup()) {
      // 更新美颜滤镜
      if (FUNMRenderKit.sharedInstance().beauty) {
        FUNMRenderKit.sharedInstance().beauty!.filterName = 'origin'
        FUNMRenderKit.sharedInstance().beauty!.filterLevel = 0
      }
      //note: 这行代码不能少，卸妆后点击自定义会用 face_makeup 初始化 makeup
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
      return
    }

    const makeupModel: MakeUpModel = this.makeUpViewModel.selectMakeup_model

    // @note 嗲嗲兔、冻龄、国风、混血是8.0.0新加的四个组合妆，新组合妆只需要直接加载bundle，不需要绑定到face_makeup.bundle
    if (makeupModel.isCombined) {
      // 新组合妆，每次加载必须重新初始化
      const rawfilePath = `makeup/CombinationMakeup/Bundle/${makeupModel.bundleName}.bundle`;
      const makeup = new FUNMMakeup({ rawfilePath: rawfilePath });
      //高端机打开全脸分割
      makeup!.makeupSegmentation = true;
      FUNMRenderKit.sharedInstance().makeup = makeup;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()

      // 更新美颜滤镜
      this._updateBeautyFilter()
      // 新组合妆直接设置程度值
      FUNMRenderKit.sharedInstance().makeup!.intensity = makeupModel.value;

    } else {
      // 老组合妆, 先加载 face_makeup.bundle，再加载选择的 bundle
      const face_makeup = new FUNMMakeup({ rawfilePath: 'face_makeup.bundle' });
      //高端机打开全脸分割
      face_makeup.makeupSegmentation = true;
      FUNMRenderKit.sharedInstance().makeup = face_makeup;

      // 绑定组合装
      const rawfilePath = `makeup/CombinationMakeup/Bundle/${makeupModel.bundleName}.bundle`;
      const makeup = new FUNMMakeup({ rawfilePath: rawfilePath });
      FUNMRenderKit.sharedInstance().makeup!.updateMakeupPackage(makeup, true)

      // 放在最后，否则会渲染会有抖动
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()

      // 更新美颜滤镜
      this._updateBeautyFilter()

      /**
       * 从实际效果来看，切换了 bundle，子妆的程度值已在 bundle 内置，不需要二次设置，为什么要计算和更新子 bundle 的 value 值呢 ？自定义子妆组件value值显示正确
       */
      // 计算最新的程度值
      this._update_unCombined_subMakeupValue_afterMakeupValueDidChange()
      // 更新程度值
      this._update_unCombined_makeup_Intensity()
    }
  }

  /**
   * 主 bundle slider value change
   * 1. 更新非组合妆每个子 item 的 value 值
   * 2. 更新 beauty 相关属性
   * 3. 更新 renderkit 每个子妆的值
   */
  onMakeupSliderValueDidChange() {
    const makeupModel: MakeUpModel = this.makeUpViewModel.selectMakeup_model
    if (makeupModel.isCombined) {
      this._updateBeautyFilter()
      // 新组合妆直接设置
      FUNMRenderKit.sharedInstance().makeup!.intensity = makeupModel.value;
    } else {
      this._update_unCombined_subMakeupValue_afterMakeupValueDidChange()
      this._updateBeautyFilter()
      this._update_unCombined_makeup_Intensity()
    }
  }

  /**
   * 切换了子妆 item
   * 卸妆场景特殊处理: 如果是在卸妆场景，此时 makeup === undefined，主妆加载 face_makeup
   */
  onSubMakeupSelectDidChange() {

    // 如果点击了卸妆，在点击了子妆，此时 makeup === undefined
    if (FUNMRenderKit.sharedInstance().makeup === undefined) {
      const face_makeup = new FUNMMakeup({ rawfilePath: 'face_makeup.bundle' });
      //高端机打开全脸分割
      face_makeup.makeupSegmentation = true;
      FUNMRenderKit.sharedInstance().makeup = face_makeup;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    }

    // 更新当前选中 makeup bind 的 subMakeup item
    this._bindSubMakeupToMakeup(this.makeUpViewModel.selectMakeup_model,
      this.subMakeupViewModel.selectLabel_model.u_sgArr_select_model, this.subMakeupViewModel.selectLabel_model.name)

    // 更新 bundle
    this._updateSubMakeupBundle()
    // 更新颜色
    this._updateSubMakeupColor()
    // 更新 强度
    this._updateSubMakeupIntensity()
  }

  // 子妆item 强度值改变
  onSubMakeupSliderValueDidChange() {
    // 更新 强度
    this._updateSubMakeupIntensity()
  }

  // 子妆颜色值改变
  onSubMakeupColorPickerValueDidChange() {
    this._updateSubMakeupColor()
  }

  /**
   * 子妆 item 变更后调用，重新赋值当前主妆对应的子妆 model
   * makeup: 主妆 model
   * subMakeup：子妆 model
   * inLabel：在哪个 label 标签下
   */
  private _bindSubMakeupToMakeup(makeup: MakeUpModel, subMakeup: SubMakeupItemModel, inLabel: string) {
    const selectMakeup = makeup
    const labelName = inLabel
    if (labelName === '粉底') {
      selectMakeup.select_foundationModel = subMakeup
    } else if (labelName === '口红') {
      selectMakeup.select_lipstickModel = subMakeup
    } else if (labelName === '腮红') {
      selectMakeup.select_blusherModel = subMakeup
    } else if (labelName === '眉毛') {
      selectMakeup.select_eyebrowModel = subMakeup
    } else if (labelName === '眼影') {
      selectMakeup.select_eyeShadowModel = subMakeup
    } else if (labelName === '眼线') {
      selectMakeup.select_eyelinerModel = subMakeup
    } else if (labelName === '睫毛') {
      selectMakeup.select_eyelashModel = subMakeup
    } else if (labelName === '高光') {
      selectMakeup.select_highlightModel = subMakeup
    } else if (labelName === '阴影') {
      selectMakeup.select_shadowModel = subMakeup
    } else if (labelName === '美瞳') {
      selectMakeup.select_pupilModel = subMakeup
    }
  }

  /**
   * 只有非组合妆才更新子妆程度值
   * 主妆程度值变更后更新子妆程度值
   * 子妆实际值=子妆程度值系数*主妆程度值
   * 注意：对于可编辑的非组合妆，如果选择了卸妆，则不更新该子妆,否则会修改卸妆的程度值(卸妆的程度值是不能被修改的)
   */
  private _update_unCombined_subMakeupValue_afterMakeupValueDidChange() {
    const makeupModel: MakeUpModel = this.makeUpViewModel.selectMakeup_model
    if (makeupModel.isCombined) {
      return
    }

    if (makeupModel.isAllowedEdit) {
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_foundationModel)) {
        makeupModel.select_foundationModel.value =
          Number((makeupModel.foundationModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_lipstickModel)) {
        makeupModel.select_lipstickModel.value =
          Number((makeupModel.lipstickModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_blusherModel)) {
        makeupModel.select_blusherModel.value = Number((makeupModel.blusherModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_eyebrowModel)) {
        makeupModel.select_eyebrowModel.value = Number((makeupModel.eyebrowModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_eyeShadowModel)) {
        makeupModel.select_eyeShadowModel.value =
          Number((makeupModel.eyeShadowModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_eyelinerModel)) {
        makeupModel.select_eyelinerModel.value =
          Number((makeupModel.eyelinerModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_eyelashModel)) {
        makeupModel.select_eyelashModel.value = Number((makeupModel.eyelashModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_highlightModel)) {
        makeupModel.select_highlightModel.value =
          Number((makeupModel.highlightModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_shadowModel)) {
        makeupModel.select_shadowModel.value = Number((makeupModel.shadowModel.value * makeupModel.value).toFixed(2));
      }
      if (!SubMakeupViewModel.isResetSubMakeupItem(makeupModel.select_pupilModel)) {
        makeupModel.select_pupilModel.value = Number((makeupModel.pupilModel.value * makeupModel.value).toFixed(2));
      }

    } else {
      makeupModel.select_foundationModel.value =
        Number((makeupModel.foundationModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_lipstickModel.value = Number((makeupModel.lipstickModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_blusherModel.value = Number((makeupModel.blusherModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_eyebrowModel.value = Number((makeupModel.eyebrowModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_eyeShadowModel.value =
        Number((makeupModel.eyeShadowModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_eyelinerModel.value = Number((makeupModel.eyelinerModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_eyelashModel.value = Number((makeupModel.eyelashModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_highlightModel.value =
        Number((makeupModel.highlightModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_shadowModel.value = Number((makeupModel.shadowModel.value * makeupModel.value).toFixed(2));
      makeupModel.select_pupilModel.value = Number((makeupModel.pupilModel.value * makeupModel.value).toFixed(2));
    }
  }

  /**
   * 更新非组合妆 更新makeup 每一子项的程度值
   */
  private _update_unCombined_makeup_Intensity() {
    const makeupModel: MakeUpModel = this.makeUpViewModel.selectMakeup_model
    if (makeupModel.isCombined) {
      return
    }

    // 老组合妆需要设置所有子妆值，子妆实际值=组合妆值*子妆默认值
    const makeup: FUNMMakeup = FUNMRenderKit.sharedInstance().makeup as FUNMMakeup
    // 粉底
    makeup.intensityFoundation = makeupModel.select_foundationModel.value
    // 口红
    makeup.lipType = makeupModel.select_lipstickModel.lipstickType;
    makeup.isTwoColor = makeupModel.select_lipstickModel.isTwoColorLipstick;
    makeup.intensityLip = makeupModel.select_lipstickModel.value;
    if (makeup.lipType == FUNMMakeupLipType.Moisturizing) {
      // 润泽Ⅱ口红时需要开启口红高光，高光暂时为固定值
      makeup.isLipHighlightOn = true;
      makeup.intensityLipHighlight = 0.8;
    } else {
      makeup.isLipHighlightOn = false;
      makeup.intensityLipHighlight = 0;
    }
    // 其他
    makeup.intensityBlusher = makeupModel.select_blusherModel.value
    makeup.intensityEyebrow = makeupModel.select_eyebrowModel.value
    makeup.intensityEyeshadow = makeupModel.select_eyeShadowModel.value
    makeup.intensityEyeliner = makeupModel.select_eyelinerModel.value
    makeup.intensityEyelash = makeupModel.select_eyelashModel.value
    makeup.intensityHighlight = makeupModel.select_highlightModel.value
    makeup.intensityShadow = makeupModel.select_shadowModel.value
    makeup.intensityPupil = makeupModel.select_pupilModel.value
  }

  /**
   * 更新美颜滤镜
   * describe: xxx
   */
  private _updateBeautyFilter() {
    const makeupModel: MakeUpModel = this.makeUpViewModel.selectMakeup_model

    if (makeupModel.isCombined) {
      // 恢复美颜滤镜为原图效果
      if (FUNMRenderKit.sharedInstance().beauty) {
        FUNMRenderKit.sharedInstance()!.beauty!.filterName = 'origin'
      }
      // 更新美颜滤镜
      FUNMRenderKit.sharedInstance().makeup!.filterIntensity =
        Number((makeupModel.value * makeupModel.selectedFilterLevel).toFixed(2));
    } else {
      // 设置滤镜
      if (FUNMRenderKit.sharedInstance().beauty) {
        FUNMRenderKit.sharedInstance()!.beauty!.filterName = makeupModel.selectedFilter || 'origin'
        FUNMRenderKit.sharedInstance()!.beauty!.filterLevel = makeupModel.value
      }
    }
  }

  // 子 bundle 切换
  private _updateSubMakeupBundle() {
    const selectSubMakeupItem = this.subMakeupViewModel.selectLabel_model.u_sgArr_select_model
    if (!selectSubMakeupItem.bundleName) {
      // 如果选择了卸妆，没有 bundle 信息
      return
    }
    const subBundlePath = SubMakeupViewModel.getSubMakeupBundlePathWithModel(selectSubMakeupItem)
    const subMakeupBundle = new FUNMItem({ rawfilePath: subBundlePath });
    const makeUp: FUNMMakeup = FUNMRenderKit.sharedInstance().makeup as FUNMMakeup
    switch (selectSubMakeupItem.type) {
      case SubMakeupType.Foundation:
        makeUp.subFoundation = subMakeupBundle
        break
      case SubMakeupType.Lip:
        makeUp.subLip = subMakeupBundle
        break
      case SubMakeupType.Blusher:
        makeUp.subBlusher = subMakeupBundle
        break
      case SubMakeupType.Eyebrow:
        makeUp.subEyebrow = subMakeupBundle
        break
      case SubMakeupType.EyeShadow:
        makeUp.subEyeshadow = subMakeupBundle
        break
      case SubMakeupType.Eyeliner:
        makeUp.subEyeliner = subMakeupBundle
        break
      case SubMakeupType.Eyelash:
        makeUp.subEyelash = subMakeupBundle
        break
      case SubMakeupType.Highlight:
        makeUp.subHighlight = subMakeupBundle
        break
      case SubMakeupType.Shadow:
        makeUp.subShadow = subMakeupBundle
        break
      case SubMakeupType.Pupil:
        makeUp.subPupil = subMakeupBundle
        break
    }
  }

  private _updateSubMakeupColor() {
    const selectSubMakeupItem = this.subMakeupViewModel.selectLabel_model.u_sgArr_select_model
    // note: 这里特殊处理，粉底没有颜色选择器，选中第几个颜色值用当前 item 的 defaultColorIndex
    if (selectSubMakeupItem.type === SubMakeupType.Foundation) {
      selectSubMakeupItem.u_selectColor_index = selectSubMakeupItem.defaultColorIndex
    }

    if (selectSubMakeupItem.colors === undefined ||
      selectSubMakeupItem.colors.length <=
      selectSubMakeupItem.u_selectColor_index) {
      return
    }
    const color =
      selectSubMakeupItem.colors[this.subMakeupViewModel.selectLabel_model.u_sgArr_select_model.u_selectColor_index]
    const fuColor = new FUNMColor(color[0], color[1], color[2], color[3])
    const makeUp: FUNMMakeup = FUNMRenderKit.sharedInstance().makeup as FUNMMakeup
    switch (selectSubMakeupItem.type) {
      case SubMakeupType.Foundation:
        makeUp.foundationColor = fuColor
        break
      case SubMakeupType.Lip:
        makeUp.lipColor = fuColor
        break
      case SubMakeupType.Blusher:
        makeUp.blusherColor = fuColor
        break
      case SubMakeupType.Eyebrow:
        makeUp.eyebrowColor = fuColor
        break
      case SubMakeupType.EyeShadow:
        makeUp.setEyeColors(
          new FUNMColor(0, 0, 0, 0),
          new FUNMColor(color[0], color[1], color[2], color[3]),
          new FUNMColor(color[4], color[5], color[6], color[7]),
          new FUNMColor(color[8], color[9], color[10], color[11]),
        )
        break
      case SubMakeupType.Eyeliner:
        makeUp.eyelinerColor = fuColor
        break
      case SubMakeupType.Eyelash:
        makeUp.eyelashColor = fuColor
        break
      case SubMakeupType.Highlight:
        makeUp.highlightColor = fuColor
        break
      case SubMakeupType.Shadow:
        makeUp.shadowColor = fuColor
        break
      case SubMakeupType.Pupil:
        makeUp.pupilColor = fuColor
        break
    }
  }

  private _updateSubMakeupIntensity() {
    const selectSubMakeupItem = this.subMakeupViewModel.selectLabel_model.u_sgArr_select_model
    const makeUp: FUNMMakeup = FUNMRenderKit.sharedInstance().makeup as FUNMMakeup
    switch (selectSubMakeupItem.type) {
      case SubMakeupType.Foundation:
        makeUp.intensityFoundation = selectSubMakeupItem.value
        break
      case SubMakeupType.Lip:
        makeUp.lipType = selectSubMakeupItem.lipstickType
        makeUp.isTwoColor = selectSubMakeupItem.isTwoColorLipstick
        makeUp.intensityLip = selectSubMakeupItem.value
        if (makeUp.lipType === FUNMMakeupLipType.Moisturizing) {
          // 润泽Ⅱ口红时需要开启口红高光，高光暂时为固定值0.8
          makeUp.isLipHighlightOn = true
          makeUp.intensityLipHighlight = 0.8
        } else {
          makeUp.isLipHighlightOn = false
          makeUp.intensityLipHighlight = 0
        }
        break
      case SubMakeupType.Blusher:
        makeUp.intensityBlusher = selectSubMakeupItem.value
        break
      case SubMakeupType.Eyebrow:
        makeUp.intensityEyebrow = selectSubMakeupItem.value
        break
      case SubMakeupType.EyeShadow:
        makeUp.intensityEyeshadow = selectSubMakeupItem.value
        break
      case SubMakeupType.Eyeliner:
        makeUp.intensityEyeliner = selectSubMakeupItem.value
        break
      case SubMakeupType.Eyelash:
        makeUp.intensityEyelash = selectSubMakeupItem.value
        break
      case SubMakeupType.Highlight:
        makeUp.intensityHighlight = selectSubMakeupItem.value
        break
      case SubMakeupType.Shadow:
        makeUp.intensityShadow = selectSubMakeupItem.value
        break
      case SubMakeupType.Pupil:
        makeUp.intensityPupil = selectSubMakeupItem.value
        break
    }
  }
}

const MakeUpVCInstance: MakeUpViewModelController = MakeUpViewModelController.sharedInstance()

export { MakeUpViewModelController, MakeUpVCInstance }