import { MediaSource } from './MediaSource';
import { MediaLogger } from '../MediaLogger';
import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import { MediaSourceType } from './MediaSourceType';

const TAG = "[MediaSourceFactory]"

/**
 * Helper to create media source from file, assets and url.
 *
 * Author: Seagazer
 * Date: 2022/8/17
 */
export class MediaSourceFactory {
    /**
     * Create a media source for local file.
     * @param title The title of media.
     * @param filePath The path of media file.
     * @param cover The cover image of media file.
     */
    public static async createFile(title: string, filePath: string, cover?: string | PixelMap): Promise<MediaSource> {
        let fdPath = 'fd://'
        MediaLogger.i(TAG, "filePath = " + filePath)
        let file = await fs.open(filePath, fs.OpenMode.READ_ONLY)
        let url = fdPath + file.fd
        MediaLogger.d(TAG, "createFile = " + url)
        let source = new MediaSource(MediaSourceType.FILE, title, cover)
        source.url = url
        return source
    }

    /**
     * Create a media source for assets file.
     * @param title The title of media.
     * @param rawAssetsPath The path of raw assets file.
     * @param cover The cover image of media file.
     */
    public static createAssets(title: string, rawAssetsPath: string, cover?: string | PixelMap): MediaSource {
        MediaLogger.i(TAG, "rawAssetsPath = " + rawAssetsPath)
        let source = new MediaSource(MediaSourceType.ASSETS, title, cover)
        source.rawAssetsPath = rawAssetsPath
        return source
    }

    /**
     * Create a media source for network url.
     * @param title The title of media.
     * @param url The url of media source.
     * @param cover The cover image of media file.
     * @param header The header of http request for network.
     * @param strategy The strategy of http play.
     */
    public static createUrl(title: string, url: string, cover?: string | PixelMap, header?: Record<string, string>,
        strategy?: media.PlaybackStrategy): MediaSource {
        let source = new MediaSource(MediaSourceType.NETWORK, title, cover, header, strategy)
        source.url = url
        return source
    }
}