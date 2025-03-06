import { MediaSource } from '../data/MediaSource';

/**
 *
 * Author: Seagazer
 * Date: 2025/2/19
 */
export interface IMediaExt {

    /**
     * Set background play or not.
     * @param enable True to start background play, false to stop background play.
     * @returns True set success, false set failed.
     */
    setBackgroundPlayEnable(enable: boolean): Promise<boolean>

    /**
     * Add a listener to observe the media source changed.
     * @param listener The listener to observe the media source changed.
     */
    addOnMediaChangedListener(listener: (source: MediaSource) => void): void

    /**
     * Remove a listener to observe the media source changed.
     * @param listener The listener to observe the media source changed.
     */
    removeOnMediaChangedListener(listener: (source: MediaSource) => void): void

    /**
     * Set the controller of XComponent to play video.
     * @param controller The controller{@link XComponentController} of XComponent to play video.
     */
    setXComponentController(controller: XComponentController): void

    /**
     * Return the controller of XComponent.
     * @returns The controller of XComponent, return undefined if not set.
     */
    getXComponentController(): XComponentController | undefined

    /**
     * Get the snapshot of the media, only support video.
     * Attention: The function must be call and return result before setMediaSource because this will modify the src file.
     *
     * @param filePath The path of media file.
     * @param width The width of snapshot image.
     * @param height The height of snapshot image.
     * @param timestamp The timestamp of media to generate snapshot.
     * @returns The snapshot of video.
     */
    getSnapshotFromFile(filePath: string, width: number, height: number, timestamp: number): Promise<PixelMap | undefined>

    /**
     * Get the snapshot of the media, only support video.
     * Attention: The function must be call and return result before setMediaSource because this will modify the src file.
     *
     * @param rawPath The raw path of media file.
     * @param width The width of snapshot image.
     * @param height The height of snapshot image.
     * @param timestamp The timestamp of media to generate snapshot.
     * @returns The snapshot of video.
     */
    getSnapshotFromAssets(rawPath: string, width: number, height: number, timestamp: number): Promise<PixelMap | undefined>

    /**
     * Set keep screen on or not.
     * @param uiContext The context of current ui.
     * @param keepScreenOn Screen on or not.
     * @returns Set result, return true success.
     */
    setKeepScreenOn(uiContext: UIContext, keepScreenOn: boolean): Promise<boolean>
}
