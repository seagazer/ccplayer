import { OhosVideoPlayer } from './core/OhosVideoPlayer';
import { OhosAudioPlayer } from './core/OhosAudioPlayer';
import { PlayerState } from './core/PlayerState';
import { IPlayer } from './core/IPlayer'
import { PlayerType } from './core/PlayerType'

/**
 * The player for audio or video.
 */
export class MediaPlayer implements IPlayer {
    private player: IPlayer

    private constructor(type: PlayerType) {
        if (type == PlayerType.AUDIO) {
            this.player = OhosAudioPlayer.create()
        } else {
            this.player = OhosVideoPlayer.create()
        }
    }

    /**
     * Create a instance of MediaPlayer.
     * @param type PlayerType.[AUDIO, VIDEO]
     */
    public static create(type: PlayerType) {
        return new MediaPlayer(type)
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

    setDataSourceUrl(url: string) {
        this.player.setDataSourceUrl(url)
    }

    setDataSourceFile(sourcePath: string) {
        this.player.setDataSourceFile(sourcePath)
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

    addOnCompletionListener(listener: () => void): IPlayer {
        this.player.addOnCompletionListener(listener)
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer{
        this.player.addOnErrorListener(listener)
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnProgressChangedListener(listener)
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.player.addOnSeekChangedListener(listener)
        return this
    }

    addOnVolumeChangedListener(listener: () => void): IPlayer{
        this.player.addOnVolumeChangedListener(listener)
        return this
    }

    addOnStateChangedListener(listener: (newState: PlayerState) => void): IPlayer{
        this.player.addOnStateChangedListener(listener)
        return this
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
}