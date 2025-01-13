import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI';
import { SaveScreenshotCallBack } from '../../utils/CallBack';
import { MakeupPageView } from './MakeupPageView';

interface WidgetInterface {
  autoRender?: boolean // 是否显示在摄像头画面
  cbObject?: SaveScreenshotCallBack
}

@Builder
function buildWidget(params: WidgetInterface) {
  Column() {
    MakeupPageView({
      autoRender: params.autoRender,
      callBackObject: params.cbObject
    })
      .width('100%')
      .height('100%')
  }
}

export class MakeupViewNodeController extends NodeController {
  private autoRender: boolean = true;
  private cbObject?: SaveScreenshotCallBack;
  private textNode: BuilderNode<[WidgetInterface]> | null = null;

  constructor(autoRender: boolean, cbObject: SaveScreenshotCallBack) {
    super()
    this.autoRender = autoRender
    this.cbObject = cbObject;
  }

  makeNode(context: UIContext): FrameNode | null {
    if (!this.textNode) {
      this.textNode = new BuilderNode(context);
      this.textNode.build(wrapBuilder(buildWidget), { autoRender: this.autoRender, cbObject: this.cbObject })
    }
    return this.textNode.getFrameNode();
  }

  update(autoRender: boolean, cbObject?: SaveScreenshotCallBack) {
    if (this.textNode) {
      // 调用update进行更新。
      this.autoRender = autoRender;
      this.cbObject = cbObject;
      this.textNode.update({ autoRender, cbObject } as WidgetInterface);
    }
  }

  destroy() {
    if (this.textNode) {
      this.textNode.dispose();
      this.textNode = null;
    }
  }
}