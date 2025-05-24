import { PiPWindow } from '@kit.ArkUI'

/**
 * Define the action of pip mode.
 *
 * Author: Seagazer
 * Date: 2025/3/6
 */
export interface IPip {
    /**
     * get pip whether can use
     */
    canUsePip(): boolean

    /**
     * Set the pip enable, must call #setXComponentController first.
     *
     * navigationId If the UIAbility use Navigation api to handle page router, should set this id, so can restore from pip to the page with this id.
     * @param pipType The type{@link PiPWindow.PiPTemplateType} of pip window, default is VIDEO_PLAY.
     */
    enablePip(navigationId: string, pipType: PiPWindow.PiPTemplateType): Promise<void>

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