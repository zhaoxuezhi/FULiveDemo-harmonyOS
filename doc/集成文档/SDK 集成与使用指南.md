## 示例Demo的目录结构介绍

```SQL
main
├── ets
├── auth
│   └── FUNMAuth.ets									//鉴权文件
├── components											 // UI组件
│   ├── beauty											//美颜模块UI组件		
│   │   ├── BeautyFilterView.ets
│   │   ├── BeautyShapeView.ets
│   │   ├── BeautySkinView.ets
│   │   ├── BeautyView.ets
│   │   └── BeautyViewNodeController.ets
│   ├── common										   //模块间通用的自定义UI组件
│   │   ├── AutoDismissToast.ets
│   │   ├── CaptureButton.ets
│   │   ├── CustomDialog.ets
│   │   ├── DisplayXView.ets
│   │   ├── FUBackButton.ets
│   │   ├── HorizontalScrollView.ets
│   │   ├── PageBaseView.ets
│   │   └── VerticalColorPicker.ets
│   ├── floatComponent								   //浮窗自定义UI组件
│   │   └── FPSFloatView.ets
│   ├── headToolBar									   //顶部工具栏自定义UI组件
│   │   ├── FUHeadToolBar.ets
│   │   ├── HeadToolBarController.ets
│   │   ├── MorePopView.ets
│   │   └── PixelBufferView.ets
│   ├── home											//首页相关的自定义UI组件
│   │   ├── DataConfig.ets
│   │   └── ItemContanerView.ets
│   ├── lightingView
│   │   └── LightingView.ets
│   ├── makeup											// 美妆模块 UI 组件
│   │   ├── HorizontalScrollLabelView.ets
│   │   ├── MakeUpContainView.ets
│   │   ├── MakeupPageView.ets
│   │   ├── MakeUpView.ets
│   │   ├── MakeupViewNodeController.ets
│   │   └── SubMakeupView.ets
│   ├── media
│   │   └── ExportVideoView.ets
│   ├── segmentation									// 人像分割模块 UI组件
│   │   ├── SegmentationView.ets
│   │   └── SelectSegmentModeView.ets
│   ├── simpleSticker								   // 哈哈镜、搞笑大头 模块UI组件
│   │   └── SimpleStickerView.ets
│   └── sticker											// 贴纸模块 UI 组件	
│       ├── StickerView.ets
│       └── StickerViewNodeController.ets
├── constants
│   └── Constants.ets
├── entryability
│   └── EntryAbility.ets
├── entrybackupability
│   └── EntryBackupAbility.ets
├── models	
│   └── beauty
│       ├── BeautyFilterModel.ets
│       ├── BeautyShapeModel.ets
│       └── BeautySkinModel.ets
├── pages												// 页面																				
│   ├── media                                           // 本地导图渲染页面
│   │   ├── ImageRenderPage.ets
│   │   ├── SelectLocalMediaPage.ets
│   │   └── VideoRenderPage.ets
│   ├── modules										   // 模块页面
│   │   ├── BeautyPage.ets                            // 美颜
│   │   ├── Index.ets								  // 首页
│   │   ├── MakeUpPage.ets							  // 美妆
│   │   ├── SegmentationPage.ets                      // 人像分割
│   │   ├── SimpleStickerPage.ets                     // 哈哈镜、搞笑大头
│   │   └── StickerPage.ets                           // 贴纸
│   └── CameraPage.ets
├── router
│   └── RouterModel.ets
├── service
│   ├── BeautyDataService.ets						  //美颜模块数据服务	
│   ├── NodeControllerService.ets    				  //视图单例模式服务
│   └── RenderKitService.ets                          //FUNMRenderKit服务
├── utils
│   ├── AssetsUtil.ets
│   ├── CallBack.ets
│   ├── ComonUtil.ets
│   ├── DateTimeUtils.ets
│   ├── FUSafeAreaUtil.ets
│   ├── RequestPermission.ets
│   └── ThrottleManager.ets
├── viewModels											// 页面模型
│   ├── beauty                                         // 美颜
│   │   ├── BeautyFilterViewModel.ets
│   │   ├── BeautyShapeViewModel.ets
│   │   └── BeautySkinViewModel.ets
│   ├── makeup                                         // 美妆
│   │   ├── MakeUpViewModel.ets
│   │   ├── MakeUpViewModelController.ets
│   │   ├── SubMakeupJsonModel.ets
│   │   └── SubMakeupViewModel.ets
│   ├── video                                          //本地视频渲染
│   │   └── VideoRenderViewModel.ets
│   └── SegmentationController.ets                     // 人像分割
└── DynamicConfigInfo.ets
├── resources
│   ├── base
│   │   ├── element
│   │   ├── media
│   │   └── profile
│   │       ├── backup_config.json
│   │       ├── main_pages.json
│   │       └── router_map.json                        //路由配置表
│   ├── rawfile
│   │   ├── beauty                                     //美颜配置数据
│   │   │   ├── beauty_filter.json
│   │   │   ├── beauty_shape.json
│   │   │   └── beauty_skin.json
│   │   ├── common                    
│   │   │   ├── render_back_home@2x.png
│   │   │   ├── render_bugly@2x.png
│   │   │   ├── render_camera_switch@2x.png
│   │   │   ├── render_more@2x.png
│   │   │   ├── render_picture@2x.png
│   │   │   ├── render_select_media@2x.png
│   │   │   └── style_customizing_back@2x.png
│   │   ├── distortingMirror                           // 哈哈镜模块资源 
│   │   │   ├── bundles/
│   │   │   └── images/
│   │   ├── funnyBigHead                               // 搞笑大头模块资源
│   │   │   ├── bundles/
│   │   │   └── images/
│   │   ├── home                                       // 首页资源
│   │   │   ├── qingmeizhuang@2x.png
│   │   │   ├── quanshenavatar@2x.png
│   │   │   ├── renxiangfenge@2x.png
│   │   │   ├── shoushishibie@2x.png
│   │   │   └── yinyuelvjing@2x.png
│   │   ├── lighting
│   │   │   ├── lighting_mon@2x.png
│   │   │   └── lighting_sun@2x.png
│   │   ├── makeup                                     // 美妆模块资源    
│   │   │   ├── CombinationMakeup/
│   │   │   ├── CustomizedMakeup/
│   │   │   ├── items/
│   │   │   ├── others/
│   │   │   └── subItems/
│   │   ├── pickerImage      
│   │   │   ├── media_picker_button_background@2x.png
│   │   │   ├── media_picker_image_selection@2x.png
│   │   │   └── media_picker_video_selection@2x.png
│   │   ├── segmentation                                // 人像分割模块资源 
│   │   │   ├── bundles/
│   │   │   ├── images/
│   │   │   └── segmentation.json
│   │   ├── sticker                                     // 贴纸模块资源
│   │   │   ├── bundles/
│   │   │   └── images/
│   │   ├── ai_face_processor.bundle                    //AI道具文件
│   │   ├── ai_human_processor.bundle                   //AI道具文件
│   │   ├── face_beautification.bundle                  //美颜道具文件 
│   │   ├── face_makeup.bundle 
│   │   ├── landmarks.bundle
│   │   └── moban_bz.png
└── module.json5
```

