import avSession from '@ohos.multimedia.avsession';
import media from '@ohos.multimedia.media';
import { IPlayer } from './interface/IPlayer';
import { AvPlayerImpl } from './core/AvPlayerImpl';
import { MediaSource } from './data/MediaSource';
import { PlayerState } from './config/PlayerState';
import { MediaLogger } from './common/MediaLogger';
import common from '@ohos.app.ability.common';
import { AvSessionManager } from './core/AvSessionManager';
import wantAgent from '@ohos.app.ability.wantAgent';
import { BackgroundPlayManager } from './core/BackgroundPlayManager';
import { AvSessionCallback } from './core/AvSessionCallback';
import { PiPWindow } from '@kit.ArkUI';

const TAG = '[CcPlayer]'

/**
 * The player for audio or video.
 *
 * Author: Seagazer
 * Date: 2022/8/17
 */
export class CcPlayer implements IPlayer {
    private player: IPlayer
    private context: Context
    private isBackgroundPlay = false
    private avSessionManager?: AvSessionManager = undefined
    private agentInfo?: wantAgent.WantAgentInfo = undefined
    private onMediaChangedListeners: Array<(source: MediaSource) => void> = new Array()
    private xComponentController?: XComponentController = undefined
    private isControllerChanged: boolean = false
    private pipController?: PiPWindow.PiPController = undefined
    private pipType: PiPWindow.PiPTemplateType = PiPWindow.PiPTemplateType.VIDEO_PLAY

    constructor(context: Context) {
        this.context = context
        this.player = AvPlayerImpl.create(context)
        this.init()
    }

