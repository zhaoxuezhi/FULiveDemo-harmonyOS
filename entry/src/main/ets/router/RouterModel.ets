
export interface  RouterParamsModel {
  params ?: Object
  popCallBack ?: (value: Object | undefined) => void
}

export const  RouterPageConfig : Map<string, string> = new Map(
  [
    ['美颜', 'BeautyPage'],
    ['道具贴纸', 'StickerPage'],
    // ['美妆', 'MakeUpPage'],
  ]
)
