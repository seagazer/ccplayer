import { AudioFocusEvent, IPlayer, MediaSource, PlayerState } from '@seagazer/ccplayer-base';
import media from '@ohos.multimedia.media';
import { IjkPlayerImpl } from './IjkPlayerImpl';

/**
 * The ijkPlayer plugin of CcPlayer.
 *
 * Author: Seagazer
 * Date: 2025/8/2
 */
export class IjkPlugin implements IPlayer {
    private static readonly NAPI = "ijkplayer_napi"
    private static readonly ID = "IjkPlayerImpl"
    private ijkPlayer: IjkPlayerImpl

    constructor() {
        this.ijkPlayer = new IjkPlayerImpl()
    }

    static getLibrary(): string {
        return IjkPlugin.NAPI
    }

    static getXComponentId(): string {
        return IjkPlugin.ID
    }

    start(): void {
        this.ijkPlayer.start()
    }

    startTo(position: number): void {
        this.ijkPlayer.startTo(position)
    }

    pause(): void {
        this.ijkPlayer.pause()
    }

    stop(): void {
        this.ijkPlayer.stop()
    }

    reset(): void {
        this.ijkPlayer.reset()
    }

    release(): void {
        this.ijkPlayer.release()
    }

    seekTo(position: number): void {
        this.ijkPlayer.seekTo(position)
    }

    setSeekMode(mode: media.SeekMode): void {
        this.ijkPlayer.setSeekMode(mode)
    }

    setMediaSource(mediaSource: MediaSource, onReady?: (() => void) | undefined): void {
        this.ijkPlayer.setMediaSource(mediaSource, onReady)
    }

    getMediaSource(): MediaSource | undefined {
        return this.ijkPlayer.getMediaSource()
    }

    setLooper(isLoop: boolean): void {
        this.ijkPlayer.setLooper(isLoop)
    }

    setVolume(vol: number): void {
        this.ijkPlayer.setVolume(vol)
    }

    setPlaySpeed(speed: number): void {
        this.ijkPlayer.setPlaySpeed(speed)
    }

    addOnPreparedListener(listener: () => void): IPlayer {
        this.ijkPlayer.addOnPreparedListener(listener)
        return this
    }

    removeOnPreparedListener(listener: () => void): IPlayer {
        this.ijkPlayer.removeOnPreparedListener(listener)
        return this
    }

    addOnCompletionListener(listener: () => void): IPlayer {
        this.ijkPlayer.addOnCompletionListener(listener)
        return this
    }

    removeOnCompletionListener(listener: () => void): IPlayer {
        this.ijkPlayer.removeOnCompletionListener(listener)
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.ijkPlayer.addOnErrorListener(listener)
        return this
    }

    removeOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.ijkPlayer.removeOnErrorListener(listener)
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.ijkPlayer.addOnProgressChangedListener(listener)
        return this
    }

    removeOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.ijkPlayer.removeOnProgressChangedListener(listener)
        return this
    }

    addOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.ijkPlayer.addOnBufferProgressChangedListener(listener)
        return this
    }

    removeOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.ijkPlayer.removeOnBufferProgressChangedListener(listener)
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.ijkPlayer.addOnSeekChangedListener(listener)
        return this
    }

    removeOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.ijkPlayer.removeOnSeekChangedListener(listener)
        return this
    }

    addOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        this.ijkPlayer.addOnVolumeChangedListener(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        this.ijkPlayer.removeOnVolumeChangedListener(listener)
        return this
    }

    addOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer {
        this.ijkPlayer.addOnStateChangedListener(listener)
        return this
    }

    removeOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer {
        this.ijkPlayer.removeOnStateChangedListener(listener)
        return this
    }

    addOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.ijkPlayer.addOnAudioFocusChangedListener(listener)
        return this
    }

    removeOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.ijkPlayer.removeOnAudioFocusChangedListener(listener)
        return this
    }

    isPlaying(): boolean {
        return this.ijkPlayer.isPlaying()
    }

    getDuration(): number {
        return this.ijkPlayer.getDuration()
    }

    getCurrentPosition(): number {
        return this.ijkPlayer.getCurrentPosition()
    }

    getBufferPosition(): number {
        return this.ijkPlayer.getBufferPosition()
    }

    getPlayerState(): PlayerState {
        return this.ijkPlayer.getPlayerState()
    }

    getSystemPlayer(): IPlayer | media.AVPlayer {
        return this
    }

    setSurface(surfaceId: string): void {
        this.ijkPlayer.setSurface(surfaceId)
    }

    bindXComponent(controller: XComponentController, loadContext: object): void {
        this.ijkPlayer.bindXComponent(controller, loadContext)
    }

    addOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer {
        this.ijkPlayer.addOnVideoSizeChangedListener(listener)
        return this
    }

    removeOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer {
        this.ijkPlayer.removeOnVideoSizeChangedListener(listener)
        return this
    }

    addOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.ijkPlayer.addOnRenderFirstFrameListener(listener)
        return this
    }

    removeOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.ijkPlayer.removeOnRenderFirstFrameListener(listener)
        return this
    }
}