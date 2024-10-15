## FUNMAIKit

AI 功能核心类

```TypeScript
/**
 * 人体分割模式
 */
export enum FUHumanSegmentationMode {
  /**
   * CPU通用模式
   */
  CPU_COMMON = 0x00,
  /**
   * GPU通用模式
   */
  GPU_COMMON = 0x01,
  /**
   * GPU会议模式
   */
  GPU_MEETING = 0x02
}

/**
 * 人脸检测模式
 */
export enum FUNMFaceProcessorDetectMode {
  Image,
  Video,
}

/**
 * 人脸点位算法质量
 */
export enum FUNMFaceProcessorFaceLandmarkQuality {
  Low,
  Medium,
  High
}


export class FUNMAIKit {
  /**
   * 图像的原始朝向（默认朝上）
   */
  imageOrientation: FUNMImageOrientation = FUNMImageOrientation.UP;
  /**
   * 数据是不是来自前置摄像头（默认 true）
   */
  isFrontCamera: boolean = true;

  /**
   * 设置最大的人脸跟踪个数 default is 1
   * @param value 人脸跟踪个数
   */
  set maxTrackFaces(value: number)

  /**
   * 获取设置的最大人脸跟踪个数
   * @returns 人脸跟踪个数 number
   */
  get maxTrackFaces()

  /**
   * 设置人脸检测模式 default is FUFaceProcessorDetectModeVideo
   * @param value 人脸检测模式
   */
  set faceProcessorDetectMode(value: FUNMFaceProcessorDetectMode)

  /**
   * 获取设置的人脸检测模式
   * @returns 人脸检测模式 FUNMFaceProcessorDetectMode
   */
  get faceProcessorDetectMode()

  /**
   * 设置人脸算法质量
   * @param value 人脸算法质量
   */
  set faceProcessorFaceLandmarkQuality(value: FUNMFaceProcessorFaceLandmarkQuality)

  /**
   * 获取设置的人脸算法质量
   * @returns 人脸算法质量 FUNMFaceProcessorFaceLandmarkQuality
   */
  get faceProcessorFaceLandmarkQuality()
  /**
   * 是否开启重力检测
   * @param value 是/否
   */
  set gravityEnable(value: boolean)

  /**
   * 设置待检测图像的最终朝向
   * @param value 图像朝向
   */
  set finalImageOrientation(value: FUNMImageOrientation)

  /**
   * 获取设置的待检测图像的最终朝向
   * @returns 图像朝向 FUNMImageOrientation
   */
  get finalImageOrientation()

  /**
   * 获取 FUNMAIKit 单例对象
   * @returns FUNMAIKit 单例对象
   */
  static shareKit(): FUNMAIKit

  /**
   * 销毁 FUNMAIKit 单例
   */
  static destroy()

  /**
   * 加载AI模型
   * @param type AI类型
   * @param path 模型文件路径
   */
  static loadAIModeWithAIType(type: FUAITYPE, path: FUNMPathInfo)

  /**
   * 卸载所有的AI模型
   */
  static unloadAllAIMode() 

  /**
   * 卸载特定类型的AI模型
   * @param type AI类型
   */
  static unloadAIModeForAIType(type: FUAITYPE)
}
```

## FUNMAutoRenderConfig

自动渲染配置

```TypeScript
/**
 * 自动渲染配置
 */
export class FUNMAutoRenderConfig {
  /**
   * 帧率
   */
  fps: number = 30;
  /**
   * 相机分辨率（如果指定的分辨率查找不到对应的相机配置，会默认使用相机预览配置的第一个）
   */
  camaraResolution: Size = { width: 1280, height: 720 };
  /**
   * 输出类型
   */
  outputType: FUNMOutputType = FUNMOutputType.XCOMPONENT;
  /**
   * 是否使用前置摄像头
   */
  isFrontCamera: boolean = true;
  /**
   * 前置摄像头时的纹理旋转矩阵
   */
  frontCameraTextureMatrix: FU_TRANSFORM_MATRIX = FU_TRANSFORM_MATRIX.CCROT90_FLIPHORIZONTAL;
  /**
   * 前置摄像头时buffer旋转矩阵
   */
  frontCameraBufferMatrix: FU_TRANSFORM_MATRIX = FU_TRANSFORM_MATRIX.CCROT90_FLIPHORIZONTAL;
  /**
   * 后置摄像头时的纹理旋转矩阵
   */
  backCameraTextureMatrix: FU_TRANSFORM_MATRIX = FU_TRANSFORM_MATRIX.CCROT270;
  /**
   * 后置摄像头时buffer旋转矩阵
   */
  backCameraBufferMatrix: FU_TRANSFORM_MATRIX = FU_TRANSFORM_MATRIX.CCROT270;
}
```

