import { MediaSource } from './MediaSource';
import { MediaLogger } from '../common/MediaLogger';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import media from '@ohos.multimedia.media';
import { MediaSourceType } from './MediaSourceType';

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
        MediaLogger.i(TAG, "filePath = " + filePath)
        let file = await fs.open(filePath, fs.OpenMode.READ_ONLY)
        let url = fdPath + file.fd
        MediaLogger.d(TAG, "createFile = " + url)
        let source = new MediaSource(MediaSourceType.FILE)
        source.url = url
        return source
    }

    /**
     * Create a media source for assets file.
     * @param context The context of ability.
     * @param assetsPath The path of raw assets file.
     */
    public static async createAssets(context: common.Context, assetsPath: string): Promise<MediaSource | undefined> {
        if (context == undefined) {
            MediaLogger.e(TAG, "The context is null!!!")
            return undefined
        }
        MediaLogger.i(TAG, "assetsPath = " + assetsPath)
        let rfd = await context.resourceManager.getRawFd(assetsPath)
        let source = new MediaSource(MediaSourceType.ASSETS)
        source.rawFd = rfd
        return source
    }

    /**
     * Create a media source for network url.
     * @param url The url of media source.
     * @param header The header of http request for network.
     * @param strategy The strategy of http play.
     */
    public static createUrl(url: string, header?: Record<string, string>, strategy?: media.PlaybackStrategy): MediaSource {
        let source = new MediaSource(MediaSourceType.NETWORK, header, strategy)
        source.url = url
        return source
    }
}