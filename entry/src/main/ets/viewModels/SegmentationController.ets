import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { FUNMFileUtil } from '@faceunity/renderkit_nama';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AssetsUtil } from '../utils/AssetsUtil';

interface AssetMataInterface {
  displayName: string,
  uri: string,
  photoType: photoAccessHelper.PhotoType,
  width: number,
  height: number,
}

export class SegmentationController {
  // 缩略图
  thumbImgPixelMap: PixelMap | undefined = undefined
  // 元数据
  assetMataInfo: AssetMataInterface | undefined
  private filesDir: string
  private thumbImgName: string = 'seg/thumb_image.jpg'
  private imageName: string = 'seg/original_image.jpg'
  private videoName: string = 'seg/original_video.mp4'
  private metadataName: string = 'seg/asset_metadata.json'

  constructor() {
    this.filesDir = FUNMFileUtil.fileDir;
  }

  async loadCacheData() {
    this.assetMataInfo = await this.loadAssetMetadata()
    this.thumbImgPixelMap = await AssetsUtil.loadPixelMapFromSandbox(this.thumbImgPath())
  }

  destroy() {
    this.thumbImgPixelMap?.release()
  }

  thumbImgPath(): string {
    const targetPath = `${this.filesDir}/${this.thumbImgName}`
    return targetPath
  }

  originalImgPath(): string {
    const targetPath = `${this.filesDir}/${this.imageName}`
    return targetPath
  }

  videoPath(): string {
    const targetPath = `${this.filesDir}/${this.videoName}`
    return targetPath
  }

  metadataPath(): string {
    const targetPath = `${this.filesDir}/${this.metadataName}`
    return targetPath
  }

  async setAssetUri(uri: string, callback: () => void): Promise<void> {
    console.info('[SegmentationController] setAssetUri start, uri:', uri)

    // 读取原始文件
    const asset = await AssetsUtil.getAsset(uri)
    if (!asset) {
      console.error('[SegmentationController] getMediaFileInfo failed')
      callback()
      return
    }

    console.info('[SegmentationController] start deleting old files')
    // 删除旧文件
    await this.deleteFromSandbox(this.thumbImgPath())
    await this.deleteFromSandbox(this.originalImgPath())
    await this.deleteFromSandbox(this.videoPath())
    await this.deleteFromSandbox(this.metadataPath())

    // 保存到沙盒目录
    const filePath = asset!.photoType === photoAccessHelper.PhotoType.IMAGE ? this.originalImgPath() : this.videoPath()
    console.info('[SegmentationController] saving file to sandbox:', filePath)
    await this.saveToSandbox(asset!.uri, filePath)

    // 保存封面图
    console.info('[SegmentationController] saving thumbnail')
    await this.saveThumbnail(asset!, this.thumbImgPath())

    // 保存元数据
    this.saveAssetMetadata(asset)

    console.info('[SegmentationController] setAssetUri completed')
    // 回调
    callback()
  }

  /**
   * 从沙盒目录读取文件
   * @param fileName 文件名
   * @returns 文件数据
   */
  readFromSandbox(fileName: string): ArrayBuffer | undefined {
    try {
      const filePath = `${this.filesDir}/${fileName}`;
      const buffer = FUNMFileUtil.readBufferFormSandBox(filePath)
      if (buffer) {
        return buffer as ArrayBuffer
      }
      return undefined;
    } catch (error) {
      console.error('Failed to read file from sandbox:', error);
      return undefined;
    }
  }

