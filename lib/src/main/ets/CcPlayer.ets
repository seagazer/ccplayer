import avSession from '@ohos.multimedia.avsession';
import media from '@ohos.multimedia.media';
import { IPlayer } from './interface/IPlayer';
import { AvPlayerImpl } from './core/impl/AvPlayerImpl';
import { MediaSource } from './data/MediaSource';
import { PlayerState } from './core/config/PlayerState';
import { MediaLogger } from './common/MediaLogger';
import common from '@ohos.app.ability.common';
import { AvSessionManager } from './core/AvSessionManager';
import wantAgent from '@ohos.app.ability.wantAgent';
import { BackgroundPlayManager } from './core/BackgroundPlayManager';
import { AvSessionCallback } from './core/config/AvSessionCallback';
import { PiPWindow, window } from '@kit.ArkUI';
import { AudioFocusEvent } from './core/config/AudioFocusEvent';
import { IMediaExt } from './interface/IMediaExt';
import { fileIo } from '@kit.CoreFileKit';
import { IAvSession } from './interface/IAvSession';
import { IPip } from './interface/IPip';
import { PipManager } from './core/PipManager';

const TAG = '[CcPlayer]'

/**
 * The player for audio or video.
 *
 * Author: Seagazer
 * Date: 2022/8/17
 */
export class CcPlayer implements IPlayer, IAvSession, IPip, IMediaExt {
    private player: IPlayer
    private context: Context
    private isBackgroundPlay = false
    private avSessionManager?: AvSessionManager = undefined
    private agentInfo?: wantAgent.WantAgentInfo = undefined
    private onMediaChangedListeners: Array<(source: MediaSource) => void> = new Array()
    private xComponentController?: XComponentController = undefined
    private pipManager?: PipManager = undefined
    private defaultAudioFocusChangedListener: (event: AudioFocusEvent) => void = (event: AudioFocusEvent) => {
        switch (event) {
            case AudioFocusEvent.AUDIO_FOCUS_LOST:
                if (this.player.isPlaying()) {
                    this.pause()
                }
                break
            case AudioFocusEvent.AUDIO_FOCUS_GAIN:
                if (this.player.getPlayerState() == PlayerState.STATE_PAUSED) {
                    this.start()
                }
                break
        }
    }

    constructor(context: Context) {
        this.context = context
        this.player = AvPlayerImpl.create(context)
        this.init()
    }

    private init() {
        if (this.avSessionManager) {
            MediaLogger.attentionW(TAG, "The instance of the player is changed, release the av session and reInit again!")
            this.avSessionManager.release()
        }
        this.avSessionManager = new AvSessionManager(this.player)
        this.player.addOnAudioFocusChangedListener(this.defaultAudioFocusChangedListener)
    }

    /**
     * Set the player instance implements the {@link IPlayer}.
     * @param player
     */
    public setPlayer(player: IPlayer) {
        this.player = player
        this.init()
    }

