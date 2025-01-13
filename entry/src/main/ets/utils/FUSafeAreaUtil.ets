

class FUSafeAreaUtil {
  private static instance: FUSafeAreaUtil;
  private statusBarHeight: number = 0;
  private bottomBarHeight: number = 0;
  private screenHeight: number = 0;
  private screenWidth: number = 0;

  private constructor() {
  }

  public static getInstance(): FUSafeAreaUtil {
    if (!FUSafeAreaUtil.instance) {
      FUSafeAreaUtil.instance = new FUSafeAreaUtil();
    }
    return FUSafeAreaUtil.instance;
  }

  public setScreenHeight(height: number) {
    this.screenHeight = height
  }

  public getScreenHeight() {
    return this.screenHeight
  }

  public setScreenWidth(width: number) {
    this.screenWidth = width
  }

  public getScreenWidth() {
    return this.screenWidth
  }

  public setStatusBarHeight(height: number) {
    this.statusBarHeight = height || 44;
  }

  public getStatusBarHeight(): number {
    return this.statusBarHeight;
  }

  public setBottomBarHeight(height: number) {
    this.bottomBarHeight = height || 30;
  }

  public getBottomBarHeight(): number {
    return this.bottomBarHeight;
  }
}

export default FUSafeAreaUtil.getInstance();