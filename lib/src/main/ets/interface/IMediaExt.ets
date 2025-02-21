import { avSession } from '@kit.AVSessionKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { AvSessionCallback } from '../core/AvSessionCallback';
import { MediaSource } from '../data/MediaSource';
import { PiPWindow } from '@kit.ArkUI';

/**
 *
 * Author: Seagazer
 * Date: 2025/2/19
 */
export interface IMediaExt {

    /**
     * Bind av session.
     * @param context The context of app.
     * @param sessionName The name of av session.
     * @param type The type of av session.{@link avSession.AVSessionType}
     * @param agentInfo The agent info of av session.{@link wantAgent.WantAgentInfo}
     */
    bindAvSession(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType, agentInfo: wantAgent.WantAgentInfo): Promise<void>

    /**
     * Add a callback {@link AvSessionCallback} to observe the play action like play next and play previous.
     * @param callback The callback to observe the play action.
     */
    addAvSessionCallback(callback: AvSessionCallback): void

    /**
     * Remove a callback {@link AvSessionCallback} to observe the play action like play next and play previous.
     * @param callback The callback to observe the play action.
     */
    removeAvSessionCallback(callback: AvSessionCallback): void

    /**
     * Set background play or not.
     * @param enable True to start background play, false to stop background play.
     */
    setBackgroundPlayEnable(enable: boolean): void

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
     * Set the pip enable, must call #setXComponentController first.
     * @param pipType The type{@link PiPWindow.PiPTemplateType} of pip window, default is VIDEO_PLAY.
     * @returns The pipController {@link PiPWindow.PiPController} if enable success, return undefined if enable failed or not support pip.
     */
    enablePip(pipType: PiPWindow.PiPTemplateType): Promise<PiPWindow.PiPController | undefined>

    /**
     * Set the pip disable.
     */
    disablePip(): Promise<void>

    /**
     * Start the pip.
     */
    startPip(): Promise<void>

    /**
     * Stop the pip.
     */
    stopPip(): Promise<void>

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
}