### 关键资源文件

#### 1、ai_face_processor.bundle 

如果不加载就没有AI检测能力

#### 2、face_beautification.bundle 

如果不加载就没有美颜效果

#### 3、beauty_skin.json

```TypeScript
[
    {
        "name":"磨皮",
        "imeName":"mopi",
        "type":0,
        "currentValue":3.6,
        "defaultValue":3.6,
        "defaultValueInMiddle":false,
        "ratio":6,
        "performanceLevel": -1
    },
    ....
]
```

使用此配置文件创建  `BeautySkinModel`模型数组，以便后续美肤参数的调整。

#### 4、beauty_shape.json

```TypeScript
[
    {
        "name":"瘦脸",
        "imeName":"shoulian",
        "type":0,
        "currentValue":0.0,
        "defaultValue":0.0,
        "defaultValueInMiddle":false,
        "performanceLevel": -1
    },
    ....
]
```

使用此配置文件创建  `BeautyShapeModel`模型数组，以便后续美形参数的调整。

#### 5、beauty_filter.json

```TypeScript
[
    {
        "filterIndex":0,
        "filterName":"origin",
        "filterLevel":0.4
    },
    ....
]
```

使用此配置文件创建  `BeautyFilterModel`模型数组，以便后续美颜滤镜参数的调整。

## 功能集成

### 1、设置SDK内部的 UIAbility 上下文

程序启动之初，需要设置SDK内部的 UIAbility 上下文，否则SDK内部依赖此上下文的所有功能将无法正常运行。

```TypeScript
onWindowStageCreate(windowStage: window.WindowStage): void {
  FUNMGlobalContext.getContext().setUIAbilityContext(this.context);
」
```

### 2、初始化RenderKit

```TypeScript
// 初始化 RenderKit
initRenderKit() {
  let byte = new Uint8Array(g_auth_package)
  const config = new FUNMSetupConfig(byte.buffer as ArrayBuffer, byte.length);
  FUNMRenderKit.setup(config);
  FUNMRenderKit.setLogLevel(FULOGLEVEL.FU_LOG_LEVEL_INFO);
  FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera = true;
  FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = AutoRenderResolution;
  FUNMRenderKit.sharedInstance().autoRenderConfig.fps = 30;
  FUNMRenderKit.sharedInstance().renderDelegate = this;
}
```

