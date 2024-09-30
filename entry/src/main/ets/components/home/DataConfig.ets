export interface HomeItem {
  img: ResourceStr;
  label: string;
}

export interface HomeItemGroup {
  label: string;
  style: '1x1' | '1x3';
  items: HomeItem[];
}

export const configData: HomeItemGroup[] = [
  {
    label: '人脸特效',
    style: '1x3',
    items: [
      {
        img: $rawfile('home/meiyan@2x.png'),
        label: '美颜'
      },
      // {
      //   img: $rawfile('home/meizhuang@2x.png'),
      //   label: '美妆'
      // },
      // {
      //   img: $rawfile('home/fenggetuijian@2x.png'),
      //   label: '风格推荐'
      // },
      {
        img: $rawfile('home/daojutiezhi@2x.png'),
        label: '道具贴纸'
      },
      // {
      //   img: $rawfile('home/animoji@2x.png'),
      //   label: 'Animoji'
      // },
      // {
      //   img: $rawfile('home/meifa@2x.png'),
      //   label: '美发'
      // },
      // {
      //   img: $rawfile('home/qingmeizhuang@2x.png'),
      //   label: '轻美妆'
      // },
      // {
      //   img: $rawfile('home/armianju@2x.png'),
      //   label: 'AR面具'
      // },
      // {
      //   img: $rawfile('home/gaoxiaodatou@2x.png'),
      //   label: '搞笑大头'
      // },
      // {
      //   img: $rawfile('home/haibaohuanlian@2x.png'),
      //   label: '海报换脸'
      // },
      // {
      //   img: $rawfile('home/biaoqingshibie@2x.png'),
      //   label: '表情识别'
      // },
      // {
      //   img: $rawfile('home/yinyuelvjing@2x.png'),
      //   label: '音乐滤镜'
      // },
      // {
      //   img: $rawfile('home/hahaijing@2x.png'),
      //   label: '哈哈镜'
      // }
    ]
  },
  // {
  //   label: '人体特效',
  //   style: '1x3',
  //   items: [
  //     {
  //       img: $rawfile('home/meiti@2x.png'),
  //       label: '美体'
  //     },
  //     {
  //       img: $rawfile('home/quanshenavatar@2x.png'),
  //       label: '全身Avatar'
  //     },
  //     {
  //       img: $rawfile('home/renxiangfenge@2x.png'),
  //       label: '人像分割'
  //     },
  //     {
  //       img: $rawfile('home/shoushishibie@2x.png'),
  //       label: '手势识别'
  //     },
  //     {
  //       img: $rawfile('home/lvmukouxiang@2x.png'),
  //       label: '绿幕抠像'
  //     }
  //   ]
  // },
  // {
  //   label: '内容服务',
  //   style: '1x1',
  //   items: [
  //     {
  //       img: $rawfile('home/jingpintiezhi_animation.gif'),
  //       label: '精品贴纸'
  //     }
  //   ]
  // }
];