    private init() {
        this.avSessionManager = new AvSessionManager(this.player)
        this.player.addOnStateChangedListener((state) => {
            if (state == PlayerState.STATE_STARTED) {
                this.pipController?.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, PiPWindow.PiPControlStatus.PLAY)
            } else {
                this.pipController?.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, PiPWindow.PiPControlStatus.PAUSE)
            }
        })
        this.player.addOnVideoSizeChangedListener((w, h) => {
            this.pipController?.updateContentSize(w, h)
        })
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
            MediaLogger.w(TAG, 'current is playing, not start!')
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

    getSystemPlayer(): media.AVPlayer {
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

    addOnVolumeChangedListener(listener: () => void): IPlayer {
        this.player.addOnVolumeChangedListener(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: () => void): IPlayer {
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

    /**
     * Bind av session.
     * @param context The context of app.
     * @param sessionName The name of av session.
     * @param type The type of av session.{@link avSession.AVSessionType}
     * @param agentInfo The agent info of av session.{@link wantAgent.WantAgentInfo}
     */
    async bindAvSession(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType,
        agentInfo: wantAgent.WantAgentInfo) {
        this.agentInfo = agentInfo
        try {
            await this.avSessionManager!.create(context, sessionName, type)
            await this.avSessionManager!.setLaunchInfo(agentInfo)
            await this.avSessionManager!.bind()
        } catch (e) {
            MediaLogger.e(TAG, "bindAvSession error: " + JSON.stringify(e))
        }
    }

    /**
     * Add a callback {@link AvSessionCallback} to observe the play action like play next and play previous.
     * @param callback The callback to observe the play action.
     */
    addAvSessionCallback(callback: AvSessionCallback) {
        this.avSessionManager!.addAvSessionCallback(callback)
    }

    /**
     * Remove a callback {@link AvSessionCallback} to observe the play action like play next and play previous.
     * @param callback The callback to observe the play action.
     */
    removeAvSessionCallback(callback: AvSessionCallback) {
        this.avSessionManager!.removeAvSessionCallback(callback)
    }

    /**
     * Set background play or not.
     * @param enable True to start background play, false to stop background play.
     */
    setBackgroundPlayEnable(enable: boolean) {
        if (!this.context) {
            MediaLogger.w(TAG, "The context is null.")
            return
        }
        if (!this.agentInfo) {
            MediaLogger.w(TAG, "The agent is null, you should call {@Link bindAvSession} first.")
            return
        }
        if (this.isBackgroundPlay == enable) {
            return
        }
        if (enable) {
            MediaLogger.d(TAG, "start background play")
            BackgroundPlayManager.startBackground(this.context, this.agentInfo)
        } else {
            MediaLogger.d(TAG, "stop background play")
            BackgroundPlayManager.stopBackground(this.context)
        }
        this.isBackgroundPlay = enable
    }

    /**
     * Add a listener to observe the media source changed.
     * @param listener The listener to observe the media source changed.
     */
    addOnMediaChangedListener(listener: (source: MediaSource) => void) {
        this.onMediaChangedListeners.push(listener)
    }

    /**
     * Remove a listener to observe the media source changed.
     * @param listener The listener to observe the media source changed.
     */
    removeOnMediaChangedListener(listener: (source: MediaSource) => void) {
        let index = this.onMediaChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.onMediaChangedListeners.splice(index, 1)
        }
    }

    /**
     * Set the controller of XComponent to play video.
     * @param controller The controller{@link XComponentController} of XComponent to play video.
     */
    setXComponentController(controller: XComponentController) {
        if (this.xComponentController != controller) {
            MediaLogger.d(TAG, "set xComponent controller= " + controller)
            this.xComponentController = controller
            this.isControllerChanged = true
        }
    }

    /**
     * Return the controller of XComponent.
     * @returns The controller of XComponent, return undefined if not set.
     */
    getXComponentController(): XComponentController | undefined {
        return this.xComponentController
    }

    /**
     * Set the pip enable, must call #setXComponentController first.
     * @param pipType The type{@link PiPWindow.PiPTemplateType} of pip window, default is VIDEO_PLAY.
     * @returns The pipController {@link PiPWindow.PiPController} if enable success, return undefined if enable failed or not support pip.
     */
    async enablePip(pipType: PiPWindow.PiPTemplateType = PiPWindow.PiPTemplateType.VIDEO_PLAY): Promise<PiPWindow.PiPController | undefined> {
        if (!PiPWindow.isPiPEnabled()) {
            MediaLogger.w(TAG, "The platform is not support pip mode.")
            return undefined
        }
        if (!this.xComponentController) {
            MediaLogger.e(TAG, "The xComponentController is null, must call #setXComponentController first.")
            return undefined
        }
        if (this.pipController) {
            MediaLogger.w(TAG, "The pip is enabled, can not enable again!")
            return this.pipController
        }
        this.pipType = pipType
        this.pipController = await this.createPipController()
        MediaLogger.d(TAG, "enable pip")
        return this.pipController
    }

    /**
     * Set the pip disable.
     */
    async disablePip() {
        if (this.pipController) {
            MediaLogger.d(TAG, "disable pip")
            await this.stopPip()
            this.pipController.off("controlPanelActionEvent")
        }
    }

    /**
     * Start the pip.
     */
    async startPip() {
        if (!this.pipController) {
            return
        }
        if (this.isControllerChanged) {
            this.pipController = await this.createPipController();
        }
        MediaLogger.d(TAG, "start pip")
        await this.pipController.startPiP()
    }

    private readonly pipActionEventListener = (event: PiPWindow.PiPActionEventType, status?: number) => {
        switch (event) {
            case "playbackStateChanged":
                if (status == 0) {
                    this.player.pause();
                } else {
                    this.player.start();
                }
                break;
        }
    }

    private async createPipController(): Promise<PiPWindow.PiPController> {
        const pipController = await PiPWindow.create({
            context: this.context,
            componentController: this.xComponentController,
            templateType: this.pipType
        });
        this.isControllerChanged = false;
        pipController.on("controlPanelActionEvent", this.pipActionEventListener)
        MediaLogger.d(TAG, "create pip controller success")
        return pipController
    }

    /**
     * Stop the pip.
     */
    async stopPip() {
        if (!PiPWindow.isPiPEnabled()) {
            MediaLogger.w(TAG, "The platform is not support pip mode.")
            return
        }
        if (!this.xComponentController) {
            MediaLogger.e(TAG, "The xComponentController is null, must call #setXComponentController first.")
            return
        }
        if (this.pipController) {
            MediaLogger.d(TAG, "stop pip")
            await this.pipController.stopPiP()
        }
    }
}