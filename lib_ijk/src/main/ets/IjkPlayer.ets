import { AudioFocusEvent, IPlayer, MediaSource, PlayerState, IJK } from '@seagazer/ccplayer-base';
import media from '@ohos.multimedia.media';
import { IjkPlayerImpl } from './impl/IjkPlayerImpl';

/**
 * The ijkPlayer extensions of CcPlayer.
 *
 * Author: Seagazer
 * Date: 2025/8/2
 */
export class IjkPlayer implements IPlayer {
    private player: IjkPlayerImpl

    constructor() {
        this.player = new IjkPlayerImpl()
    }

    static getLibrary(): string {
        return IJK.NAPI
    }

    static getXComponentId(): string {
        return IJK.ID
    }

    start(): void {
        this.player.start()
    }

    startTo(position: number): void {
        this.player.startTo(position)
    }

    pause(): void {
        this.player.pause()
    }

    stop(): void {
        this.player.stop()
    }

    reset(): void {
        this.player.reset()
    }

    release(): void {
        this.player.release()
    }

    seekTo(position: number): void {
        this.player.seekTo(position)
    }

    setSeekMode(mode: media.SeekMode): void {
        this.player.setSeekMode(mode)
    }

    setMediaSource(mediaSource: MediaSource, onReady?: (() => void) | undefined): void {
        this.player.setMediaSource(mediaSource, onReady)
    }

    getMediaSource(): MediaSource | undefined {
        return this.player.getMediaSource()
    }

    setLooper(isLoop: boolean): void {
        this.player.setLooper(isLoop)
    }

    setVolume(vol: number): void {
        this.player.setVolume(vol)
    }

    setPlaySpeed(speed: number): void {
        this.player.setPlaySpeed(speed)
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

    addOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnBufferProgressChangedListener(listener)
        return this
    }

    removeOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.removeOnBufferProgressChangedListener(listener)
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

    addOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.player.addOnAudioFocusChangedListener(listener)
        return this
    }

    removeOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.player.removeOnAudioFocusChangedListener(listener)
        return this
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

    getBufferPosition(): number {
        return this.player.getBufferPosition()
    }

    getPlayerState(): PlayerState {
        return this.player.getPlayerState()
    }

    getSystemPlayer(): IPlayer | media.AVPlayer {
        return this
    }

    getTag(): string {
        return this.player.getTag()
    }

    setSurface(surfaceId: string): void {
        this.player.setSurface(surfaceId)
    }

    bindXComponent(controller: XComponentController, loadContext: object): void {
        this.player.bindXComponent(controller, loadContext)
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
}