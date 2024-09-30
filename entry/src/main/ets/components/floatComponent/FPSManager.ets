export class FPSManager {
  private static instance: FPSManager
  private timer: number | undefined

  private constructor() {
  }

  public static getInstance(): FPSManager {
    if (!FPSManager.instance) {
      FPSManager.instance = new FPSManager()
    }
    return FPSManager.instance
  }

  public startMonitor() {
    if (this.timer) {
      return
    }
    this.timer = setInterval(() => {
      const random = Math.floor(Math.random() * 61)
      AppStorage.set('FPSValue', random)
      console.log('FPSManager timer go -----')
    }, 1000)
  }

  public stopTimer() {
    if (this.timer != undefined) {
      clearInterval(this.timer)
      this.timer = undefined
    }
  }
}