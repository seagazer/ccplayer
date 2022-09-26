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
     * @param title The title of media file.
     * @param filePath The path of media file.
     */
    public static async createFile(title: string, filePath: string): Promise<MediaSource> {
        let fdPath = 'fd://'
        Logger.d(TAG, "filePath = " + filePath)
        let fd = await fileIO.open(filePath)
        let result = fdPath + '' + fd
        Logger.d(TAG, "createFile = " + result)
        return new MediaSource(title, result)
    }

    /**
     * Create a media source for assets file.
     * @param abilityContext The context of ability.
     * @param title The title of media file.
     * @param assetsPath The path of raw assets file.
     */
    public static async createAssets(abilityContext, title: string, assetsPath: string): Promise<MediaSource> {
        if (abilityContext == undefined) {
            Logger.e(TAG, "The context is null!!!")
        }
        let fdPath = 'fd://'
        Logger.d(TAG, "assetsPath = " + assetsPath)
        let rfd = await abilityContext.resourceManager.getRawFileDescriptor(assetsPath)
        let result = fdPath + '' + rfd.fd
        Logger.d(TAG, "createAssets = " + result)
        return new MediaSource(title, result)
    }

    /**
     * Create a media source for network url.
     * @param title The title of media file.
     * @param url The url of media file.
     */
    public static createUrl(title: string, url: string): MediaSource{
        return new MediaSource(title, url)
    }
}