## FUNMCamera

相机

```TypeScript
/**
 * 相机代理
 */
export interface FUNMCameraDelegate {
  /**
   * 输出相机buffer
   * @param buffer
   */
  didOutputCameraBuffer(buffer: ArrayBuffer): void;
}

export class FUNMCamera {
  /**
   * 用来预览的 surfaceId 数组
   */
  surfaceIds: string[] | undefined = undefined;
  /**
   * 代理对象
   */
  delegate: FUNMCameraDelegate | undefined = undefined;
  /**
   * 相机buffer回调，效果跟 FUNMCameraDelegate 一样，按喜好决定使用那种方式
   */
  bufferCallBack: ((buffer: ArrayBuffer) => void) | undefined = undefined;
  /**
   * 是否是前置摄像头
   */
  isFrontCamera: boolean = true;
  /**
   * 分辨率
   */
  resolution: Size | undefined = undefined;

  /**
   * 初始化设置，达到待开启渲染的状态
   */
  async setup() 

  /**
   * 开始相机渲染
   */
  async startCamera() 

  /**
   * 停止相机渲染
   */
  async stopCamera() 

  /**
   * 相机销毁（内部会自动停掉相机，使用前不需要调用 stopCamera()）
   */
  async destroy() 

  /**
   * 相机前后摄像头切换
   * @param isFrontCamera
   */
  async cameraSwitch(isFrontCamera: boolean) 
}
```

## FUNMDisplayView

渲染页面，内部通过 XComponent 实现渲染

```TypeScript
@Component
export struct FUNMDisplayView {
  /**
   * 内部 XComponent 的di
   */
  viewId: string | undefined = undefined;
  /**
   * 内部 XComponent 的 libraryname
   */
  libraryName: string = 'funama_napi';
  /**
   * 内部 XComponent 的分辨率，设置后，待 XComponent onLoad完，与之绑定的 XComponentController 会调用 setXComponentSurfaceRect 方法完成设置
   */
  resolution: Size | undefined = undefined;
  /**
   * 内部 XComponent 的加载完成回调，此时可通过回调出去的 controller 实现如获取内部 XComponent 的 SurfaceId 的功能。
   */
  onLoadCallBack: ((controller: XComponentController) => void) | undefined = undefined;
}
```

## FUNMConstants

常量

```TypeScript
/**
 * 美颜属性模式，不同的模式使用的算法不同，呈现的效果也是不一样的，性能要求也是不同的；
 * 用户应该根据具体机型特征决定使用哪种模式，一般来说等级高的模式对于设备的要求更高。（模式等级：Mode3 > Mode2 > Mode2）
 */
export enum FUNMBeautyPropertyMode {
  Mode1 = 1,
  Mode2 = 2,
  Mode3 = 3
}

/**
 * 支持设置模式的key
 */
export enum FUNMModeKey {
  ColorLevel = 'color_level',
  RemovePouchStrength = 'remove_pouch_strength',
  RemoveNasolabialFoldsStrength = 'remove_nasolabial_folds_strength',
  CheekThinning = 'cheek_thinning',
  CheekNarrow = 'cheek_narrow',
  CheekSmall = 'cheek_small',
  EyeEnlarging = 'eye_enlarging',
  IntensityChin = 'intensity_chin',
  IntensityForehead = 'intensity_forehead',
  IntensityNose = 'intensity_nose',
  IntensityMouth = 'intensity_mouth'
}

/**
 * 原始图像的朝向
 */
export enum FUNMImageOrientation {
  UP,
  Right,
  Down,
  Left
}
```

