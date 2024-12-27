import { CcPlayer } from "../CcPlayer";
import { GestureType } from "./GestureType";

/**
 *
 * Author: Seagazer
 * Date: 2024/12/27
 */
export class GestureOverlayConfig {
    player: CcPlayer
    gestureType: GestureType = GestureType.PROGRESS
    gesturePercent: number = 0
    gestureOverlayVisible: boolean = false
    textSize: number = 14
    textColor: ResourceColor = "#ffffffff"
    bgColor: ResourceColor = "#a6000000"

    constructor(player: CcPlayer) {
        this.player = player;
    }
}
