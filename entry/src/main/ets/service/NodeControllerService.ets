import { BeautyViewNodeController } from '../components/beauty/BeautyViewNodeController';
import { MakeupViewNodeController } from '../components/makeup/MakeupViewNodeController';
import { StickerViewNodeController } from '../components/sticker/StickerViewNodeController';
import { SaveScreenshotCallBack } from '../utils/CallBack';

export class NodeControllerService {
  private static instance: NodeControllerService | undefined = undefined;
  private beautyNodeController: BeautyViewNodeController | undefined = undefined;
  private stickerNodeController: StickerViewNodeController | undefined = undefined;
  private makeupNodeController: MakeupViewNodeController | undefined = undefined

  private constructor() {
  }

  static sharedInstance(): NodeControllerService {
    if (!NodeControllerService.instance) {
      NodeControllerService.instance = new NodeControllerService();
    }
    return NodeControllerService.instance;
  }

  static destroy() {
    NodeControllerService.instance = undefined;
  }

  // 美颜
  getBeautyViewNodeController(): BeautyViewNodeController {
    if (!this.beautyNodeController) {
      this.beautyNodeController = new BeautyViewNodeController(true, new SaveScreenshotCallBack(() => {
      }));
    }
    return this.beautyNodeController;
  }

  updateBeautyViewNodeController(autoRender: boolean, cbObject?: SaveScreenshotCallBack) {
    this.beautyNodeController?.update(autoRender, cbObject);
  }

  destroyBeautyViewNodeController() {
    if (this.beautyNodeController) {
      this.beautyNodeController.destroy();
      this.beautyNodeController = undefined;
    }
  }

  // 贴纸
  getStickerViewNodeController(): StickerViewNodeController {
    if (!this.stickerNodeController) {
      this.stickerNodeController = new StickerViewNodeController(true, new SaveScreenshotCallBack(() => {
      }));
    }
    return this.stickerNodeController;
  }

  updateStickerViewNodeController(autoRender: boolean, cbObject?: SaveScreenshotCallBack) {
    this.stickerNodeController?.update(autoRender, cbObject);
  }

  destroyStickerViewNodeController() {
    if (this.stickerNodeController) {
      this.stickerNodeController.destroy();
      this.stickerNodeController = undefined;
    }
  }

  // 美妆
  getMakeupViewNodeController(): MakeupViewNodeController {
    if (!this.makeupNodeController) {
      this.makeupNodeController = new MakeupViewNodeController(true, new SaveScreenshotCallBack(() => {
      }))
    }
    return this.makeupNodeController as MakeupViewNodeController
  }

  updateMakeupViewNodeController(autoRender: boolean, cbObject?: SaveScreenshotCallBack) {
    this.makeupNodeController?.update(autoRender, cbObject);
  }

  destroyMakeupViewNodeController() {
    if (this.makeupNodeController) {
      this.makeupNodeController.destroy();
      this.makeupNodeController = undefined;
    }
  }
}