## FUNMRenderIO

```TypeScript
/**
 * 输入的 Buffer 格式
 */
export enum FUNMInputBufferFormat {
  /**
   * BGRA 格式的buffer
   */
  BGRA_BUFFER,
  /**
   * RGBA 格式的buffer
   */
  RGBA_BUFFER,
  /**
   * NV21 格式的buffer
   */
  NV21_BUFFER,
  /**
   * NV12 格式的buffer
   */
  NV12_BUFFER,
}

/**
 * 输出的类型
 */
export enum FUNMOutputType {
  /**
   * 不展示，只输出 BGRA 格式的buffer
   */
  BGRA_BUFFER,
  /**
   * 不展示，只输出 RGBA 格式的buffer
   */
  RGBA_BUFFER,
  /**
   * 不展示，只输出 NV21 格式的buffer
   */
  NV21_BUFFER,
  /**
   * 不展示，只输出 NV12 格式的buffer
   */
  NV12_BUFFER,
  /**
   * 仅展示在 XComponent 上，不输出任何类型的buffer
   */
  XCOMPONENT,
  /**
   * 展示在 XComponent 上，并且输出 RGBA 类型的buffer
   */
  XCOMPONENT_WITH_RGBA_BUFFER,
  /**
   * 展示在 XComponent 上，并且输出 NV21 类型的buffer
   */
  XCOMPONENT_WITH_NV21_BUFFER
}

/**
 * 输出的数据类型
 */
export enum FUNMOutputDataType {
  /**
   * 数据是 BGRA 格式的buffer
   */
  BGRA_BUFFER,
  /**
   * 数据是 RGBA 格式的buffer
   */
  RGBA_BUFFER,
  /**
   * 数据是 NV21 格式的buffer
   */
  NV21_BUFFER,
  /**
   * 数据是 NV12 格式的buffer
   */
  NV12_BUFFER,
  /**
   * 非任何类型的buffer，表示仅展示在 XComponent 上
   */
  XCOMPONENT,
  /**
   * 渲染失败时返回
   */
  INVALID
}

/**
 * 👉渲染输入
 * 目前只支持 normalInput 或 cameraInput 作为输入，不支持两者同时作为输入
 */
export class FUNMRenderInput {
  /**
   * 常规的输入（buffer）
   */
  normalInput: FUNMNormalInput | undefined = undefined;
  /**
   * 相机输入
   */
  cameraInput: FUNMCameraInput | undefined = undefined;
  /**
   * 渲染配置项
   */
  renderConfig: FUNMRenderConfig;
  /**
   * 输入的尺寸，默认 1280 * 720
   */
  inputSize: Size = { width: 1280, height: 720 };
  /**
   * 纹理变换矩阵
   */
  textureMatrix: namaApi.FU_TRANSFORM_MATRIX = namaApi.FU_TRANSFORM_MATRIX.DEFAULT;
  /**
   * buffer变换矩阵
   */
  bufferMatrix: namaApi.FU_TRANSFORM_MATRIX = namaApi.FU_TRANSFORM_MATRIX.DEFAULT;
}

/**
 * 普通输入
 */
export class FUNMNormalInput {
  /**
   * 像素buffer
   */
  pixelBuffer: ArrayBuffer | undefined = undefined;
  /**
   * 像素buffer的格式
   */
  pixelFormat: FUNMInputBufferFormat = FUNMInputBufferFormat.RGBA_BUFFER;
  // texture: number | undefined = undefined;
}

/**
 * 📷相机输入
 */
export class FUNMCameraInput {
  /**
   * 相机纹理对象
   */
  nativeImage: namaApi.NativeImage | undefined = undefined;
  /**
   * 相机buffer接收对象
   */
  nativeReceiver: namaApi.ImageReceiver | undefined = undefined;
}

/**
 * ⚙️渲染配置
 */
export class FUNMRenderConfig {
  /**
   * 要展示在的 XComponent 上的 id
   */
  xcomponentId: string | undefined = undefined;
  /**
   * 要展示/输出的类型
   */
  outputType: FUNMOutputType = FUNMOutputType.XCOMPONENT;
}

/**
 * 👉渲染输出
 */
export class FUNMRenderOutput {
  /**
   * 输出数据的类型
   */
  dataType: FUNMOutputDataType = FUNMOutputDataType.XCOMPONENT;
  /**
   * 像素buffer
   */
  pixelBuffer: ArrayBuffer | undefined = undefined;
  /**
   * 输出的尺寸
   */
  outputSize: Size = { width: 720, height: 1280 };
}
```