    start() {
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_STARTED) {
            MediaLogger.attentionW(TAG, 'current is playing, not start!')
            return
        }
        this.player.start()
    }

    startTo(position: number) {
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_STARTED) {
            return
        }
        this.player.startTo(position)
    }

    pause() {
        let state = this.getPlayerState()
        if (state != PlayerState.STATE_STARTED) {
            return
        }
        this.player.pause()
    }

    stop() {
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_STOPPED) {
            return
        }
        this.player.stop()
    }

    reset() {
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_IDLE) {
            return
        }
        this.player.reset()
    }

    release() {
        if (this.avSessionManager) {
            this.avSessionManager.release()
        }
        if (this.isBackgroundPlay && this.context) {
            BackgroundPlayManager.stopBackground(this.context)
        }
        this.disablePip()
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_NOT_INIT) {
            return
        }
        this.player.removeOnAudioFocusChangedListener(this.defaultAudioFocusChangedListener)
        this.player.release()
    }

    seekTo(position: number) {
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_PREPARED || state == PlayerState.STATE_STARTED ||
            state == PlayerState.STATE_PAUSED || state == PlayerState.STATE_COMPLETED) {
            this.player.seekTo(position)
        }
    }

    setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        this.onMediaChangedListeners.forEach((onMediaChanged) => {
            onMediaChanged(mediaSource)
        })
        this.player.setMediaSource(mediaSource, onReady)
        this.avSessionManager?.setMediaSource(mediaSource)
    }

    setLooper(isLoop: boolean) {
        this.player.setLooper(isLoop)
    }

    setVolume(vol: number) {
        this.player.setVolume(vol)
    }

    setPlaySpeed(speed: number | media.PlaybackSpeed): void {
        this.player.setPlaySpeed(speed)
    }

    isPlaying(): boolean {
        return this.player.isPlaying()
    }

    getDuration(): number {
        return this.player.getDuration()
    }

    getCurrentPosition(): number {
        return this.player.getCurrentPosition()
    }

    getPlayerState(): PlayerState {
        return this.player.getPlayerState()
    }

    setSurface(surfaceId: string) {
        this.player.setSurface(surfaceId)
    }

    getMediaSource(): MediaSource | undefined {
        return this.player.getMediaSource()
    }

    getSystemPlayer(): media.AVPlayer | IPlayer {
        return this.player.getSystemPlayer()
    }

    addOnPreparedListener(listener: () => void): IPlayer {
        this.player.addOnPreparedListener(listener)
        return this
    }

    removeOnPreparedListener(listener: () => void): IPlayer {
        this.player.removeOnPreparedListener(listener)
        return this
    }

    addOnCompletionListener(listener: () => void): IPlayer {
        this.player.addOnCompletionListener(listener)
        return this
    }

    removeOnCompletionListener(listener: () => void): IPlayer {
        this.player.removeOnCompletionListener(listener)
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.player.addOnErrorListener(listener)
        return this
    }

    removeOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.player.removeOnErrorListener(listener)
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnProgressChangedListener(listener)
        return this
    }

    removeOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.removeOnProgressChangedListener(listener)
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnSeekChangedListener(listener)
        return this
    }

    removeOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.removeOnSeekChangedListener(listener)
        return this
    }

    addOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        this.player.addOnVolumeChangedListener(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        this.player.removeOnVolumeChangedListener(listener)
        return this
    }

    addOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer {
        this.player.addOnStateChangedListener(listener)
        return this
    }

    removeOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer {
        this.player.removeOnStateChangedListener(listener)
        return this
    }

    addOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer {
        this.player.addOnVideoSizeChangedListener(listener)
        return this
    }

    removeOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer {
        this.player.removeOnVideoSizeChangedListener(listener)
        return this
    }

    addOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.player.addOnRenderFirstFrameListener(listener)
        return this
    }

    removeOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.player.removeOnRenderFirstFrameListener(listener)
        return this
    }

    addOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.player.removeOnAudioFocusChangedListener(this.defaultAudioFocusChangedListener)
        this.player.addOnAudioFocusChangedListener(listener)
        return this
    }

    removeOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.player.removeOnAudioFocusChangedListener(listener)
        return this
    }

    async bindAvSession(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType,
        agentInfo: wantAgent.WantAgentInfo) {
        this.agentInfo = agentInfo
        this.avSessionManager!.bindAvSession(context, sessionName, type, agentInfo)
    }

    addAvSessionCallback(callback: AvSessionCallback) {
        this.avSessionManager!.addAvSessionCallback(callback)
    }

    removeAvSessionCallback(callback: AvSessionCallback) {
        this.avSessionManager!.removeAvSessionCallback(callback)
    }

    async setBackgroundPlayEnable(enable: boolean) {
        if (!this.context) {
            MediaLogger.attentionW(TAG, "The context is null.")
            return false
        }
        if (!this.agentInfo) {
            MediaLogger.attentionW(TAG, "The agent is null, you should call {@Link bindAvSession} first.")
            return false
        }
        if (this.isBackgroundPlay == enable) {
            return false
        }
        let result = false
        if (enable) {
            MediaLogger.d(TAG, "start background play")
            result = await BackgroundPlayManager.startBackground(this.context, this.agentInfo)
        } else {
            MediaLogger.d(TAG, "stop background play")
            result = await BackgroundPlayManager.stopBackground(this.context)
        }
        this.isBackgroundPlay = enable
        return result
    }

    addOnMediaChangedListener(listener: (source: MediaSource) => void) {
        this.onMediaChangedListeners.push(listener)
    }

    removeOnMediaChangedListener(listener: (source: MediaSource) => void) {
        let index = this.onMediaChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.onMediaChangedListeners.splice(index, 1)
        }
    }

    setXComponentController(controller: XComponentController) {
        if (this.xComponentController != controller) {
            MediaLogger.d(TAG, "set xComponent controller= " + controller)
            this.xComponentController = controller
            this.pipManager?.notifyControllerChanged()
        }
    }

    getXComponentController(): XComponentController | undefined {
        return this.xComponentController
    }

    private checkPipManagerNotNull() {
        if (!this.pipManager) {
            this.pipManager = new PipManager(this, this.context)
        }
    }

    async enablePip(pipType: PiPWindow.PiPTemplateType = PiPWindow.PiPTemplateType.VIDEO_PLAY) {
        this.checkPipManagerNotNull()
        await this.pipManager!.enablePip(pipType)
    }

    async disablePip() {
        this.checkPipManagerNotNull()
        await this.pipManager!.disablePip()
    }

    async startPip() {
        this.checkPipManagerNotNull()
        await this.pipManager!.startPip()
    }

    async stopPip() {
        this.checkPipManagerNotNull()
        await this.pipManager!.stopPip()
    }

    addOnPipStateChangedListener(listener: (state: PiPWindow.PiPState, reason: string) => void): void {
        this.checkPipManagerNotNull()
        this.pipManager!.addOnPipStateChangedListener(listener)
    }

    removeOnPipStateChangedListener(listener: (state: PiPWindow.PiPState, reason: string) => void): void {
        this.checkPipManagerNotNull()
        this.pipManager!.removeOnPipStateChangedListener(listener)
    }

    async getSnapshotFromFile(filePath: string, width: number, height: number, timestamp: number): Promise<PixelMap | undefined> {
        try {
            const imageG = await media.createAVImageGenerator()
            let file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY)
            imageG.fdSrc = { fd: file.fd }
            const result =
                await imageG.fetchFrameByTime(timestamp, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, { width: width, height: height })
            await imageG.release()
            fileIo.close(file.fd)
            return result
        } catch (e) {
            MediaLogger.attentionE(TAG, 'getSnapshotFromFile error= ' + JSON.stringify(e))
            return undefined
        }
    }

    async getSnapshotFromAssets(rawPath: string, width: number, height: number, timestamp: number): Promise<PixelMap | undefined> {
        try {
            const imageG = await media.createAVImageGenerator()
            const afd = this.context.resourceManager.getRawFdSync(rawPath)
            imageG.fdSrc = afd
            const result =
                await imageG.fetchFrameByTime(timestamp, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, { width: width, height: height })
            await imageG.release()
            this.context.resourceManager.closeRawFdSync(rawPath)
            return result
        } catch (e) {
            MediaLogger.attentionE(TAG, 'getSnapshotFromAssets error= ' + JSON.stringify(e))
            return undefined
        }
    }

    async setKeepScreenOn(uiContext: UIContext, keepScreenOn: boolean): Promise<boolean> {
        try {
            await window.findWindow(uiContext.getWindowName()).setWindowKeepScreenOn(keepScreenOn)
            return true
        } catch (e) {
            MediaLogger.attentionE(TAG, 'setKeepScreenOn cause error= ' + JSON.stringify(e))
            return false
        }
    }
}