import { MediaSource } from './MediaSource';
import { MediaLogger } from '../common/MediaLogger';
import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import { MediaSourceType } from './MediaSourceType';

const TAG = "[MediaSourceFactory]"

/**
 * Helper to create media source from file, assets and url.
 */
export class MediaSourceFactory {
    /**
     * Create a media source for local file.
     * @param title The title of media.
     * @param filePath The path of media file.
     */
    public static async createFile(title: string, filePath: string): Promise<MediaSource> {
        let fdPath = 'fd://'
        MediaLogger.i(TAG, "filePath = " + filePath)
        let file = await fs.open(filePath, fs.OpenMode.READ_ONLY)
        let url = fdPath + file.fd
        MediaLogger.d(TAG, "createFile = " + url)
        let source = new MediaSource(MediaSourceType.FILE, title)
        source.url = url
        return source
    }

    /**
     * Create a media source for assets file.
     * @param title The title of media.
     * @param rawAssetsPath The path of raw assets file.
     */
    public static async createAssets(title: string, rawAssetsPath: string): Promise<MediaSource | undefined> {
        MediaLogger.i(TAG, "rawAssetsPath = " + rawAssetsPath)
        let source = new MediaSource(MediaSourceType.ASSETS, title)
        source.rawAssetsPath = rawAssetsPath
        return source
    }

    /**
     * Create a media source for network url.
     * @param title The title of media.
     * @param url The url of media source.
     * @param header The header of http request for network.
     * @param strategy The strategy of http play.
     */
    public static createUrl(title: string, url: string, header?: Record<string, string>, strategy?: media.PlaybackStrategy): MediaSource {
        let source = new MediaSource(MediaSourceType.NETWORK, title, header, strategy)
        source.url = url
        return source
    }
}