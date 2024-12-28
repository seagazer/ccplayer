import { GestureType } from './GestureType'

/**
 * The config to set gesture type area of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2024/12/28
 */
export class GestureAreaConfig {
    left: GestureType
    right: GestureType

    /**
     * The default constructor.
     * @param left The gesture type for left part half width of CcPlayerView.
     * @param right The gesture type for right part half width of CcPlayerView.
     */
    constructor(left: GestureType = GestureType.BRIGHTNESS, right: GestureType = GestureType.VOLUME) {
        this.left = left
        this.right = right
    }
}