`g_auth_package` 为证书文件中的信息，证书信息获取详见 [参考示例-Demo运行说明文档](https://k2i32i19ow.feishu.cn/wiki/ZMXjwwOaxiHQ7ek477YcvFlanke#share-RhTAdCopYoWqnDxhJ3vcPOv9ntb)

### 3、初始化AIKit

```TypeScript
// 初始化AIKit
 initAIKit() {
  FUNMAIKit.loadAIModeWithAIType(FUAITYPE.FUAITYPE_FACEPROCESSOR, { rawfilePath: 'ai_face_processor.bundle' });
  FUNMAIKit.shareKit().maxTrackFaces = 2;
  FUNMAIKit.shareKit().faceProcessorDetectMode = FUNMFaceProcessorDetectMode.Video;
  FUNMAIKit.shareKit().faceProcessorFaceLandmarkQuality = FUNMFaceProcessorFaceLandmarkQuality.High;
}
```

### 4、加载美颜道具

```TypeScript
loadBeauty() {
  if (!FUNMRenderKit.sharedInstance().beauty) {
    // 创建美颜道具
    const beauty = new FUNMBeauty({ rawfilePath: 'face_beautification.bundle' });
    beauty.heavyBlur = 0;
    // 默认均匀磨皮
    beauty.blurType = 3;
    // 默认精细变形
    beauty.faceShape = 4;

    // 高性能设备设置去黑眼圈、去法令纹、大眼、嘴型最新效果
    beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode2, FUNMModeKey.RemovePouchStrength);
    beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode2, FUNMModeKey.RemoveNasolabialFoldsStrength);
    beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode3, FUNMModeKey.EyeEnlarging);
    beauty.addBeautyPropertyMode(FUNMBeautyPropertyMode.Mode3, FUNMModeKey.IntensityMouth);
    FUNMRenderKit.sharedInstance().beauty = beauty;
  }
}
```

### 5、修改美颜参数

#### 5.1、修改美肤参数

```TypeScript
//修改美肤参数
BeautySkinViewModel

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
```

#### 5.1、修改美形参数

```TypeScript
BeautyShapeViewModel

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
```

#### 5.3、修改美颜滤镜参数

```TypeScript
BeautyFilterViewModel

/// 设置单项滤镜值
/// @param value 当前选中单项的值
setFilterValue(model: BeautyFilterModel, value: number) {
  this.currentModel = model;
  model.filterLevel = value;
  this.setFilter(model.filterLevel, model.filterName);
}
```

### 6、加载/移除贴纸道具（哈哈镜、搞笑大头、人像分割 实现逻辑大致相同）

```TypeScript
//道具贴纸示例
const rawfilePath = `sticker/bundles/${this.selectItem?.id}.bundle`;
const sticker = new FUNMItem({ rawfilePath: rawfilePath });

//添加贴纸
FUNMRenderKit.sharedInstance().sticker = sticker;

//移除贴纸
FUNMRenderKit.sharedInstance().sticker = undefined;
```

### 7、截图保存到相册

#### 7.1、使用自动渲染时的相机截图

```TypeScript
RenderKitService

private async captureImageFromAutoRenderHandle(renderOutput: FUNMRenderOutput) {
  const outputType = FUNMRenderKit.sharedInstance().autoRenderConfig.outputType;
  if (this.captureImageFromAutoRender && outputType !== FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER) {
    FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER;
    FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
  }

  if (this.captureImageFromAutoRender && renderOutput.dataType === FUNMOutputDataType.RGBA_BUFFER && renderOutput.pixelBuffer) {
    FULogger.info('YYYY 保存照片调用了');
    this.captureImageFromAutoRender = false;
    let pixelMap = FUNMImageUtil.getRGBAPixelMapFromPixelBuffer(renderOutput.pixelBuffer, image.PixelMapFormat.RGBA_8888,
      { width: renderOutput.outputSize.width, height: renderOutput.outputSize.height });
    const encodeBuffer = await FUNMImageUtil.encodePixelMapToGetFileBuffer(pixelMap, 'image/jpeg', 98);
    await pixelMap.release();
    await FUNMImageUtil.saveToPhotoAlbum(encodeBuffer);
    promptAction.showToast({ message: '照片保存成功！' });

    FUNMRenderKit.sharedInstance().autoRenderConfig.outputType = FUNMOutputType.XCOMPONENT;
    FUNMRenderKit.sharedInstance().refreshAutoRenderInput();
  }
}
```

#### 7.2、使用相册中的图片渲染截图

```TypeScript
ImageRenderPage

async aboutToAppear() {
  this.assetData = Object(this.routerParams?.params)?.assetData as AssetsDataInterface;

  const pixelMap = this.assetData.thumbnail;
  if (pixelMap === undefined) {
    return;
  }
  let input_buffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
  pixelMap.readPixelsToBufferSync(input_buffer);
  let info = pixelMap.getImageInfoSync();
  await pixelMap.release();

  const nInput = new FUNMNormalInput();
  nInput.pixelBuffer = input_buffer;
  nInput.pixelFormat = FUNMInputBufferFormat.RGBA_BUFFER;

  const configT = new FUNMRenderConfig();
  configT.xcomponentId = xcomponentIdG;
  configT.outputType = FUNMOutputType.XCOMPONENT;

  const input = new FUNMRenderInput(configT);
  input.normalInput = nInput;
  input.inputSize = { width: info.size.width, height: info.size.height };
  this.input = input;

  // TODO: 待完善
  RenderKitService.sharedInstance().finalImageOrientation(FUNMImageOrientation.UP);

  this.renderTimer = setInterval(async () => {
    if (this.input) {
      if (this.captureImage && this.input.renderConfig.outputType !== FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER) {
        this.input.renderConfig.outputType = FUNMOutputType.XCOMPONENT_WITH_RGBA_BUFFER;
      }

      FUNMRenderKit.renderWithInput(this.input).then(async (output: FUNMRenderOutput) => {
        if (this.captureImage && output.dataType === FUNMOutputDataType.RGBA_BUFFER && output.pixelBuffer) {
          FULogger.info('YYYY 保存照片调用了');
          this.captureImage = false;
          let pixelMap =
            FUNMImageUtil.getRGBAPixelMapFromPixelBuffer(output.pixelBuffer, image.PixelMapFormat.RGBA_8888,
              { width: output.outputSize.width, height: output.outputSize.height });
          const encodeBuffer = await FUNMImageUtil.encodePixelMapToGetFileBuffer(pixelMap, 'image/jpeg', 98);
          await pixelMap.release();
          await FUNMImageUtil.saveToPhotoAlbum(encodeBuffer);
          promptAction.showToast({ message: '照片保存成功！' });

          if (this.input) {
            this.input.renderConfig.outputType = FUNMOutputType.XCOMPONENT;
          }
        }
      }).catch((Error: Error) => {
        FULogger.error(`保存照片失败了 ${Error.message}`)
      });
    }
  }, 166);
}
```

### 8、相机前后摄像头切换

```TypeScript
RenderKitService

async cameraSwitch() {
  const camera = FUNMRenderKit.sharedInstance().camera;
  if (camera) {
    const isFrontCamera = !camera.isFrontCamera;
    FUNMRenderKit.sharedInstance().autoRenderConfig.isFrontCamera = isFrontCamera;
    await FUNMRenderKit.stopAutoRender();
    await FUNMRenderKit.startAutoRender();
    FUNMAIKit.shareKit().isFrontCamera = isFrontCamera;
  }
}
```

### 9、相机分辨率切换

```TypeScript
RenderKitService

async changeCamaraResolution(resolution: Size, displayResolutionHandle:() => void) {
  FUNMRenderKit.sharedInstance().autoRenderConfig.camaraResolution = resolution;
  await FUNMRenderKit.stopAutoRender();
  RenderKitService.sharedInstance().clearXComponent();
  displayResolutionHandle();
  await FUNMRenderKit.startAutoRender();
}
```

### 10、美颜效果对比

```TypeScript
BeautyPage


Button({ stateEffect: true }) {
  Image($r('app.media.demo_icon_contrast'))
}
.alignRules({
  bottom: { anchor: "beautyView", align: VerticalAlign.Top },
  left: { anchor: "beautyView", align: HorizontalAlign.Start }
})
.width(40)
.height(40)
.id("compareButton")
.offset({ x: 10, y: -20 })
.onTouch((event: TouchEvent) => {
  switch (event.type) {
    case TouchType.Up:
    case TouchType.Cancel:
      if (!this.shouldDoRender) {
        RenderKitService.sharedInstance().shouldDoRender = true;
        this.shouldDoRender = true;
      }
      break;
    case TouchType.Down:
    case TouchType.Move:
      if (this.shouldDoRender) {
        RenderKitService.sharedInstance().shouldDoRender = false;
        this.shouldDoRender = false;
      }
      break;
  }
});
```

### 11、获取渲染后的数据

```TypeScript
RenderKitService

didAutoRender(renderOutput: FUNMRenderOutput) {
  this.captureImageFromAutoRenderHandle(renderOutput);
}
```

通过实现 FUNMAutoRenderDelegate 接口获取。

### 12、获取帧率、单帧渲染时间

```TypeScript
RenderKitService

renderFPSInfo(fps: number, renderTime: number) {
  AppStorage.set('FPSValue', FUNMNumberUtil.formatNumber(fps, 0, true));
  AppStorage.set('renderTime', FUNMNumberUtil.formatNumber(renderTime, 0, true));
}
```

通过实现 FUNMFPSDelegate 接口获取。