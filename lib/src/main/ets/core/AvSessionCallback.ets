/**
 * The callback from av session controller.
 *
 * Author: Seagazer
 * Date: 2024/10/23
 */
export interface AvSessionCallback {
    /**
     * Callback when play next.
     */
    onNext: () => void
    /**
     * Callback when play pre.
     */
    onPrevious: () => void
}