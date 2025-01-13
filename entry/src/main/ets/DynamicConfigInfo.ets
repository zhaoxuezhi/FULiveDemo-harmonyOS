interface DynamicConfigInfoInterface {
  showsLandmarks: Boolean;
  makeupShowLocalMediaEntry : Boolean
}

export const DynamicConfigInfo: DynamicConfigInfoInterface = {
  showsLandmarks : false,  // 是否显示点位
  makeupShowLocalMediaEntry : false  // 美妆模块是否显示导图入口
}