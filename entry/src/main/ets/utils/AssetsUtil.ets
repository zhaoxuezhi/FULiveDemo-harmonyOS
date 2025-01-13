import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { JSON } from '@kit.ArkTS';
import { dataSharePredicates } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { FUNMGlobalContext } from '@faceunity/renderkit_nama';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';

export type AssetsType = 'photo' | 'video'

// 高性能手机：8294400 稍差点性能的手机：5760000
const FUPicturePixelMaxSize = 8294400

export interface RequestAssetsInterface {
  type: AssetsType
  onlyUri: boolean
  compress: boolean
}

export interface AssetsDataInterface {
  type: AssetsType
  uri: string | undefined
  asset?: photoAccessHelper.PhotoAsset | undefined
  size?: Size | undefined
  thumbnail?: image.PixelMap | undefined
}

export class AssetsUtil {
  /**
   * describe: 检查文件是否存在于沙箱环境中
   * @param filePath 文件路径
   * @returns 返回布尔值，表示文件是否存在
   */
  static async checkFileExistsInSandbox(filePath: string): Promise<boolean> {
    try {
      const stat = await fs.stat(filePath)
      if (stat && stat.size > 0) {
        return true
      }
      return false
    } catch (e) {
      return false
    }
  }

  /**
   * describe: 从沙箱环境中加载图片并创建PixelMap对象用于 Image 组件直接显示
   * @param path 图片文件路径
   * @returns 返回PixelMap对象，如果加载失败则返回undefined
   */
  static async loadPixelMapFromSandbox(path: string): Promise<image.PixelMap | undefined> {
    let file: fs.File | undefined
    try {
      const exists = await AssetsUtil.checkFileExistsInSandbox(path)
      if (!exists) {
        return undefined
      }

      file = fs.openSync(path)
      const pixelMap = await image.createImageSource(file.fd).createPixelMap({
        sampleSize: 1,
        rotate: 0,
        editable: false
      })
      return pixelMap

    } catch (error) {
      console.error(`[AssetsUtil] Failed to load PixelMap from path: ${path}`, error)
      return undefined
    } finally {
      if (file?.fd) {
        fs.close(file.fd)
      }
    }
  }

  /**
   * 根据URI获取媒体文件的详细信息
   * @param uri 媒体文件的URI
   * @returns 返回PhotoAsset对象
   */
  static async getAsset(uri: string): Promise<photoAccessHelper.PhotoAsset | undefined> {
    if (!uri || uri.length === 0) {
      return Promise.resolve(undefined)
    }
    try {
      let context: common.UIAbilityContext =
        FUNMGlobalContext.getContext().getUIAbilityContext() as common.UIAbilityContext;
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      // 配置查询条件，使用PhotoViewPicker选择图片返回的uri进行查询
      predicates.equalTo('uri', uri);
      let fetchOption: photoAccessHelper.FetchOptions = {
        fetchColumns: [photoAccessHelper.PhotoKeys.WIDTH, photoAccessHelper.PhotoKeys.HEIGHT,
          photoAccessHelper.PhotoKeys.TITLE, photoAccessHelper.PhotoKeys.DURATION],
        predicates: predicates
      };
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOption);
      // 得到uri对应的PhotoAsset对象，读取文件的部分信息
      const asset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      console.info('asset displayName: ', asset.displayName);
      console.info('asset uri: ', asset.uri);
      console.info('asset photoType: ', asset.photoType);
      console.info('asset width: ', asset.get(photoAccessHelper.PhotoKeys.WIDTH));
      console.info('asset height: ', asset.get(photoAccessHelper.PhotoKeys.HEIGHT));
      console.info('asset title: ' + asset.get(photoAccessHelper.PhotoKeys.TITLE));
      return asset

    } catch (error) {
      console.error('uriGetAssets failed with err: ' + JSON.stringify(error));
      return undefined
    }
  }

  /**
   * describe: 请求访问相册并获取用户选择的媒体资源
   * @param request 请求参数，包含类型(照片/视频)、是否仅需URI、是否需要压缩等
   * @returns 返回媒体资源信息，包含URI、资源对象、尺寸和缩略图等
   */
  static async requestAssets(request: RequestAssetsInterface): Promise<AssetsDataInterface | undefined> {
    // step1: 打开相册，读取图片/视频
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType =
      request.type === 'photo' ? photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE :
      photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    PhotoSelectOptions.isOriginalSupported = true;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    try {
      const photoSelectResult = await photoPicker.select(PhotoSelectOptions)
      console.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(photoSelectResult));
      // step2: 如果只是获取 uri 则直接返回
      if (request.onlyUri) {
        return {
          type: request.type,
          uri: photoSelectResult.photoUris[0]
        }
      } else {
        // step2: 获取 asset 详情
        const asset = await AssetsUtil.getAsset(photoSelectResult.photoUris[0])
        const width = asset?.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
        const height = asset?.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
        // 缩略图
        let thumbSize: Size = request.compress ? AssetsUtil.compressToTheRightSize({ width: width, height: height }) :
          { width: width, height: height };
        const thumb = await asset?.getThumbnail(thumbSize)
        return {
          type: request.type,
          uri: photoSelectResult.photoUris[0],
          asset: asset,
          size: { width: width, height: height },
          thumbnail: thumb
        }
      }
    } catch (error) {
      console.error(`PhotoViewPicker.select failed with err: ${JSON.stringify(error)}`);
      return undefined
    }
  }

  /**
   * describe: 根据图片尺寸计算合适的压缩后尺寸
   * @param size 原始图片尺寸
   * @returns 返回压缩后的合适尺寸，确保总像素不超过最大限制
   */
  static compressToTheRightSize(size: Size): Size {
    let suitableSize = size;

    const imagePixel = size.width * size.height;
    // 超过限制像素需要压缩
    if (imagePixel > FUPicturePixelMaxSize) {
      const ratio = FUPicturePixelMaxSize / imagePixel;
      suitableSize = { width: size.width * ratio, height: size.height * ratio };
    }

    return suitableSize;
  }
}
