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

const TAG = '[CcPlayer]'

/**
 * The player for audio or video.
 */
export class CcPlayer implements IPlayer {
    private player: IPlayer
    private avSessionManager?: AvSessionManager = undefined

    constructor(context: common.Context) {
        this.player = AvPlayerImpl.create(context)
    }

    /**
     * Set the player instance implements the {@link IPlayer}.
     * @param player
     */
    public setPlayer(player: IPlayer) {
        this.player = player
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
        this.avSessionManager?.release()
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
        this.player.setMediaSource(mediaSource, onReady)
        this.avSessionManager?.setMediaSource(mediaSource)
    }

    setLooper(isLoop: boolean) {
        this.player.setLooper(isLoop)
    }

    setVolume(vol: number) {
        this.player.setVolume(vol)
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

    addOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer {
        this.player.addOnStateChangedListener(listener)
        return this
    }

    removeOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer {
        this.player.removeOnStateChangedListener(listener)
        return this
    }

    addOnVideoSizeChangedListener(listener: (newWidth: number, newHeight: number) => void): IPlayer {
        this.player.addOnVideoSizeChangedListener(listener)
        return this
    }

    removeOnVideoSizeChangedListener(listener: (newWidth: number, newHeight: number) => void): IPlayer {
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

    async bindAvSession(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType,
        agentInfo: wantAgent.WantAgentInfo) {
        this.avSessionManager = new AvSessionManager(this.player)
        await this.avSessionManager.create(context, sessionName, type)
        await this.avSessionManager.setLaunchInfo(agentInfo)
        this.avSessionManager.bind()
    }
}