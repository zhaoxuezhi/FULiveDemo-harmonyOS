import { FUNMItem, FUNMRenderKit } from '@faceunity/renderkit_nama';
import { HorizontalScrollView, HorizontalScrollViewItemInterface } from '../common/HorizontalScrollView';
import { CaptureButton } from '../common/CaptureButton';
import { RenderKitService } from '../../service/RenderKitService';
import { SaveScreenshotCallBack } from '../../utils/CallBack';

@Component
export struct StickerView {
  @Prop autoRender: boolean = true;
  @Prop callBackObject: SaveScreenshotCallBack | undefined;
  // 模板选择
  @State @Watch('onPropertyDidChange') selectItemIndex: number = 1
  private items: HorizontalScrollViewItemInterface[] = [
    { id: 'reset_item', imageUrl: $rawfile('sticker/images/reset_item.png') },
    { id: 'CatSparks', imageUrl: $rawfile('sticker/images/CatSparks.png') },
    { id: 'fu_zh_fenshu', imageUrl: $rawfile('sticker/images/fu_zh_fenshu.png') },
    { id: 'sdlr', imageUrl: $rawfile('sticker/images/sdlr.png') },
    { id: 'xlong_zh_fu', imageUrl: $rawfile('sticker/images/xlong_zh_fu.png') },
    { id: 'newy1', imageUrl: $rawfile('sticker/images/newy1.png') },
    { id: 'redribbt', imageUrl: $rawfile('sticker/images/redribbt.png') },
    { id: 'DaisyPig', imageUrl: $rawfile('sticker/images/DaisyPig.png') },
    { id: 'sdlu', imageUrl: $rawfile('sticker/images/sdlu.png') },
  ];

  onPropertyDidChange(properTyName: string) {
    if (properTyName === 'selectItemIndex') {
      this.updateSticker()
    }
  }

  aboutToAppear() {
    this.onPropertyDidChange('selectItemIndex');
  }

  build() {
    Column() {
      Row() {
        if (this.autoRender) {
          CaptureButton({
            onClickCallback: () => {
              RenderKitService.sharedInstance().captureImageFromAutoRender = true;
            }, onLongPressStartCallback: () => {
              RenderKitService.sharedInstance().startRecordVideoFromAutoRender = true;
            }, onLongPressEndCallback: () => {
              RenderKitService.sharedInstance().stopRecordVideoFromAutoRender = true;
            }
          })
            .size({ width: 70, height: 70 })
        } else {
          Button({ stateEffect: true }) {
            Image($r('app.media.demo_icon_save'))
          }
          .type(ButtonType.Circle)
          .backgroundColor(Color.White)
          .width(70)
          .height(70)
          .onClick(() => {
            if (this.callBackObject) {
              this.callBackObject.cb();
            }
          })
        }
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(70)
      .margin({ bottom: 20 })

      HorizontalScrollView({
        items: this.items,
        selectIndex_from: this.selectItemIndex,
        frames: { imgWidth: 60 },
        onItemClick: (item: HorizontalScrollViewItemInterface, index: number) => {
          this.selectItemIndex = index
        }
      })
        .padding({ top: 10 })
        .backgroundColor(Color.Black)
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
  }

  updateSticker() {
    this.destroyCurrentItemIfNeed();
    const item = this.items[this.selectItemIndex]
    if (item?.id === 'reset_item') {
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    } else if (item?.id) {
      const rawfilePath = `sticker/bundles/${item?.id}.bundle`;
      const sticker = new FUNMItem({ rawfilePath: rawfilePath });
      FUNMRenderKit.sharedInstance().sticker = sticker;
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    }
  }

  private destroyCurrentItemIfNeed() {
    if (FUNMRenderKit.sharedInstance().sticker) {
      FUNMRenderKit.sharedInstance().sticker?.destroy();
      FUNMRenderKit.sharedInstance().sticker = undefined;
    }
  }
}