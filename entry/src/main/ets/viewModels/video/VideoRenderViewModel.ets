import {
  FULogger,
  FUNMFileUtil,
  FUNMImageOrientation,
  FUNMImageUtil,
  FUNMInputBufferFormat,
  FUNMNormalInput,
  FUNMOutputType,
  FUNMRenderConfig,
  FUNMRenderInput,
  FUNMRenderKit
} from "@faceunity/renderkit_nama";
import { image } from "@kit.ImageKit";
import { RenderKitService } from "../../service/RenderKitService";

export const VideoRenderXcomponentIdG: string = 'VideoRenderXcomponentIdG';

export class VideoRenderViewModel {
  thumbnail: image.PixelMap | undefined = undefined;
  private renderTimer: number | undefined = undefined;
  private input: FUNMRenderInput | undefined = undefined;
  private isPreviewing = false;

  async destroy() {
    this.stopPreviewing();

    if (this.thumbnail) {
      await this.thumbnail.release();
    }
  }

  /**
   * 开始视频首帧预览
   */
  async startPreviewing() {
    if (this.isPreviewing) {
      FULogger.warn('It is already in preview');
      return;
    }

    if (this.thumbnail === undefined) {
      FULogger.warn('startPreviewing，thumbnail is nil');
      return;
    }

    if (this.input === undefined) {
      const pixelMap = this.thumbnail;
      let input_buffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
      pixelMap.readPixelsToBufferSync(input_buffer);
      let info = pixelMap.getImageInfoSync();

      const configT = new FUNMRenderConfig();
      configT.xcomponentId = VideoRenderXcomponentIdG;
      configT.outputType = FUNMOutputType.XCOMPONENT;

      const nInput = new FUNMNormalInput();
      nInput.pixelBuffer = input_buffer;
      nInput.pixelFormat = FUNMInputBufferFormat.RGBA_BUFFER;

      const input = new FUNMRenderInput(configT);
      input.normalInput = nInput;

      input.inputSize = { width: info.size.width, height: info.size.height };
      this.input = input;
    }

    this.isPreviewing = true;
    this.renderTimer = setInterval(() => {
      if (this.input) {
        FUNMRenderKit.renderWithInput(this.input)
      }
    }, 66);
  }

  /**
   * 停止预览
   */
  stopPreviewing() {
    if (this.renderTimer != undefined) {
      clearInterval(this.renderTimer)
      this.renderTimer = undefined
    }

    this.isPreviewing = false;
    // TODO: 待完善
    // FUNMRenderKit.clearRenderTasks();
    // FUNMRenderKit.releaseGLResource();
  }
}