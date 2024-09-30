import { FUNMGlobalContext } from '@faceunity/renderkit_nama';
import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';

// 获取相册权限
export async function requestMediaPermission(): Promise<boolean> {
  let ctx: common.UIAbilityContext = FUNMGlobalContext.getContext().getUIAbilityContext() as common.UIAbilityContext;
  let atManager = abilityAccessCtrl.createAtManager();
  let result: PermissionRequestResult = await atManager.requestPermissionsFromUser(ctx, ["ohos.permission.READ_IMAGEVIDEO"]);
  if (result.authResults[0] === 0) {
    return true
  } else {
    return false
  }
}