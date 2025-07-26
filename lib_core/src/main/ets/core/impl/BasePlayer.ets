import media from '@ohos.multimedia.media';
import { AudioFocusEvent, IPlayer, MediaLogger, MediaSource, PlayerState } from '@seagazer/ccplayer_base';

const TAG = "[BasePlayer]"

/**
 * Base player
 *
 * Author: Seagazer
 * Date: 2022/3/17
 *
 * @deprecated since v1.0.4
 */
export abstract class BasePlayer implements IPlayer {
    protected currentState = PlayerState.STATE_NOT_INIT
    protected preparedListeners: Array<() => void> = []
    protected completedListeners: Array<() => void> = []
    protected progressChangedListeners: Array<(position: number) => void> = []
    protected bufferProgressChangedListeners: Array<(position: number) => void> = []
    protected errorListeners: Array<(code: number, message: string) => void> = []
    protected seekChangedListeners: Array<(position: number) => void> = []
    protected volumeChangedListeners: Array<(volume: number) => void> = []
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

    setPlaySpeed(speed: number): void {
        throw new Error('Method not implemented.');
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

    addOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.bufferProgressChangedListeners.push(listener)
        return this
    }

    removeOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.bufferProgressChangedListeners.splice(this.bufferProgressChangedListeners.indexOf(listener), 1)
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

    addOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        this.volumeChangedListeners.push(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
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

    addOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        return this
    }

    removeOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        return this
    }

    isPlaying(): boolean {
        return this.currentState == PlayerState.STATE_STARTED
    }

    getDuration(): number {
        return 0
    }

    getCurrentPosition(): number {
        return 0
    }

    getBufferPosition(): number {
        return 0
    }

    getSystemPlayer(): IPlayer | media.AVPlayer {
        return this
    }

    addOnVideoSizeChangedListener(listener: (newWidth: number, newHeight: number) => void): IPlayer {
        this.videoSizeChangedListeners.push(listener)
        return this
    }

    removeOnVideoSizeChangedListener(listener: (newWidth: number, newHeight: number) => void): IPlayer {
        this.videoSizeChangedListeners.splice(this.videoSizeChangedListeners.indexOf(listener), 1)
        return this
    }

    addOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.renderFirstFrameListeners.push(listener)
        return this
    }

    removeOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.renderFirstFrameListeners.splice(this.renderFirstFrameListeners.indexOf(listener), 1)
        return this
    }

    getPlayerState(): PlayerState {
        MediaLogger.i(TAG, ">> currentState: " + this.currentState)
        return this.currentState
    }

    setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        MediaLogger.i(TAG, ">> setMediaSource: " + JSON.stringify(mediaSource))
    }

    getMediaSource(): MediaSource | undefined {
        return undefined
    }

    async start() {
        // do action in sub class
    }

    async startTo(position: number) {
        MediaLogger.d(TAG, ">> start to: " + position)
        this.startPosition = position
        await this.start()
    }

    async pause() {
        // do action in sub class
        //this.stopProgressTimer()
    }

    async stop() {
        // do action in sub class
        //this.stopProgressTimer()
    }

    async reset() {
        // do action in sub class
        //this.stopProgressTimer()
    }

    seekTo(position: number) {
        // do action in sub class
    }

    setSeekMode(mode: media.SeekMode) {
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

    /**
     * @deprecated since v1.0.4
     */
    protected startProgressTimer() {
        if (this.progressChangedListeners.length > 0) {
            this.stopProgressTimer()
            // refresh duration right now
            this.progressChangedListeners.forEach((callback) => {
                callback(this.getCurrentPosition())
            })
            MediaLogger.i(TAG, ">> start progress timer")
            this.progressTimer = setInterval(() => {
                this.progressChangedListeners.forEach((callback) => {
                    callback(this.getCurrentPosition())
                })
            }, 1000)
        }
    }

    /**
     * @deprecated since v1.0.4
     */
    protected stopProgressTimer() {
        if (this.progressTimer != -1) {
            MediaLogger.i(TAG, ">> stop progress timer")
            clearInterval(this.progressTimer)
            this.progressTimer = -1
        }
    }

    release() {
        MediaLogger.d(TAG, "release")
        //this.stopProgressTimer()
        this.preparedListeners = []
        this.completedListeners = []
        this.progressChangedListeners = []
        this.errorListeners = []
        this.seekChangedListeners = []
        this.volumeChangedListeners = []
        this.stateChangedListeners = []
    }
}

