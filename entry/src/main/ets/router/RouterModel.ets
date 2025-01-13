export interface RouterParamsModel {
  params ?: Object
  popCallBack ?: (value: Object | undefined) => void
}

export const RouterPageConfig: Map<string, string> = new Map(
  [
    ['美颜', 'BeautyPage'],
    ['道具贴纸', 'StickerPage'],
    ['美妆', 'MakeUpPage'],
    ['哈哈镜', 'DistortingMirrorPage'],
    ['搞笑大头', 'FunnyBigHead'],
    ['人像分割','SegmentationPage']
  ]
)
