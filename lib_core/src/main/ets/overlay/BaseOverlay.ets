import { CcPlayer } from '../CcPlayer';
import { BuilderNode, NodeController } from '@kit.ArkUI';

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

export abstract class BaseOverlayController<C extends BaseOverlayConfig> extends NodeController {
    builderNode?: BuilderNode<[C]> = undefined
    config?: C = undefined

    /**
     * Set the visible of overlay.
     * @param type The visible of this view.
     */
    setVisible(visible: boolean) {
        if (this.config!.visible != visible) {
            this.config!.visible = visible
            this.builderNode?.update(this.config!)
        }
    }
}