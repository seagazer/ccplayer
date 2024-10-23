/**
 * The callback from av session controller.
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