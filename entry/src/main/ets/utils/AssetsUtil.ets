import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { JSON } from '@kit.ArkTS';
import { dataSharePredicates } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { FUNMGlobalContext } from '@faceunity/renderkit_nama';
import { image } from '@kit.ImageKit';

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

export async function requestAssets(request: RequestAssetsInterface): Promise<AssetsDataInterface | undefined> {
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
      const asset = await uriGetAssets(photoSelectResult.photoUris)
      const width = asset?.get(photoAccessHelper.PhotoKeys.WIDTH) as number;
      const height = asset?.get(photoAccessHelper.PhotoKeys.HEIGHT) as number;
      const thumbSize:Size = request.compress ? compressToTheRightSize({ width: width, height: height }) : { width: width, height: height };
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

async function uriGetAssets(uris: string[]): Promise<photoAccessHelper.PhotoAsset | undefined> {
  if (!uris || uris.length === 0) {
    return undefined
  }
  try {
    let context: common.UIAbilityContext =
      FUNMGlobalContext.getContext().getUIAbilityContext() as common.UIAbilityContext;
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // 配置查询条件，使用PhotoViewPicker选择图片返回的uri进行查询
    predicates.equalTo('uri', uris[0]);
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

function compressToTheRightSize(size: Size): Size {
  let suitableSize = size;

  const imagePixel = size.width * size.height;
  // 超过限制像素需要压缩
  if (imagePixel > FUPicturePixelMaxSize) {
    const ratio = FUPicturePixelMaxSize / imagePixel;
    suitableSize = { width: size.width * ratio, height: size.height * ratio };
  }

  return suitableSize;
}