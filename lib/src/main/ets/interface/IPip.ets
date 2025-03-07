import { PiPWindow } from '@kit.ArkUI'

/**
 * Define the action of pip mode.
 *
 * Author: Seagazer
 * Date: 2025/3/6
 */
export interface IPip {

    /**
     * Set the pip enable, must call #setXComponentController first.
     * @param pipType The type{@link PiPWindow.PiPTemplateType} of pip window, default is VIDEO_PLAY.
     */
    enablePip(pipType: PiPWindow.PiPTemplateType): Promise<void>

    /**
     * Set the pip disable.
     */
    disablePip(): Promise<void>

    /**
     * Start the pip.
     */
    startPip(): Promise<void>

    /**
     * Stop the pip.
     */
    stopPip(): Promise<void>

    /**
     * Add a listener to observe the pip state changed.
     * @param listener The listener to observe the pip state changed.
     */
    addOnPipStateChangedListener(listener: (state: PiPWindow.PiPState, reason: string) => void): void

    /**
     * Remove a listener to observe the pip state changed.
     * @param listener The listener to observe the pip state changed.
     */
    removeOnPipStateChangedListener(listener: (state: PiPWindow.PiPState, reason: string) => void): void
}