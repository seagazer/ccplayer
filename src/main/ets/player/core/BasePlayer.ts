import { Logger } from '../helper/Logger'
import { IPlayer } from './Iplayer'
import { PlayerState } from './PlayerState'

const TAG = "BasePlayer"

/**
 * Base player
 */
export class BasePlayer implements IPlayer {
    protected currentState = PlayerState.STATE_IDLE
    protected preparedListeners: Array<any> = []
    protected completedListeners: Array<any> = []
    protected progressChangedListeners: Array<any> = []
    protected errorListeners: Array<any> = []
    protected seekChangedListeners: Array<any> = []
    protected volumeChangedListeners: Array<any> = []
    protected stateChangedListeners: Array<any> = []
    protected isPrepared = false
    protected progressTimer = null
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

    addOnCompletionListener(listener: () => void): IPlayer{
        this.completedListeners.push(listener)
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.errorListeners.push(listener)
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.progressChangedListeners.push(listener)
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer{
        this.seekChangedListeners.push(listener)
        return this
    }

    addOnVolumeChangedListener(listener: () => void): IPlayer {
        this.volumeChangedListeners.push(listener)
        return this
    }

    addOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer{
        this.stateChangedListeners.push(listener)
        return this
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
        Logger.d(TAG, ">> currentState: " + this.currentState)
        return this.currentState
    }

    setDataSourceUrl(url: string) {
        Logger.d(TAG, ">> setDataSourceUrl: " + url)
    }

    setDataSourceFile(sourcePath: string) {
        Logger.d(TAG, ">> setDataSourceUrl: " + sourcePath)
    }

    start() {
    }

    startTo(position: number) {
        Logger.d(TAG, ">> start to: " + position)
        this.startPosition = position
        this.start()
    }

    pause() {
    }

    stop() {
    }

    reset() {
    }

    seekTo(position: number) {
    }

    setVolume(vol: number) {
    }

    setLooper(isLoop: boolean) {
    }

    setSurface(surfaceId: string) {
    }

    protected startProgressTimer() {
        if (this.progressChangedListeners.length > 0) {
            this.stopProgressTimer()
            // refresh duration right now
            this.progressChangedListeners.forEach((callback) => {
                callback(this.getCurrentPosition())
            })
            this.progressTimer = setInterval(() => {
                this.progressChangedListeners.forEach((callback) => {
                    callback(this.getCurrentPosition())
                })
            }, 1000)
        }
    }

    protected stopProgressTimer() {
        if (this.progressTimer != null) {
            clearInterval(this.progressTimer)
        }
    }

    release() {
        this.stopProgressTimer()
        this.preparedListeners = []
        this.completedListeners = []
        this.progressChangedListeners = []
        this.errorListeners = []
        this.seekChangedListeners = []
        this.volumeChangedListeners = []
        this.stateChangedListeners = []
    }
}

