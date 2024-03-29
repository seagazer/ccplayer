import { BasePlayer } from './core/BasePlayer';
import media from '@ohos.multimedia.media';
import { Logger } from './common/Logger';
import { IPlayer } from './interface/IPlayer'
import { IRender } from './interface/IRender'
import { OhosAvPlayer } from './core/OhosAvPlayer';
import { OhosVideoPlayer } from './core/OhosVideoPlayer';
import { OhosAudioPlayer } from './core/OhosAudioPlayer';
import { getOSVersion } from './common/Extentions';
import { MediaSource } from './data/MediaSource';
import { PlayerState } from './config/PlayerState';
import { PlayerType } from './config/Playertype'

const TAG = "CcPlayer"

/**
 * The player for audio or video.
 */
export class CcPlayer implements IPlayer, IRender {
    private mediaSource: MediaSource = null
    private player: BasePlayer

    private constructor(type: PlayerType) {
        let osVersion = getOSVersion()
        if (osVersion >= 3.2) {
            this.player = OhosAvPlayer.create(type)
            Logger.i(TAG, "Os version is 3.2+, create AvPlayer")
        } else if (osVersion >= 3.0) {
            if (type == PlayerType.AUDIO) {
                Logger.i(TAG, "Os version is 3.1, create AudioPlayer")
                this.player = OhosAudioPlayer.create()
            } else {
                Logger.i(TAG, "Os version is 3.1, create VideoPlayer")
                this.player = OhosVideoPlayer.create()
            }
        } else {
            Logger.e(TAG, "Os version is 2.x, not support!")
            throw new Error("This library only support for OpenHarmony 3.1+")
        }
    }

    /**
     * Create a instance of CcPlayer.
     * @param type The type of player. [PlayerType.AUDIO, PlayerType.VIDEO]
     */
    public static create(type: PlayerType) {
        return new CcPlayer(type)
    }

    start() {
        let state = this.getPlayerState()
        if (state == PlayerState.STATE_STARTED) {
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
        this.mediaSource = mediaSource
        this.player.setMediaSource(mediaSource, onReady)
    }

    setLooper(isLoop: boolean) {
        this.player.setLooper(isLoop)
    }

    setVolume(vol: number) {
        this.player.setVolume(vol)
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

    addOnVideoSizeChangedListener(listener: (newWidth, newHeight) => void) {
        this.player.addOnVideoSizeChangedListener(listener)
    }

    removeOnVideoSizeChangedListener(listener: (newWidth, newHeight) => void) {
        this.player.removeOnVideoSizeChangedListener(listener)
    }

    addOnRenderFirstFrameListener(listener: () => void) {
        this.player.addOnRenderFirstFrameListener(listener)
    }

    removeOnRenderFirstFrameListener(listener: () => void) {
        this.player.removeOnRenderFirstFrameListener(listener)
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

    /**
     * Get the playing media source.
     * @return MediaSource The media source which is playing.
     */
    public getMediaSource(): MediaSource {
        return this.mediaSource
    }

    getSystemPlayer(): media.AVPlayer | media.AudioPlayer | media.VideoPlayer {
        return this.player.getSystemPlayer()
    }
}