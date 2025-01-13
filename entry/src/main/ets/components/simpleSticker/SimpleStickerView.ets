import { FUNMItem, FUNMRenderKit } from '@faceunity/renderkit_nama';
import { CaptureButton } from '../common/CaptureButton';
import { RenderKitService } from '../../service/RenderKitService';
import { HorizontalScrollView, HorizontalScrollViewItemInterface } from '../common/HorizontalScrollView';
import { SimpleStickerPageType } from '../../pages/modules/SimpleStickerPage';

@Component
export struct SimpleStickerView {
  // 模板选择
  @State @Watch('onPropertyDidChange') selectItemIndex: number = 1
  @Require pageType: SimpleStickerPageType = SimpleStickerPageType.DISTORTING_MIRROR;
  private items: HorizontalScrollViewItemInterface[] = []
  @Require showToastCb: (toast: string) => void = () => {
  };

  onPropertyDidChange(properTyName: string) {
    if (properTyName === 'selectItemIndex') {
      this.updateFUItem()
    }
  }

  initItems() {
    if (this.pageType === SimpleStickerPageType.DISTORTING_MIRROR) {
      this.items = [
        { id: 'reset_item', imageUrl: $rawfile('distortingMirror/images/reset_item.png') },
        { id: 'facewarp2', imageUrl: $rawfile('distortingMirror/images/facewarp2.png') },
        { id: 'facewarp3', imageUrl: $rawfile('distortingMirror/images/facewarp3.png') },
        { id: 'facewarp4', imageUrl: $rawfile('distortingMirror/images/facewarp4.png') },
        { id: 'facewarp5', imageUrl: $rawfile('distortingMirror/images/facewarp5.png') },
        { id: 'facewarp6', imageUrl: $rawfile('distortingMirror/images/facewarp6.png') },
      ];
    } else if (this.pageType === SimpleStickerPageType.FUNNY_BIG_HEAD) {
      this.items = [
        { id: 'reset_item', imageUrl: $rawfile('funnyBigHead/images/reset_item.png') },
        { id: 'big_head', imageUrl: $rawfile('funnyBigHead/images/big_head.png') },
        { id: 'big_head_facewarp2', imageUrl: $rawfile('funnyBigHead/images/big_head_facewarp2.png') },
        { id: 'big_head_facewarp4', imageUrl: $rawfile('funnyBigHead/images/big_head_facewarp4.png') },
        { id: 'big_head_facewarp5', imageUrl: $rawfile('funnyBigHead/images/big_head_facewarp5.png') },
        { id: 'big_head_facewarp6', imageUrl: $rawfile('funnyBigHead/images/big_head_facewarp6.png') },
        { id: 'big_head_smile', imageUrl: $rawfile('funnyBigHead/images/big_head_smile.png') },
      ];
    }
  }

  aboutToAppear() {
    this.initItems()
    this.onPropertyDidChange('selectItemIndex');
  }

  build() {
    Column() {
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
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  getBundlePathWithName(bundleName: string): string {
    if (this.pageType === SimpleStickerPageType.DISTORTING_MIRROR) {
      return `distortingMirror/bundles/${bundleName}.bundle`;
    }
    if (this.pageType === SimpleStickerPageType.FUNNY_BIG_HEAD) {
      return `funnyBigHead/bundles/${bundleName}.bundle`;
    }
    return ''
  }

  updateFUItem() {
    const item = this.items[this.selectItemIndex]
    if (item?.id === 'reset_item') {
      this.destroyCurrentItemIfNeed();
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    } else if (item?.id) {
      this.destroyCurrentItemIfNeed();
      const rawfilePath = this.getBundlePathWithName(item?.id);
      const fuItem = new FUNMItem({ rawfilePath: rawfilePath });
      // 不同页面类型设置不同的item
      if (this.pageType === SimpleStickerPageType.DISTORTING_MIRROR) {
        FUNMRenderKit.sharedInstance().distortingMirror = fuItem;
      } else if (this.pageType === SimpleStickerPageType.FUNNY_BIG_HEAD) {
        FUNMRenderKit.sharedInstance().funnyBigHead = fuItem;
      }
      FUNMRenderKit.sharedInstance().refreshAutoRenderInput()
    }

    // toast 提示
    if (this.pageType === SimpleStickerPageType.FUNNY_BIG_HEAD && item.id === 'big_head_smile') {
      this.showToastCb('微笑触发')
    } else {
      this.showToastCb('')
    }
  }

  private destroyCurrentItemIfNeed() {
    if (FUNMRenderKit.sharedInstance().distortingMirror) {
      FUNMRenderKit.sharedInstance().distortingMirror?.destroy();
      FUNMRenderKit.sharedInstance().distortingMirror = undefined;
    }
    if (FUNMRenderKit.sharedInstance().funnyBigHead) {
      FUNMRenderKit.sharedInstance().funnyBigHead?.destroy();
      FUNMRenderKit.sharedInstance().funnyBigHead = undefined;
    }
  }
}