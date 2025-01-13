import bundleManager from '@ohos.bundle.bundleManager';

export class CommonUtil {
  /**
   * 获取当前应用的BundleInfo
   * @returns 返回一个Promise，该Promise解析为当前应用的BundleInfo对象
   */
  static async getBundleInfo(): Promise<bundleManager.BundleInfo> {
    // 调用bundleManager的getBundleInfoForSelf方法，传入参数以获取包含应用信息的BundleInfo
    return await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
  }

  public static async getAppVersionName(): Promise<string> {
    // 获取包含应用信息的BundleInfo对象
    let bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    // 从BundleInfo对象中提取应用程序的配置信息
    return bundleInfo.versionName;
  }
}