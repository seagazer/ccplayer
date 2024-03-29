import { MediaSource } from './MediaSource';
import { Logger } from '../common/logger';
import fileIO from '@ohos.fileio'

const TAG = "MediaSourceFactory"

/**
 * Helper to create media source from file, assets and url.
 */
export class MediaSourceFactory {
    /**
     * Create a media source for local file.
     * @param filePath The path of media file.
     * @param title The title of media file, maybe null.
     */
    public static async createFile(filePath: string, title?: string): Promise<MediaSource> {
        let fdPath = 'fd://'
        Logger.i(TAG, "filePath = " + filePath)
        let fd = await fileIO.open(filePath)
        let result = fdPath + fd
        Logger.d(TAG, "createFile = " + result)
        return new MediaSource(result, title)
    }

    /**
     * Create a media source for assets file.
     * @param abilityContext The context of ability.
     * @param assetsPath The path of raw assets file.
     * @param title The title of media file, maybe null.
     */
    public static async createAssets(abilityContext, assetsPath: string, title?: string): Promise<MediaSource> {
        if (abilityContext == undefined) {
            Logger.e(TAG, "The context is null!!!")
            return null
        }
        let fdPath = 'fd://'
        Logger.i(TAG, "assetsPath = " + assetsPath)
        let rfd = await abilityContext.resourceManager.getRawFileDescriptor(assetsPath)
        let result = fdPath + rfd.fd
        Logger.d(TAG, "createAssets = " + result)
        return new MediaSource(result, title)
    }

    /**
     * Create a media source for network url.
     * @param url The url of media file.
     * @param title The title of media file, maybe null.
     */
    public static createUrl(url: string, title?: string): MediaSource{
        return new MediaSource(url, title)
    }
}