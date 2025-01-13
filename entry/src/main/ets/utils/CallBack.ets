
export class SaveScreenshotCallBack {
  cb: () => void;

  constructor(cb: () => void) {
    this.cb = cb;
  }
}