/**
 * The event for audio focus changed.
 *
 * Author: Seagazer
 * Date: 2024/12/9
 */
export enum AudioFocusEvent {
    /**
     * The event for lose audio focus, always the player will pause.
     */
    AUDIO_FOCUS_LOST,
    /**
     * The event for gain audio focus, always the player will resume play.
     */
    AUDIO_FOCUS_GAIN
}