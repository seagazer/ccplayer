import { MediaSource } from './data/MediaSource';
import { OhosVideoPlayer } from './core/OhosVideoPlayer';
import { OhosAudioPlayer } from './core/OhosAudioPlayer';
import { PlayerState } from './config/PlayerState';
import { IPlayer } from './interface/IPlayer'
import { IRender } from './interface/IRender'
import { PlayerType } from './config/Playertype'
import { BasePlayer } from './core/BasePlayer'

/**
 * The player for audio or video.
 */
export class CcPlayer implements IPlayer, IRender {
    private mediaSource: MediaSource = null
    private player

    private constructor(type: PlayerType) {
        if (type == PlayerType.AUDIO) {
            this.player = OhosAudioPlayer.create()
        } else {
            this.player = OhosVideoPlayer.create()
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
        this.player.start()
    }

    startTo(position: number) {
        this.player.startTo(position)
    }

    pause() {
        this.player.pause()
    }

    stop() {
        this.player.stop()
    }

    reset() {
        this.player.reset()
    }

    release() {
        this.player.release()
    }

    seekTo(position: number) {
        this.player.seekTo(position)
    }

    setMediaSource(mediaSource: MediaSource) {
        this.mediaSource = mediaSource
        this.player.setMediaSource(mediaSource)
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

    removeOnPreparedListener(listener: () => void): IPlayer{
        this.player.removeOnPreparedListener(listener)
        return this
    }

    addOnCompletionListener(listener: () => void): IPlayer {
        this.player.addOnCompletionListener(listener)
        return this
    }

    removeOnCompletionListener(listener: () => void): IPlayer{
        this.player.removeOnCompletionListener(listener)
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer{
        this.player.addOnErrorListener(listener)
        return this
    }

    removeOnErrorListener(listener: (code: number, message: string) => void): IPlayer{
        this.player.removeOnErrorListener(listener)
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnProgressChangedListener(listener)
        return this
    }

    removeOnProgressChangedListener(listener: (duration: number) => void): IPlayer{
        this.player.removeOnProgressChangedListener(listener)
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnSeekChangedListener(listener)
        return this
    }

    removeOnSeekChangedListener(listener: (duration: number) => void): IPlayer{
        this.player.removeOnSeekChangedListener(listener)
        return this
    }

    addOnVolumeChangedListener(listener: () => void): IPlayer{
        this.player.addOnVolumeChangedListener(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: () => void): IPlayer{
        this.player.removeOnVolumeChangedListener(listener)
        return this
    }

    addOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer{
        this.player.addOnStateChangedListener(listener)
        return this
    }

    removeOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer{
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

    isPlaying(): boolean{
        return this.player.isPlaying()
    }

    getDuration(): number{
        return this.player.getDuration()
    }

    getCurrentPosition(): number{
        return this.player.getCurrentPosition()
    }

    getPlayerState(): PlayerState{
        return this.player.getPlayerState()
    }

    setSurface(surfaceId: string) {
        this.player.setSurface(surfaceId)
    }

    /**
     * Get the playing media source.
     * @return MediaSource The media source which is playing.
     */
    public getMediaSource(): MediaSource{
        return this.mediaSource
    }
}