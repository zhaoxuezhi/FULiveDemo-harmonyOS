import { FULogger } from "@faceunity/renderkit_nama";
import { NodeController, BuilderNode, FrameNode, UIContext } from "@kit.ArkUI";
import { SaveScreenshotCallBack } from '../../utils/CallBack';
import { StickerView } from './StickerView';

class Params {
  autoRender: boolean;
  cbObject?: SaveScreenshotCallBack;

  constructor(autoRender: boolean, cb: SaveScreenshotCallBack) {
    this.autoRender = autoRender;
    this.cbObject = cb;
  }
}

@Builder
function buildText(params: Params) {
  Column() {
    StickerView({ autoRender: params.autoRender, callBackObject: params.cbObject })
      .width('100%')
      .height('100%')
  }
}

export class StickerViewNodeController extends NodeController {
  private textNode: BuilderNode<[Params]> | null = null;
  private autoRender: boolean = true;
  private cbObject?: SaveScreenshotCallBack;

  constructor(autoRender: boolean, cbObject: SaveScreenshotCallBack) {
    super()
    this.autoRender = autoRender
    this.cbObject = cbObject;
  }

  makeNode(context: UIContext): FrameNode | null {
    if (!this.textNode) {
      this.textNode = new BuilderNode(context);
      this.textNode.build(wrapBuilder<[Params]>(buildText), new Params(this.autoRender, this.cbObject))
    }
    return this.textNode.getFrameNode();
  }

  destroy() {
    if (this.textNode) {
      this.textNode.dispose();
      this.textNode = null;
    }
  }

  update(autoRender: boolean, cbObject?: SaveScreenshotCallBack) {
    if (this.textNode !== null) {
      // 调用update进行更新。
      this.autoRender = autoRender;
      this.cbObject = cbObject;
      this.textNode.update(new Params(autoRender, cbObject));
    }
  }
}