import { BuilderNode, UIContext } from '@kit.ArkUI';
import { MediaSource } from '@seagazer/ccplayer-base';
import { CcPlayer } from '../CcPlayer';
import { BaseOverlayConfig } from './base/BaseOverlayConfig';
import { BaseOverlayController } from './base/BaseOverlayController';

/**
 * The default overlay for title bar of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2025/1/5
 */
export class CcTitleBarOverlay extends BaseOverlayController<TitleBarOverlayConfig> {
    private overlayView: WrappedBuilder<[TitleBarOverlayConfig]> = wrapBuilder(overlay)
    private mediaChangedListener = (source: MediaSource) => {
        this.config!.title = source.title
        this.invalidate()
    }

    /**
     * The default constructor.
     * @param player The player instance of CcPlayer.
     */
    constructor(player: CcPlayer) {
        super()
        this.config = new TitleBarOverlayConfig(player)
    }

    aboutToAppear(): void {
        this.config!.player.addOnMediaChangedListener(this.mediaChangedListener)
    }

    aboutToDisappear(): void {
        this.config!.player.removeOnMediaChangedListener(this.mediaChangedListener)
    }

    makeNode(uiContext: UIContext): FrameNode | null {
        if (!this.builderNode) {
            this.builderNode = new BuilderNode(uiContext)
            this.builderNode.build(this.overlayView, this.config!)
        }
        return this.builderNode.getFrameNode()
    }

    /**
     * Set the size of text.
     * @param size The size of text with unit fp.
     */
    setTextSize(size: Length) {
        if (this.config!.textSize != size) {
            this.config!.textSize = size
            this.invalidate()
        }
    }

    /**
     * Set the color of text.
     * @param color The color of text.
     */
    setTextColor(color: ResourceColor) {
        if (this.config!.textColor != color) {
            this.config!.textColor = color
            this.invalidate()
        }
    }

    /**
     * Set the padding of title container.
     * @param padding The padding of title container.
     */
    setPadding(padding: Length | Padding) {
        if (this.config!.padding != padding) {
            this.config!.padding = padding
            this.invalidate()
        }
    }

    /**
     * Set background color of overlay.
     * @param color The color of overlay background.
     */
    setBackgroundColor(color: ResourceColor) {
        if (this.config!.bgColor != color) {
            this.config!.bgColor = color
            this.builderNode?.update(this.config!)
        }
    }

    private invalidate() {
        this.builderNode?.update(this.config!);
    }
}

@Builder
function overlay(config: TitleBarOverlayConfig) {
    Row() {
        Text(config.title)
            .fontSize(config.textSize)
            .fontColor(config.textColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width("100%")
    .padding(config.padding)
    .backgroundColor(config.bgColor)
    .justifyContent(FlexAlign.Center)
    .visibility(config.visible ? Visibility.Visible : Visibility.Hidden)
}

class TitleBarOverlayConfig extends BaseOverlayConfig {
    title: string = ""
    textSize: Length = 14
    padding: Length | Padding = 16
    textColor: ResourceColor = "#ffffffff"
    bgColor: ResourceColor = "#a6000000"
}