### 1、 基础模型 FUNMItem

- 说明: 关于nama所有item部分说明: 所有业务模块item底层都基于FUNMItem 来实现，FUNMItem 实现了和公司内部库通信功能。
- Nama Item 的属性是在键值对基础上进行属性一层封装，更加方便的设置想要的功能。*如果设置项过多建议直接使用封装的键值对setParam或setParam:forName:paramType:方法设置,目前会针对美颜、美妆等封装一层key-value接口提供方便设置，后续会在每个item做详细说明*
- FUNMRenderKit 文件声明了所有NamaItem的属性或容器，实际业务开发在初始化之后赋值给 FUNMRenderKit的对应属性值. 不用NamaItem 需要把FUNMRenderKit对应的item 设置为 undefined，使用自动渲染时再调用 FUNMRenderKit  的 refreshAutoRenderInput 接口就能生效效果的更改。
  - 示例代码
  - ```TypeScript
    //美颜示例
    // 创建美颜道具
    const beauty = new FUNMBeauty({ rawfilePath: 'face_beautification.bundle' });
    
    //加载美颜
    FUNMRenderKit.sharedInstance().beauty = beauty;
    
    //移除美颜
    FUNMRenderKit.sharedInstance().beauty = undefined;
    
    
    //道具贴纸示例
    const rawfilePath = `sticker/bundles/${this.selectItem?.id}.bundle`;
    const sticker = new FUNMItem({ rawfilePath: rawfilePath });
    
    //添加贴纸
    FUNMRenderKit.sharedInstance().sticker = sticker;
    
    //移除贴纸
    FUNMRenderKit.sharedInstance().sticker = undefined;
    ```

#### 1.1 接口说明

- 根据道具路径创建道具对象

```TypeScript
constructor(path: FUNMPathInfo) 
```

- 设置键值对参数

```TypeScript
 /**
 * 道具设置参数
 * @param name 参数名
 * @param param 参数值
 * @returns 结果值{number} 1 if success, 0 if failed
 */
setParamForName(name: string, param: number | string): number
```

### 2、 美颜 FUNMBeauty

- 2.1.0 说明: 美颜模块继承自FUNMItem， 美颜模块分三个部分: 美肤(Skin)、美型(Shap)、滤镜(Filter), 需要证书秘钥包含该功能才可以使用。
- 2.1.1 属性说明

| 属性名称    | 类型 | 说明                                                         | key           |
| ----------- | ---- | ------------------------------------------------------------ | ------------- |
| blurUseMask | BOOL | blur是否使用mask                                             | blur_use_mask |
| heavyBlur   | int  | 朦胧磨皮开关，0为清晰磨皮，1为朦胧磨皮                       | heavy_blur    |
| blurType    | int  | 此参数优先级比heavyBlur低，在使用时要将heavy_blur设为0，0 清晰磨皮 1 朦胧磨皮 2精细磨皮 3均匀磨皮 | blur_type     |

#### 2.2 美肤 FUNMBeauty (Skin)

- 属性说明

| 属性名称                      | 类型   | 说明                                                         | key                              |
| ----------------------------- | ------ | ------------------------------------------------------------ | -------------------------------- |
| skinDetect                    | double | 肤色检测开关，0为关，1为开 默认值0                           | skin_detect                      |
| nonskinBlurScale              | double | 肤色检测之后非肤色区域的融合程度，取值范围0.0-1.0，默认值0.0 | nonskin_blur_scale               |
| blurLevel                     | double | 默认均匀磨皮,磨皮程度，取值范围0.0-6.0，默认值6.0            | blur_level                       |
| colorLevel                    | double | 美白 取值范围 0.0-1.0，0.0为无效果，1.0为最大效果，默认值0.0 | color_level                      |
| redLevel                      | double | 红润 取值范围 0.0-1.0，0.0为无效果，1.0为最大效果，默认值0.0 | red_level                        |
| sharpen                       | double | 锐化 锐化程度，取值范围0.0-1.0，默认0.0                      | sharpen                          |
| faceThreed                    | double | 五官立体 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0 | face_threed                      |
| eyeBright                     | double | 亮眼 0.0-1.0, 0.0为无效果，1.0为最大效果，默认值0.0 亮眼为高级美颜功能，需要相应证书权限才能使用 | eye_bright                       |
| toothWhiten                   | double | 美牙 取值范围 0.0-1.0, 0.0为无效果，1.0为最大效果，默认值0.0 美牙为高级美颜功能，需要相应证书权限才能使用 | tooth_whiten                     |
| removePouchStrength           | double | 去黑眼圈 范围0.0~1.0, 0.0为无效果，1.0最强，默认0.0 去黑眼圈为高级美颜功能，需要相应证书权限才能使用 | remove_pouch_strength            |
| removeNasolabialFoldsStrength | double | 去法令纹 范围0.0~1.0, 0.0为无效果，1.0最强，默认0.0 去法令纹为高级美颜功能，需要相应证书权限才能使用 | remove_nasolabial_folds_strength |

