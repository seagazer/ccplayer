import { BuilderNode, NodeController, UIContext } from '@kit.ArkUI';
import { CcPlayer } from '../CcPlayer';
import { MediaSource } from '../data/MediaSource';

/**
 * The default overlay for title bar of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2025/1/5
 */
export class CcTitleBarOverlay extends NodeController {
    private builderNode?: BuilderNode<[TitleBarOverlayConfig]> = undefined
    private overlayView: WrappedBuilder<[TitleBarOverlayConfig]> = wrapBuilder(overlay)
    private config: TitleBarOverlayConfig
    private mediaChangedListener = (source: MediaSource) => {
        this.config.title = source.title
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
        this.config.player.addOnMediaChangedListener(this.mediaChangedListener)
    }

    aboutToDisappear(): void {
        this.config.player.removeOnMediaChangedListener(this.mediaChangedListener)
    }

    makeNode(uiContext: UIContext): FrameNode | null {
        if (!this.builderNode) {
            this.builderNode = new BuilderNode(uiContext)
            this.builderNode.build(this.overlayView, this.config)
        }
        return this.builderNode.getFrameNode()
    }

    /**
     * Set the size of text.
     * @param size The size of text with unit fp.
     */
    setTextSize(size: number) {
        if (this.config.textSize != size) {
            this.config.textSize = size
            this.invalidate()
        }
    }

    /**
     * Set the color of text.
     * @param color The color of text.
     */
    setTextColor(color: ResourceColor) {
        if (this.config.textColor != color) {
            this.config.textColor = color
            this.invalidate()
        }
    }

    /**
     * Set the visible of overlay.
     * @param type The visible of this view.
     */
    setVisible(visible: boolean) {
        if (this.config.visible != visible) {
            this.config.visible = visible
            this.invalidate()
        }
    }

    /**
     * Set background color of overlay.
     * @param color The color of overlay background.
     */
    setBackgroundColor(color: ResourceColor) {
        if (this.config.bgColor != color) {
            this.config.bgColor = color
            this.builderNode?.update(this.config)
        }
    }

    private invalidate() {
        this.builderNode?.update(this.config);
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
    .padding(16)
    .backgroundColor(config.bgColor)
    .justifyContent(FlexAlign.Center)
    .visibility(config.visible ? Visibility.Visible : Visibility.Hidden)
}

class TitleBarOverlayConfig {
    player: CcPlayer
    title: string = ""
    textSize: number = 14
    textColor: ResourceColor = "#ffffffff"
    visible: boolean = false
    bgColor: ResourceColor = "#a6000000"

    constructor(player: CcPlayer) {
        this.player = player;
    }
}