interface ThrottleManagerInterface {
  callback: Function;
  delay?: number;
  leading?: boolean;
  trailing?: boolean;
}

export class ThrottleManager {
  private lastExecTime: number = 0
  private timer: number | null = null
  private readonly delay: number
  private readonly leading: boolean
  private readonly trailing: boolean
  private readonly callback: Function

  constructor(options: ThrottleManagerInterface) {
    this.callback = options.callback
    this.delay = options.delay ?? 300
    this.leading = options.leading ?? false
    this.trailing = options.trailing ?? true
  }

  execute(): void {
    const currentTime = Date.now()
    const firstTime = !this.lastExecTime

    // leading为true且是第一次调用,立即执行
    if (this.leading && firstTime) {
      this.lastExecTime = currentTime
      this.runCallback()
      return
    }

    const remainTime = this.delay - (currentTime - this.lastExecTime)

    // 如果在节流时间内
    if (remainTime > 0) {
      // 如果trailing为true且没有定时器,设置定时器
      if (this.trailing && this.timer === null) {
        this.timer = setTimeout(() => {
          this.lastExecTime = this.trailing ? Date.now() : 0
          this.timer = null
          this.runCallback()
        }, remainTime)
      }
      return
    }

    // 已经超出节流时间,立即执行
    this.lastExecTime = currentTime
    this.runCallback()
  }

  private runCallback(): void {
    this.callback()
  }

  clear(): void {
    if (this.timer !== null) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }
}