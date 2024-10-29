import media from '@ohos.multimedia.media';
import { MediaSource } from '../data/MediaSource';
import { PlayerState } from '../config/PlayerState';


/**
 * Define the action of media player.
 *
 * Author: Seagazer
 * Date: 2022/8/17
 */
export interface IPlayer {
    /**
     * Start play or resume play.
     */
    start(): void

    /**
     * Start to play with the begin position.
     * @param position The begin position.
     */
    startTo(position: number): void

    /**
     * Pause play.
     */
    pause(): void

    /**
     * Stop play.
     */
    stop(): void

    /**
     * Reset the player, the state reset to IDLE.
     */
    reset(): void

    /**
     * Destroy the player and release the resource.
     */
    release(): void

    /**
     * Seek to the position.
     * @param position Duration to be seek.
     */
    seekTo(position: number): void

    /**
     * Set the mediaSource.
     * @param mediaSource The mediaSource {@link MediaSource}, use MediaSourceFactory to create a mediaSource.
     * @param onReady The callback when video is bind surface and set src success, undefined for audio player.
     */
    setMediaSource(mediaSource: MediaSource, onReady?: () => void): void

    /**
     * Get current mediaSource.
     * @returns The mediaSource of current playing, undefined if not play.{@link MediaSource}
     */
    getMediaSource(): MediaSource | undefined

    /**
     * Set loop mode.
     * @param isLoop Loop or not.
     */
    setLooper(isLoop: boolean): void

    /**
     * Set the volume.
     * @param vol The volume of media player.
     */
    setVolume(vol: number): void

    /**
     * Add a listener to observe the prepared state.
     * @param listener The listener to observe the prepared state.
     * @return The player instance.
     */
    addOnPreparedListener(listener: () => void): IPlayer

    /**
     * Remove a listener to observe the prepared state.
     * @param listener The listener to observe the prepared state.
     * @return The player instance.
     */
    removeOnPreparedListener(listener: () => void): IPlayer

    /**
     * Add a listener to observe the completed state.
     * @param listener The listener to observe the completed state.
     * @return The player instance.
     */
    addOnCompletionListener(listener: () => void): IPlayer

    /**
     * Remove a listener to observe the completed state.
     * @param listener The listener to observe the completed state.
     * @return The player instance.
     */
    removeOnCompletionListener(listener: () => void): IPlayer

    /**
     * Add a listener to observe the error state.
     * @param listener The listener to observe the error state.
     * @return The player instance.
     */
    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer

    /**
     * Remove a listener to observe the error state.
     * @param listener The listener to observe the error state.
     * @return The player instance.
     */
    removeOnErrorListener(listener: (code: number, message: string) => void): IPlayer

    /**
     * Add a listener to observe the player progress.
     * @param listener The listener to observe the player progress.
     * @return The player instance.
     */
    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer

    /**
     * Remove a listener to observe the player progress.
     * @param listener The listener to observe the player progress.
     * @return The player instance.
     */
    removeOnProgressChangedListener(listener: (duration: number) => void): IPlayer

    /**
     * Add a listener to observe the seeking state.
     * @param listener The listener to observe the seeking state.
     * @return The player instance.
     */
    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer

    /**
     * Remove a listener to observe the seeking state.
     * @param listener The listener to observe the seeking state.
     * @return The player instance.
     */
    removeOnSeekChangedListener(listener: (duration: number) => void): IPlayer

    /**
     * Add a listener to observe the volume changed.
     * @param listener The listener to observe the volume changed.
     * @return The player instance.
     */
    addOnVolumeChangedListener(listener: () => void): IPlayer

    /**
     * Remove a listener to observe the volume changed.
     * @param listener The listener to observe the volume changed.
     * @return The player instance.
     */
    removeOnVolumeChangedListener(listener: () => void): IPlayer

    /**
     * Add a listener to observe the state changed of player.
     * @param listener The listener to observe the state changed of player.
     * @return The player instance.
     */
    addOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer

    /**
     * Remove a listener to observe the state changed of player.
     * @param listener The listener to observe the state changed of player.
     * @return The player instance.
     */
    removeOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer

    /**
     * Check the player is playing.
     * @return The player is playing or not.
     */
    isPlaying(): boolean

    /**
     * Get the total duration of the media source.
     * @return The total duration of the media source.
     */
    getDuration(): number

    /**
     * Get current duration of the playing media source.
     * @return The current duration of the media source.
     */
    getCurrentPosition(): number

    /**
     * Get the state of player.
     * @return The current state of player.
     */
    getPlayerState(): PlayerState

    /**
     * Get the instance of system player.
     * @return The instance of system player.
     */
    getSystemPlayer(): media.AVPlayer

    /**
     * Set a surface to render picture for video player.
     * @param surfaceId The surface of XComponent to be bind the media player.
     */
    setSurface(surfaceId: string): void

    /**
     * Add a listener to observe the video size changed of player.
     * @param listener The listener to observe the video size changed of player.
     */
    addOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer

    /**
     * Remove a listener to observe the video size changed of player.
     * @param listener The listener to observe the video size changed of player.
     */
    removeOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer

    /**
     * Add a listener to observe the timer for first frame of video.
     * @param listener The listener to observe the timer for first frame of video.
     */
    addOnRenderFirstFrameListener(listener: () => void): IPlayer

    /**
     * Remove a listener to observe the timer for first frame of video.
     * @param listener The listener to observe the timer for first frame of video.
     */
    removeOnRenderFirstFrameListener(listener: () => void): IPlayer
}
