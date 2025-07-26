import { CcPlayer } from '../../CcPlayer';

/**
 * The base class of overlay.
 *
 * Author: Seagazer
 * Date: 2025/2/19
 */
export abstract class BaseOverlayConfig {
    player: CcPlayer
    visible: boolean = false

    constructor(player: CcPlayer) {
        this.player = player;
    }
}