#### 2.3 美型 FUNMBeauty (Shap)

- 属性说明

| 属性名称            | 类型   | 说明                                                         | key                   |
| ------------------- | ------ | ------------------------------------------------------------ | --------------------- |
| faceShape           | int    | 变形取值 0:女神变形 1:网红变形 2:自然变形 3:默认变形 4:精细变形 默认4 | face_shape            |
| changeFrames        | int    | 0为关闭 ，大于0开启渐变，值为渐变所需要的帧数 change_frames  | change_frames         |
| faceShapeLevel      | double | 美型的整体程度由face_shape_level参数控制 取值范围 0.0-1.0, 0.0为无效果，1.0为最大效果，默认值1.0 face_shape_level | face_shape_level      |
| cheekThinning       | double | 瘦脸 瘦脸程度范围0.0-1.0 默认0.0                             | cheek_thinning        |
| cheekV              | double | v脸程度范围0.0-1.0 默认0.0                                   | cheek_v               |
| cheekNarrow         | double | 窄脸程度范围0.0-1.0 默认0.0                                  | cheek_narrow          |
| cheekShort          | double | 短脸程度范围0.0-1.0 默认0.0                                  | cheek_short           |
| cheekSmall          | double | 小脸程度范围0.0-1.0 默认0.0                                  | cheek_small           |
| intensityCheekbones | double | 瘦颧骨程度范围0.0~1.0 1.0程度最强 默认0.0                    | intensity_cheekbones  |
| intensityLowerJaw   | double | 瘦下颌骨程度范围0.0~1.0 1.0程度最强 默认0.0                  | intensity_lower_jaw   |
| eyeEnlarging        | double | 大眼程度范围0.0-1.0 1.0程度最强 默认0.0                      | eye_enlarging         |
| intensityChin       | double | 下巴调整程度范围0.0-1.0，0.5-0.0是变小，0.5-1.0是变大 默认0.5 | intensity_chin        |
| intensityForehead   | double | 额头调整程度范围0.0-1.0，0.5-0.0是变小，0.5-1.0是变大 默认0.5 | intensity_forehead    |
| intensityNose       | double | 瘦鼻程度范围0.0-1.0 1.0程度最强 默认0.0                      | intensity_nose        |
| intensityMouth      | double | 嘴型调整程度范围0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5 | intensity_mouth       |
| intensityLipThick   | double | 嘴唇厚度 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变薄, 0.5-1是变厚, 默认值0.5 | intensity_lip_thick   |
| intensityEyeHeight  | double | 眼睛位置 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变低, 0.5-1是变高, 默认值0.5 | intensity_eye_height  |
| intensityCanthus    | double | 开眼角程度范围0.0~1.0 1.0程度最强 默认0.0                    | intensity_canthus     |
| intensityEyeLid     | double | 眼睑下至 取值范围 0.0-1.0, 0.0为无效果, 1.0为最大效果, 默认值0.0 | intensity_eye_lid     |
| intensityEyeSpace   | double | 眼距调节范围0.0~1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5    | intensity_eye_space   |
| intensityEyeRotate  | double | 眼睛角度调节范围0.0~1.0，0.5-0.0逆时针旋转，0.5-1.0顺时针旋转 默认0.5 | intensity_eye_rotate  |
| intensityLongNose   | double | 鼻子长度调节范围0.0~1.0，0.5-0.0是变长，0.5-1.0是变短 默认0.5 | intensity_long_nose   |
| intensityPhiltrum   | double | 人中调节范围0.0~1.0，0.5-0.0是变短，0.5-1.0是变长， 默认0.5  | intensity_philtrum    |
| intensitySmile      | double | 微笑嘴角程度范围0.0~1.0 1.0程度最强 默认0.0                  | intensity_smile       |
| intensityEyeCircle  | double | 圆眼程度范围0.0~1.0 1.0程度最强                              | intensity_eye_circle  |
| intensityBrowHeight | double | 眉毛上下 取值范围 0.0-1.0, 0.5-0是向上, 0.5-1是向下, 默认值0.5 | intensity_brow_height |
| intensityBrowSpace  | double | 眉间距 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变小, 0.5-1是变大, 默认值0.5 | intensity_brow_space  |
| intensityBrowThick  | double | 眉毛粗细 取值范围 0.0-1.0, 默认值0.5, 0.5-0是变细, 0.5-1是变粗, 默认值0.5 | intensity_brow_thick  |

