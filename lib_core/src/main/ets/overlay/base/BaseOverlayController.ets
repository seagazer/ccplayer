import { BuilderNode, NodeController } from '@kit.ArkUI';
import { BaseOverlayConfig } from './BaseOverlayConfig';

/**
 *
 * Author: Seagazer
 * Date: 2025/7/26
 */
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