import { BuilderNode } from '@kit.ArkUI'
import { CcPlayer } from '../CcPlayer'
import { PlayerState } from '../core/config/PlayerState'
import { BaseOverlayConfig, BaseOverlayController } from './BaseOverlay'

/**
 * The default overlay for loading state of CcPlayer.
 *
 * Author: Seagazer
 * Date: 2025/1/5
 */
export class CcLoadingOverlay extends BaseOverlayController<LoadingOverlayConfig> {
    private overlayView: WrappedBuilder<[LoadingOverlayConfig]> = wrapBuilder(overlay)
    private preparedListener = () => {
        this.config!.visible = true
        this.invalidate()
    }
    private firstFrameListener = () => {
        this.config!.visible = false
        this.invalidate()
    }
    private stateChangedListener = (state: PlayerState) => {
        if (state == PlayerState.STATE_BUFFER_START) {
            this.config!.visible = true
            this.invalidate()
        } else if (state == PlayerState.STATE_BUFFER_END) {
            this.config!.visible = false
            this.invalidate()
        }
    }

    /**
     * The default constructor.
     * @param player The player instance of CcPlayer.
     */
    constructor(player: CcPlayer) {
        super()
        this.config = new LoadingOverlayConfig(player)
    }

    aboutToAppear(): void {
        this.config!.player.addOnPreparedListener(this.preparedListener)
        this.config!.player.addOnRenderFirstFrameListener(this.firstFrameListener)
        this.config!.player.addOnStateChangedListener(this.stateChangedListener)
    }

    aboutToDisappear(): void {
        this.config!.player.removeOnPreparedListener(this.preparedListener)
        this.config!.player.removeOnRenderFirstFrameListener(this.firstFrameListener)
        this.config!.player.removeOnStateChangedListener(this.stateChangedListener)
    }

    makeNode(uiContext: UIContext): FrameNode | null {
        if (!this.builderNode) {
            this.builderNode = new BuilderNode(uiContext)
            this.builderNode.build(this.overlayView, this.config!)
        }
        return this.builderNode.getFrameNode()
    }

    /**
     * Set the loading text.
     * @param text The text if loading view.
     */
    setLoadingText(text: string) {
        if (this.config!.loadingText != text) {
            this.config!.loadingText = text
            this.invalidate()
        }
    }

    /**
     * Set the size of loading progress bar.
     * @param size The  size of loading progress bar.
     */
    setLoadingSize(size: Length) {
        if (this.config!.loadingSize != size) {
            this.config!.loadingSize = size
            this.invalidate()
        }
    }

    /**
     * Set the margin between loading progress bar and loading text.
     * @param size The margin between loading progress bar and loading text.
     */
    setLoadingMargin(size: Length) {
        if (this.config!.loadingMargin != size) {
            this.config!.loadingMargin = size
            this.invalidate()
        }
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
     * Set the padding of loading container.
     * @param padding The padding of loading container.
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
function overlay(config: LoadingOverlayConfig) {
    if (config.visible) {
        Column() {
            LoadingProgress()
                .color(config.loadingColor)
                .size({ width: config.loadingSize, height: config.loadingSize })

            Text(config.loadingText)
                .fontSize(config.textSize)
                .fontColor(config.textColor)
                .margin({ top: config.loadingMargin })
        }
        .backgroundColor(config.bgColor)
        .padding(config.padding)
        .borderRadius(4)
    }
}

class LoadingOverlayConfig extends BaseOverlayConfig {
    loadingText: string = ""
    textSize: Length = 14
    textColor: ResourceColor = "#ffffffff"
    bgColor: ResourceColor = "#a6000000"
    loadingSize: Length = 56
    loadingColor: ResourceColor = Color.White
    loadingMargin: Length = 4
    padding: Length | Padding = {
        left: 32,
        top: 8,
        right: 32,
        bottom: 8
    }
}