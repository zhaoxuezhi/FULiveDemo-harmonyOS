import { FULogger, FUNMCamera, FUNMDisplayView, grantPermission } from '@faceunity/renderkit_nama';

const xcomponentIdG: string = 'FUNMCameraPageXcomponentId';
const TAG: string = '[CameraPage]';

@Builder
export function CameraPageBuilder(name: string, param: Object) {
  CameraPage()
}

@Component
export struct CameraPage {
  pageInfos: NavPathStack = new NavPathStack();
  private _camera: FUNMCamera | undefined = undefined;
  private _surfaceId: string = '';

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.home_icon'))
            .width(50)
            .height(50)
            .padding(10)
            .onClick(() => {
              this.pageInfos.pop();
            })
          Blank()
            .width('80%')
            .height('10%')
        }

        FUNMDisplayView({
          viewId: xcomponentIdG,
          resolution: { width: 1420, height: 2524 },
          onLoad: this.displayViewOnload
        })
          .width('100%')
          .height('90%')
      }
      .backgroundColor(Color.Black)
      .width('100%')
      .height('100%')
    }
    .onWillAppear(async () => {
      console.info('PPPP onWillAppear');

      // 申请相机权限
      const res = await grantPermission();
      if (res) {
        FULogger.info(TAG, `权限申请成功  ${JSON.stringify(res)}`);
      } else {
        FULogger.error(TAG, `权限申请失败`);
        return
      }

      if (this._camera === undefined) {
        this._camera = new FUNMCamera(getContext(this))
        this._camera.surfaceId = this._surfaceId;
        this._camera.isFrontCamera = true;
        this._camera.resolution = { width: 720, height: 1280 };
        await this._camera.setup();
        await this._camera.startCamera();
      }
    })
    .onWillDisappear(async () => {
      console.info('PPPP onWillDisappear');

      if (this._camera !== undefined) {
        await this._camera.destroy();
        this._camera = undefined;
      }
    })
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
  }

  private displayViewOnload = (surfaceId: string) => {
    console.info(`surfaceId: ${surfaceId}}`);
    this._surfaceId = surfaceId;
  }
}