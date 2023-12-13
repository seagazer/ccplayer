import media from '@ohos.multimedia.media';
import { MediaSource } from '../data/MediaSource';
import { Logger } from '../common/Logger'
import { IPlayer } from '../interface/Iplayer'
import { IRender } from '../interface/IRender'
import { PlayerState } from '../config/Playerstate'

const TAG = "BasePlayer"

/**
 * Base player
 */
export class BasePlayer implements IPlayer, IRender {
    protected currentState = PlayerState.STATE_NOT_INIT
    protected preparedListeners: Array<() => void> = []
    protected completedListeners: Array<() => void> = []
    protected progressChangedListeners: Array<(position: number) => void> = []
    protected errorListeners: Array<(code: number, message: string) => void> = []
    protected seekChangedListeners: Array<(position: number) => void> = []
    protected volumeChangedListeners: Array<() => void> = []
    protected stateChangedListeners: Array<(newState: PlayerState) => void> = []
    protected videoSizeChangedListeners: Array<(width: number, height: number) => void> = []
    protected renderFirstFrameListeners: Array<() => void> = []
    protected isPrepared = false
    protected progressTimer = -1
    protected startPosition = -1

    protected changePlayerState(state: PlayerState) {
        this.currentState = state
        this.stateChangedListeners.forEach((callback) => {
            callback(state)
        })
    }

    addOnPreparedListener(listener: () => void): IPlayer {
        this.preparedListeners.push(listener)
        return this
    }

    removeOnPreparedListener(listener: () => void): IPlayer {
        this.preparedListeners.splice(this.preparedListeners.indexOf(listener), 1)
        return this
    }

    addOnCompletionListener(listener: () => void): IPlayer {
        this.completedListeners.push(listener)
        return this
    }

    removeOnCompletionListener(listener: () => void): IPlayer {
        this.completedListeners.splice(this.completedListeners.indexOf(listener), 1)
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.errorListeners.push(listener)
        return this
    }

    removeOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.errorListeners.splice(this.errorListeners.indexOf(listener), 1)
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.progressChangedListeners.push(listener)
        return this
    }

    removeOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.progressChangedListeners.splice(this.progressChangedListeners.indexOf(listener), 1)
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.seekChangedListeners.push(listener)
        return this
    }

    removeOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.seekChangedListeners.splice(this.seekChangedListeners.indexOf(listener), 1)
        return this
    }

    addOnVolumeChangedListener(listener: () => void): IPlayer {
        this.volumeChangedListeners.push(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: () => void): IPlayer {
        this.volumeChangedListeners.splice(this.volumeChangedListeners.indexOf(listener), 1)
        return this
    }

    addOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer {
        this.stateChangedListeners.push(listener)
        return this
    }

    removeOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer {
        this.stateChangedListeners.splice(this.stateChangedListeners.indexOf(listener), 1)
        return this
    }

    addOnVideoSizeChangedListener(listener: (newWidth, newHeight) => void) {
        this.videoSizeChangedListeners.push(listener)
    }

    removeOnVideoSizeChangedListener(listener: (newWidth, newHeight) => void) {
        this.videoSizeChangedListeners.splice(this.videoSizeChangedListeners.indexOf(listener), 1)
    }

    addOnRenderFirstFrameListener(listener: () => void) {
        this.renderFirstFrameListeners.push(listener)
    }

    removeOnRenderFirstFrameListener(listener: () => void) {
        this.renderFirstFrameListeners.splice(this.renderFirstFrameListeners.indexOf(listener), 1)
    }

    getDuration(): number {
        return -1
    }

    getCurrentPosition(): number {
        return -1
    }

    isPlaying(): boolean {
        return this.currentState == PlayerState.STATE_STARTED
    }

    getPlayerState(): PlayerState {
        Logger.i(TAG, ">> currentState: " + this.currentState)
        return this.currentState
    }

    setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        Logger.i(TAG, ">> setMediaSource: " + JSON.stringify(mediaSource))
    }

    startTo(position: number) {
        Logger.d(TAG, ">> start to: " + position)
        this.startPosition = position
        this.start()
    }

    start() {
        // do action in sub class
    }

    pause() {
        // do action in sub class
        this.stopProgressTimer()
    }

    stop() {
        // do action in sub class
        this.stopProgressTimer()
    }

    reset() {
        // do action in sub class
        this.stopProgressTimer()
    }

    seekTo(position: number) {
        // do action in sub class
    }

    setVolume(vol: number) {
        // do action in sub class
    }

    setLooper(isLoop: boolean) {
        // do action in sub class
    }

    setSurface(surfaceId: string) {
        // do action in sub class
    }

    protected startProgressTimer() {
        if (this.progressChangedListeners.length > 0) {
            this.stopProgressTimer()
            // refresh duration right now
            this.progressChangedListeners.forEach((callback) => {
                callback(this.getCurrentPosition())
            })
            Logger.i(TAG, ">> start progress timer")
            this.progressTimer = setInterval(() => {
                this.progressChangedListeners.forEach((callback) => {
                    callback(this.getCurrentPosition())
                })
            }, 1000)
        }
    }

    protected stopProgressTimer() {
        if (this.progressTimer != -1) {
            Logger.i(TAG, ">> stop progress timer")
            clearInterval(this.progressTimer)
            this.progressTimer = -1
        }
    }

    release() {
        Logger.d(TAG, "release")
        this.stopProgressTimer()
        this.preparedListeners = []
        this.completedListeners = []
        this.progressChangedListeners = []
        this.errorListeners = []
        this.seekChangedListeners = []
        this.volumeChangedListeners = []
        this.stateChangedListeners = []
    }

    getSystemPlayer(): media.AVPlayer | media.VideoPlayer | media.AudioPlayer {
        return null
    }
}

