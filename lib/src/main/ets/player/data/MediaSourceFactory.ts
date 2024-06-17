import { MediaSource } from './MediaSource';
import { Logger } from '../common/logger';
import fs from '@ohos.file.fs'
import common from '@ohos.app.ability.common';
import media from '@ohos.multimedia.media';

const TAG = "[MediaSourceFactory]"

/**
 * Helper to create media source from file, assets and url.
 */
export class MediaSourceFactory {
    /**
     * Create a media source for local file.
     * @param filePath The path of media file.
     */
    public static async createFile(filePath: string): Promise<MediaSource> {
        let fdPath = 'fd://'
        Logger.i(TAG, "filePath = " + filePath)
        let file = await fs.open(filePath, fs.OpenMode.READ_ONLY)
        let result = fdPath + file.fd
        Logger.d(TAG, "createFile = " + result)
        return new MediaSource(result)
    }

    /**
     * Create a media source for assets file.
     * @param context The context of ability.
     * @param assetsPath The path of raw assets file.
     */
    public static async createAssets(context: common.Context, assetsPath: string): Promise<MediaSource> {
        if (context == undefined) {
            Logger.e(TAG, "The context is null!!!")
            return null
        }
        let fdPath = 'fd://'
        Logger.i(TAG, "assetsPath = " + assetsPath)
        let rfd = await context.resourceManager.getRawFd(assetsPath)
        let result = fdPath + rfd.fd
        Logger.d(TAG, "createAssets = " + result)
        return new MediaSource(result)
    }

    /**
     * Create a media source for network url.
     * @param url The url of media source.
     * @param header The header of http request for network.
     * @param strategy The strategy of http play.
     */
    public static createUrl(url: string, header: Record<string, string> = null, strategy: media.PlaybackStrategy = null): MediaSource {
        return new MediaSource(url, header, strategy)
    }
}