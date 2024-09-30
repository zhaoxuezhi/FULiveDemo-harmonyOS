import { FPSManager } from '../../components/floatComponent/FPSManager'

// 定义装饰器函数
export function hookAboutToAppear(target: Object, key: string, descriptor: PropertyDescriptor) {
  const originalMethod: Function = descriptor.value
  descriptor.value = (...args: Object[]) => {
    // 获取被装饰方法的名称、入参、返回值
    console.log(`Calling ${target.constructor.name} method ${key} with argument: ${args}`)
    const result: Object = originalMethod(...args)
    console.log(`Method ${key} returned: ${result}`)
    return result
  }
  return descriptor
}

// 定义装饰器函数
export function hookAboutToDisAppear(target: Object, key: string, descriptor: PropertyDescriptor) {
  const originalMethod: Function = descriptor.value
  descriptor.value = (...args: Object[]) => {
    // 获取被装饰方法的名称、入参、返回值
    console.log(`Calling ${target.constructor.name} method ${key} with argument: ${args}`)
    const result: Object = originalMethod(...args)
    console.log(`Method ${key} returned: ${result}`)

    // 停止 fps 监听
    FPSManager.getInstance().stopTimer()
    // 移除 fps 视图
    AppStorage.set('showFloatComponent', undefined)

    return result
  }
  return descriptor
}