## FUNMBeauty

美颜核心类，包含美肤、美型、美颜滤镜。

```TypeScript
export class FUNMBeauty extends FUNMItem {
  /**
   * 设置磨皮是否使用 mask
   * @param value 是否使用
   */
  set blurUseMask(value: boolean) 
  get blurUseMask(): boolean 

  /**
   * 朦胧磨皮开关 0清晰磨皮 1朦胧磨皮
   */
  set heavyBlur(value: number) 
  get heavyBlur(): number 

  /**
   * 磨皮类型  0清晰磨皮 1朦胧磨皮 2精细磨皮 3均匀磨皮
   * @note 此属性优先级比 heavyBlur 低, 在使用时要将 heavyBlur 设为0
   */
  set blurType(value: number)
  get blurType()

  /**
   * 皮肤分割（皮肤美白），YES开启，NO关闭，默认NO
   * @note 开启时美白效果仅支持皮肤区域，关闭时美白效果支持全局区域
   * @note 推荐非直播场景和 iPhoneXR 以上机型使用
   */
  set enableSkinSegmentation(value: boolean) 
  get enableSkinSegmentation() 

  /**
   * 肤色检测开关 0为关, 1为开，默认值0.0
   */
  set skinDetect(value: number) 
  get skinDetect() 

  /**
   * 肤色检测之后非肤色区域的融合程度 取值范围0.0-1.0，默认值0.0
   */
  set nonskinBlurScale(value: number) 
  get nonskinBlurScale() 

  /**
   * 精细磨皮 取值范围0.0-6.0, 默认6.0
   */
  set blurLevel(value: number) 
  get blurLevel() 

  /**
   * 祛斑痘，取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   * @note 硬件支持原因，祛斑痘仅支持 iPhoneXR 及以上机型使用
   */
  set antiAcneSpot(value: number) 
  get antiAcneSpot() 

  /**
   * 美白 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set colorLevel(value: number) 
  get colorLevel() 

  /**
   * 红润 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set redLevel(value: number) 
  get redLevel() 

  /**
   * 清晰 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set clarity(value: number) 
  get clarity() 

  /**
   * 锐化 取值范围0.0-1.0, 默认0.0
   */
  set sharpen(value: number) 
  get sharpen() 

  /**
   * 五官立体 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set faceThreed(value: number) 
  get faceThreed() 

  /**
   * 亮眼 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set eyeBright(value: number) 
  get eyeBright() 

  /**
   * 美牙 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set toothWhiten(value: number) 
  get toothWhiten() 

  /**
   * 去黑眼圈 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set removePouchStrength(value: number) 
  get removePouchStrength()

  /**
   * 去法令纹 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set removeNasolabialFoldsStrength(value: number) 
  get removeNasolabialFoldsStrength() 

  /**
   * 变形取值 0女神变形 1网红变形 2自然变形 3默认变形 4精细变形
   */
  set faceShape(value: number) 
  get faceShape() 

  /**
   * 渐变所需要的帧数 0为关闭渐变, 大于0开启渐变
   */
  set changeFrames(value: number) 
  get changeFrames()

  /**
   * 变形程度 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值1.0
   */
  set faceShapeLevel(value: number) 
  get faceShapeLevel() 

  /**
   * v脸 0.0-1.0，默认0.0
   */
  set cheekV(value: number) 
  get cheekV() 

  /**
   * 瘦脸 0.0-1.0，默认0.0
   */
  set cheekThinning(value: number) 
  get cheekThinning() 
  
  /**
   * 长脸 0.0-1.0，默认0.0
   */
  set cheekLong(value: number) 
  get cheekLong() 

  /**
   * 圆脸 0.0-1.0，默认0.0
   */
  set cheekCircle(value: number)
  get cheekCircle() 

  /**
   * 窄脸 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set cheekNarrow(value: number)
  get cheekNarrow() 

  /**
   * 小脸 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set cheekSmall(value: number) 
  get cheekSmall() 

  /**
   * 短脸 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set cheekShort(value: number) 
  get cheekShort()

  /**
   * 瘦颧骨 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensityCheekbones(value: number)
  get intensityCheekbones() 

  /**
   * 瘦下颌骨 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensityLowerJaw(value: number) 
  get intensityLowerJaw()

  /**
   * 大眼 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set eyeEnlarging(value: number) 
  get eyeEnlarging() 

  /**
   * 下巴 取值范围 0.0-1.0, 0.5-0是变小, 0.5-1是变大, 默认值0.5
   */
  set intensityChin(value: number)
  get intensityChin()

  /**
   * 额头 取值范围 0.0-1.0, 0.5-0是变小, 0.5-1是变大, 默认值0.5
   */
  set intensityForehead(value: number) 
  get intensityForehead() 

  /**
   * 瘦鼻 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensityNose(value: number) 
  get intensityNose() 

  /**
   * 嘴型 取值范围 0.0-1.0, 0.5-0.0是变大, 0.5-1.0是变小, 默认值0.5
   */
  set intensityMouth(value: number) 
  get intensityMouth()

  /**
   * 嘴唇厚度 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变薄, 0.5-1是变厚, 默认值0.5
   */
  set intensityLipThick(value: number) 
  get intensityLipThick() 

  /**
   * 眼睛位置 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变低, 0.5-1是变高, 默认值0.5
   */
  set intensityEyeHeight(value: number)
  get intensityEyeHeight()

  /**
   * 开眼角 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensityCanthus(value: number) 
  get intensityCanthus() 

  /**
   * 眼睑下至 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensityEyeLid(value: number) 
  get intensityEyeLid() 

  /**
   * 眼距 取值范围 0.0-1.0, 0.5-0.0是变大, 0.5-1.0是变小, 默认值0.5
   */
  set intensityEyeSpace(value: number) 
  get intensityEyeSpace() 

  /**
   * 眼睛角度 取值范围 0.0-1.0, 0.5-0.0逆时针旋转, 0.5-1.0顺时针旋转, 默认值0.5
   */
  set intensityEyeRotate(value: number) 

  get intensityEyeRotate() 

  /**
   * 长鼻 取值范围 0.0-1.0, 0.5-0.0是变长, 0.5-1.0是变短, 默认值0.5
   */
  set intensityLongNose(value: number) 
  get intensityLongNose() 

  /**
   * 缩人中 取值范围 0.0-1.0, 0.5-0.0是变短, 0.5-1.0是变长, 默认值0.5
   */
  set intensityPhiltrum(value: number) 
  get intensityPhiltrum() 

  /**
   * 微笑嘴角 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensitySmile(value: number) 
  get intensitySmile() 

  /**
   * 圆眼 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0
   */
  set intensityEyeCircle(value: number) 
  get intensityEyeCircle()

  /**
   * 眉毛上下 取值范围 0.0-1.0, 0.5-0是向上, 0.5-1是向下, 默认值0.5
   */
  set intensityBrowHeight(value: number) 
  get intensityBrowHeight()

  /**
   * 眉间距 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变小, 0.5-1是变大, 默认值0.5
   */
  set intensityBrowSpace(value: number)
  get intensityBrowSpace() 

  /**
   * 眉毛粗细 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变细, 0.5-1是变粗, 默认值0.5
   */
  set intensityBrowThick(value: number) 
  get intensityBrowThick() 

  /**
   * 设置美颜滤镜，字符串类型，默认值为 "origin" , 即为使用原图效果
   */
  set filterName(value: FUNMFilter | string)
  get filterName()

  /**
   * 美颜滤镜程度值 取值范围 0.0-1.0，0.0为无效果, 1.0为最大效果, 默认值1.0
   */
  set filterLevel(value: number) 
  get filterLevel() 
  
  /**
   * 重置属性到默认值的实现
   */
  resetToDefault()

  /**
   * 设置部分美颜属性的mode，不同mode会有主观上不同效果
   * 必须在设置美颜各个属性值之前调用该接口
   * @param mode 模式
   * @param key 支持设置模式的key
   */
  addBeautyPropertyMode(mode: FUNMBeautyPropertyMode, key: FUNMModeKey) 
}
```