  // 将pixelMap转成图片格式
  private transferPixelMap2Buffer(pixelMap: image.PixelMap): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      /**
       * 设置打包参数
       * format：图片打包格式，只支持 jpg 和 webp
       * quality：JPEG 编码输出图片质量
       * bufferSize：图片大小，默认 10M
       */
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      // 创建ImagePacker实例
      const imagePackerApi = image.createImagePacker();
      imagePackerApi.packing(pixelMap, packOpts).then((buffer: ArrayBuffer) => {
        resolve(buffer);
      }).catch((_err: BusinessError) => {
        reject();
      })
    })
  }

  /**
   * 保存文件到沙盒目录
   * @param sourceUri 源文件 uri
   * @param fileName 保存的文件名
   * @returns 保存成功的文件路径
   */
  private async saveToSandbox(sourceUri: string, filePath: string): Promise<void> {
    console.info('[SegmentationController] saveToSandbox start, sourceUri:', sourceUri, 'filePath:', filePath)
    // 读取源文件并写入目标文件
    const file = await fs.open(sourceUri, fs.OpenMode.READ_ONLY)
    // 获取文件大小
    const stat = await fs.stat(file.fd)
    const fileSize = stat.size
    console.info('[SegmentationController] file size:', fileSize, 'bytes', `(${(fileSize / 1024 / 1024).toFixed(2)}MB)`)

    // 创建对应的缓冲区
    const buffer = new ArrayBuffer(fileSize)

    // 读取文件到缓冲区
    await fs.read(file.fd, buffer)
    console.info('[SegmentationController] file read completed')

    // 写入沙盒
    FUNMFileUtil.writeFileToSandBox(filePath, buffer)
    console.info('[SegmentationController] file write completed')

    // 关闭文件
    fs.close(file.fd)
    return Promise.resolve()
  }

  /**
   * describe: 保存 asset 元数据到沙盒目录
   * @param asset
   * @returns
   */
  private saveAssetMetadata(asset: photoAccessHelper.PhotoAsset) {
    const metadata: AssetMataInterface = {
      displayName: asset.displayName,
      uri: asset.uri,
      photoType: asset.photoType,
      width: asset.get(photoAccessHelper.PhotoKeys.WIDTH) as number,
      height: asset.get(photoAccessHelper.PhotoKeys.HEIGHT) as number
    }
    this.assetMataInfo = metadata
    const str = JSON.stringify(metadata)
    FUNMFileUtil.writeFileToSandBox(this.metadataPath(), str)
    console.info('[SegmentationController] asset metadata saved')
  }

  /**
   * describe: 从沙盒目录读取并解析 asset 元数据
   * @param
   * @returns
   */
  private async loadAssetMetadata(): Promise<AssetMataInterface | undefined> {
    try {
      const exists = await AssetsUtil.checkFileExistsInSandbox(this.metadataPath())
      if (exists) {
        const str = FUNMFileUtil.readTextFormSandBox(this.metadataPath())
        let mataInfo: AssetMataInterface = JSON.parse(str!) as AssetMataInterface;
        return mataInfo
      }
      return undefined
    } catch (error) {
      console.error('[SegmentationController] Failed to read asset metadata:', error)
      return undefined
    }
  }

  /**
   * 保存缩略图
   * @param asset PhotoAsset对象
   * @param fileName 文件名
   * @returns 缩略图路径
   */
  private async saveThumbnail(asset: photoAccessHelper.PhotoAsset, filePath: string): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        // 创建缩略图选项
        asset.getThumbnail({ width: vp2px(70), height: vp2px(70) }, async (err, pixelMap) => {
          if (err) {
            reject(err);
            return;
          }

          this.thumbImgPixelMap = pixelMap
          // 获取缩略图信息
          const fileSize = pixelMap.getPixelBytesNumber()
          console.info('[SegmentationController] file size:', fileSize, 'bytes',
            `(${(fileSize / 1024 / 1024).toFixed(2)}MB)`)

          // 将pixelMap转换为buffer并保存
          const buffer = await this.transferPixelMap2Buffer(pixelMap)
          FUNMFileUtil.writeFileToSandBox(filePath, buffer)
          resolve()
        });
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 从沙盒目录删除文件
   * @param fileName 文件名
   */
  private async deleteFromSandbox(filePath: string): Promise<void> {
    try {
      await fs.unlink(filePath);
      return Promise.resolve()
    } catch (error) {
      console.error('Failed to delete file from sandbox:', error);
      return Promise.resolve()
    }
  }
}