#### 2.4 滤镜 FUNMBeauty (Filter)

- 属性说明

| 属性名      | 类型     | 说明                                                         | key          |
| ----------- | -------- | ------------------------------------------------------------ | ------------ |
| filterName  | NSString | 取值为一个字符串，默认值为 “origin” ，origin即为使用原图效果 | filter_name  |
| filterLevel | double   | filter_level 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值1.0 | filter_level |

- 滤镜键Key 可选范围

| Key          |
| ------------ |
| origin       |
| ziran1       |
| ziran2       |
| ziran3       |
| ziran4       |
| ziran5       |
| ziran6       |
| ziran7       |
| ziran8       |
| zhiganhui1   |
| zhiganhui2   |
| zhiganhui3   |
| zhiganhui4   |
| zhiganhui5   |
| zhiganhui6   |
| zhiganhui7   |
| zhiganhui8   |
| mitao1       |
| mitao2       |
| mitao3       |
| mitao4       |
| mitao5       |
| mitao6       |
| mitao7       |
| mitao8       |
| bailiang1    |
| bailiang2    |
| bailiang3    |
| bailiang4    |
| bailiang5    |
| bailiang6    |
| bailiang7    |
| fennen1      |
| fennen2      |
| fennen3      |
| fennen5      |
| fennen6      |
| fennen7      |
| fennen8      |
| lengsediao1  |
| lengsediao2  |
| lengsediao3  |
| lengsediao4  |
| lengsediao7  |
| lengsediao8  |
| lengsediao11 |
| nuansediao1  |
| nuansediao2  |
| gexing1      |
| gexing2      |
| gexing3      |
| gexing4      |
| gexing5      |
| gexing7      |
| gexing10     |
| gexing11     |
| xiaoqingxin1 |
| xiaoqingxin3 |
| xiaoqingxin4 |
| xiaoqingxin6 |
| heibai1      |
| heibai2      |
| heibai3      |
| heibai4      |

#### 2.5 美颜Mode FUNMBeauty (Mode)

- 2.5.1 接口说明

```TypeScript
/**
 * 设置部分美颜属性的mode，不同mode会有主观上不同效果
 * 必须在设置美颜各个属性值之前调用该接口
 * @param mode 模式
 * @param key 支持设置模式的key
 */
addBeautyPropertyMode(mode: FUNMBeautyPropertyMode, key: FUNMModeKey)
```

| key                              | 属性     | 支持的mode                                                   |
| -------------------------------- | -------- | ------------------------------------------------------------ |
| color_level                      | 美白     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| remove_pouch_strength            | 去黑眼圈 | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2(高性能设备推荐) |
| remove_nasolabial_folds_strength | 去法令纹 | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2(高性能设备推荐) |
| cheek_thinning                   | 瘦脸     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| cheek_narrow                     | 窄脸     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| cheek_small                      | 小脸     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| eye_enlarging                    | 大眼     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2, FUNMBeautyPropertyMode3(高性能设备推荐) |
| intensity_chin                   | 下巴     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| intensity_forehead               | 额头     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| intensity_nose                   | 瘦鼻     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2             |
| intensity_mouth                  | 嘴型     | FUNMBeautyPropertyMode1, FUNMBeautyPropertyMode2, FUNMBeautyPropertyMode3(高性能设备推荐) |