## FUNMItem

道具类

```TypeScript
/**
 * 道具类
 */
export class FUNMItem {
  
  /**
   * 获取道具具柄
   * @returns 取道具具柄
   */
  get itemId(): number 

  /**
   * 根据路径信息构造道具类
   */
  constructor(path: FUNMPathInfo)

  /**
   * 道具资源释放
   */
  destroy()

  /**
   * 道具设置参数
   * @param name 参数名
   * @param param 参数值
   * @returns 结果值{number} 1 if success, 0 if failed
   */
  setParamForName(name: string, param: number | string): number 
}
```

## FUNMRenderKit

核心渲染类

```TypeScript
/**
 * 主要场景是使用自动渲染时，想获取渲染输出
 */
export interface FUNMAutoRenderDelegate {
  /**
   * 使用自动渲染时，处理图像后的输出
   * @param renderOutput 渲染后的结果
   */
  didAutoRender(renderOutput: FUNMRenderOutput): void;

  /**
   * 使用自动渲染时，内部是否进行render处理，返回false，将直接输出原图。
   */
  shouldDoAutoRender(): boolean
}

export interface FUNMFPSDelegate {
  /**
   * 获取自动渲染的帧率和单帧渲染时间（毫秒）
   * @param fps 帧率
   * @param renderTime 单帧渲染时间（毫秒）
   */
  renderFPSInfo(fps: number, renderTime: number): void;
}

export class FUNMRenderKit {
  //*******************************************
  /**
   * 渲染代理对象
   */
  renderDelegate: FUNMAutoRenderDelegate | undefined = undefined;
  /**
   * 帧率代理对象
   */
  fpsDelegate: FUNMFPSDelegate | undefined = undefined;
  /**
   * 目标 XComponent 的 id，渲染效果会呈现在上面
   */
  xcomponentId: string | undefined = undefined;
  /**
   * 贴纸道具
   */
  sticker: FUNMItem | undefined = undefined;
  /**
   * 美颜道具
   */
  beauty: FUNMBeauty | undefined = undefined;
  
  /**
   * 获取内部渲染使用到的 surfaceId 数组
   * @returns surfaceId 数组
   */
  get surfaceIds(): string[] | undefined 

  /**
   * 获取内部渲染使用的相机
   * @returns 相机
   */
  get camera(): FUNMCamera | undefined 
  
  /**
   * 获取自动渲染的配置信息
   * @returns
   */
  get autoRenderConfig(): FUNMAutoRenderConfig 

  /**
   * 获取 FUNMRenderKit 单例对象
   * @returns
   */
  static sharedInstance(): FUNMRenderKit 

  /**
   * SDK 初始化
   * @param config 配置
   */
  static setup(config: FUNMSetupConfig) 
  
  /**
   * 销毁 FUNMRenderKit 单例对象，及释放内部渲染资源
   */
  static async destroy(): Promise<void> 

  /**
   * 设置日志等级
   * @param logLevel
   */
  static setLogLevel(logLevel: namaApi.FULOGLEVEL) 
  
  /**
   * 核心渲染接口
   * 贴纸、美颜、美型、美妆、3D场景与形象配置到 RenderKit之后，调用该接口会把效果作用于输出的结果中。
   * @param input 渲染输入对象
   * @returns 渲染输出对象
   */
  static async renderWithInput(input: FUNMRenderInput): Promise<FUNMRenderOutput> 

  /**
   * 开启内部自动渲染，相机配置请修改 autoRenderSetting 相关属性
   */
  static async startAutoRender() 
  
  /**
   * 关闭内部自动渲染
   */
  static async stopAutoRender() 

  /**
   * 释放 OpenGL 资源，调用此接口起到清理部分的目的，不会造成渲染异常
   */
  static releaseGLResource() 

  /**
   * 清空自动渲染的渲染任务
   */
  static clearRenderTasks() 

  /**
   * 清空目标 XComponent 的画面（会呈现黑色）
   */
  static clearXComponent() 

  /**
   * 刷新自动渲染的输入
   * 当有自动渲染的配置、特效道具 发生变化的，需要调用此接口
   */
  refreshAutoRenderInput() 
}
```

