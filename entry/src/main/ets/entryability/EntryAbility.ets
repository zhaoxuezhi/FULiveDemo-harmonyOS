import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { FUNMGlobalContext, FUNMRenderKit } from '@faceunity/renderkit_nama'
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    FUNMRenderKit.destroy()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    FUNMGlobalContext.getContext().setUIAbilityContext(this.context);

    // const mainWin: window.Window = windowStage.getMainWindowSync(); // 获取主窗口的方式
    // let sysBarProps: window.SystemBarProperties = {
    //   statusBarColor: '#160B2A',
    //   statusBarContentColor: '#ffffff'
    // };
    // mainWin.setWindowSystemBarProperties(sysBarProps, undefined);

    const mainWindow = windowStage.getMainWindowSync();
    const windowProperties = mainWindow.getWindowProperties();
    FUNMGlobalContext.getContext().setValue('mainWindowRect', windowProperties.windowRect)
    mainWindow.setWindowLayoutFullScreen(true);
    mainWindow.setWindowSystemBarEnable([]);
    mainWindow.setWindowKeepScreenOn(true, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        console.error('Failed to set the screen to be always on. Cause: ' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in setting the screen to be always on.');
    });

    windowStage.loadContent('pages/modules/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });


  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