## FUNMSetupConfig

FUNMRenderKit 的初始化配置类

```TypeScript
export class FUNMSetupConfig {
  /**
   * 证书的数据
   */
  authData: ArrayBuffer;
  /**
   * 证书数据的大小
   */
  authDataSize: number;
}
```

## FUNMFileUtil

【工具】文件工具类

```TypeScript
/**
 * 路径信息接口
 */
export interface FUNMPathInfo {
  /**
   * 工程内 resources 目录下 rawfile 中的路径
   */
  rawfilePath?: string;

  /**
   * 沙箱中的路径
   */
  sandBoxPath?: string;
}

export class FUNMFileUtil {
  
  /**
   * 获取沙箱中 filesDir 文件夹路径
   */
  get fileDir(): string 

  /**
   * 获取沙箱中 cacheDir 文件夹路径
   */
  get cacheDir(): string 

  /**
   * 获取沙箱中 tempDir 文件夹路径
   */
  get tempDir(): string 

  /**
   * 从 rawfile 文件中读取字符串
   * @param rPath rawfile路径
   */
  readTextFromRawfile(rPath: string): string | null 

  /**
   * 从 rawfile 文件中读取二进制buffer
   * @param rPath rawfile路径
   */
  readBufferFromRawfile(rPath: string): Uint8Array | null 

  /**
   * 从沙箱文件中读取字符串
   * @param path 沙箱路径
   */
  readTextFormSandBox(path: string): string | null 

  /**
   * 从沙箱文件中读取二进制buffer
   * @param path 沙箱文件路径
   */
  readBufferFormSandBox(path: string): Uint8Array | null 

  /**
   * 把内容写入沙箱文件中
   * @param path 沙箱文件路径
   * @param content 内容
   */
  writeFileToSandBox(path: string, content: string | ArrayBuffer): void 

  /**
   * 把 rawfile 文件拷贝到沙箱中
   * @param rRWPath rawfile文件路径
   * @param SBPath 沙箱文件路径
   * @returns 拷贝结果
   */
  copyRawfileToSandBox(rRWPath: string, SBPath: string): boolean 
  
  /**
   * 清空沙箱文件夹下的所有文件
   * @param folderName 文件夹路径
   */
  clearSandBoxFolder(folderName: string) 

  /**
   * 清空沙箱文件
   * @param path 沙箱文件路径
   */
  clearSandBoxFile(path: string) 

  /**
   * 获取沙箱文件夹下的所有文件
   * @param folderName 文件夹路径
   * @returns 文件名称数组
   */
  listFilesOfSandBoxFolder(folderName: string): Array<string> 

  /**
   * 创建沙箱文件夹
   * @param folderName
   */
  createSandBoxFolder(folderName: string) 
  
  /**
   * 移动文件
   * @param originPath 源文件路径
   * @param destPath 目的文件路径
   * @param isCover 是否覆盖
   * @returns 移动结果
   */
  moveFile(originPath: string, destPath: string, isCover: Boolean): Boolean 

  /**
   * 文件是否存在
   * @param path 文件路径
   * @returns 是否存在
   */
  isExist(path: string): boolean 
  /**
   * 二进制转 UTF-8 字符串
   * @param buf 二进制
   * @returns 字符串
   */
  buf2UTF8String(buf: Uint8Array): string 

  /**
   * 字符串转二进制
   * @param str 字符串
   * @returns 二进制
   */
  UTF8String2Buf(str: string): Uint8Array 
}
```

## FUNMGlobalContext

【工具】用于暂存 UIAbility 的上下文以供 har 内部使用

```TypeScript
/**
 * 全局上下文
 */
export class FUNMGlobalContext {

  /**
   * 获取 FUNMGlobalContext 单例对象
   */
  public static getContext(): FUNMGlobalContext 
  
  /**
   * 缓存当前 UIAbility 的上下文
   * @param context
   */
  setUIAbilityContext(context: common.UIAbilityContext) 
  
  /**
   * 获取缓存的 UIAbility 的上下文
   * @returns
   */
  getUIAbilityContext(): common.UIAbilityContext | undefined 
}
```

## FUNMImageUtil

【工具】图片工具类

```TypeScript
/**
 * 本类提供图片基础扁解码功能，不支持太多的自定义配置，只为方便指定场景的使用。
 */
export class FUNMImageUtil {
  /**
   * 根据rawfile文件路径解码出RGBA格式的PixelMap
   * @param rawfilePath
   * @returns 外界需要释放pixelMap。 「pixelMap.release()」
   */
  static decodeToGetRGBAPixelMapFromRawfile(rawfilePath: string): image.PixelMap 

  /**
   * 根据沙箱文件路径解码出RGBA格式的PixelMap
   * @param sandBoxPath
   * @returns 外界需要释放pixelMap。 「pixelMap.release()」
   */
  static decodeToGetRGBAPixelMapFromSandBoxFile(sandBoxPath: string): image.PixelMap 
  
  /**
   * 根据文件流解码出RGBA格式的PixelMap
   * @param sandBoxPath
   * @returns 外界需要释放pixelMap。 「pixelMap.release()」
   */
  static decodeToGetRGBAPixelMapFromFileBuffer(fileBuffer: ArrayBuffer, sourcePixelFormat: image.PixelMapFormat,
    sourceSize: Size): image.PixelMap 

  /**
   * 根据解码后的像素buffer创建RGBA格式的PixelMap
   * @param pixelBuffer
   * @returns 外界需要释放pixelMap。 「pixelMap.release()」
   */
  static getRGBAPixelMapFromPixelBuffer(pixelBuffer: ArrayBuffer, sourcePixelFormat: image.PixelMapFormat,
    sourceSize: Size): image.PixelMap 

  /**
   * 编码PixelMap得到压缩后的文件流
   * @param pixelMap
   * @param fileFormat 文件格式，目前只支持 image/jpeg、image/png、image/webp
   * @param quality 目标图像的质量。整数形式，取值范围是0 ~ 100。值越大越好
   * @returns 压缩后的文件流
   */
  static async encodePixelMapToGetFileBuffer(pixelMap: image.PixelMap, fileFormat: string,
    quality: number): Promise<ArrayBuffer> 

  /**
   * 保存编码后的文件流到相册中
   * @param buffer
   */
  static async saveToPhotoAlbum(fileBuffer: ArrayBuffer) 
}
```

## FUNMLogger

【工具】日志工具类

```TypeScript
class FUNMLogger {

  debug(...args: string[]) 
  
  info(...args: string[]) 
  
  warn(...args: string[]) 

  error(...args: string[]) 
  
  fatal(...args: string[]) 

  isLoggable(level: number) 
}
```

## FUNMNumberUtil

【工具】数值工具类

```TypeScript
export namespace FUNMNumberUtil {

  /**
   * 比较两个 number 是否相同
   * @param num1
   * @param num2
   * @returns
   */
  export function isNumberEqual(num1: number, num2: number): boolean 

  /**
   * 格式化 number 为字符串
   * @param num 数值
   * @param decimalPlaces 保留几位小数
   * @param round 是否四舍五入
   * @returns 格式化后的字符串
   */
  export function formatNumber(num: number, decimalPlaces: number, round: boolean): string 
}
```

## FUNMPermissionUtils

【工具】权限获取类

```TypeScript
/**
 * 获取指定权限的授权
 * @param permissions 待授权的权限数组
 * @returns 授权结果
 */
export async function grantPermission(permissions: Array<Permissions>): Promise<boolean>
```