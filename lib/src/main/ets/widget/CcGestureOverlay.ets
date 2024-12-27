import { timeToString } from '../common/Extentions'
import { GestureOverlayConfig } from '../config/GestureOverlayConfig'
import { GestureType } from '../config/GestureType'
import { BuilderNode, FrameNode, NodeController, UIContext } from '@kit.ArkUI'
import { CcPlayer } from '../CcPlayer'

/**
 * The default overlay for gesture actions of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2024/12/26
 */
export class CcGestureOverlay extends NodeController {
    private builderNode?: BuilderNode<[GestureOverlayConfig]> = undefined
    private overlayView: WrappedBuilder<[GestureOverlayConfig]> = wrapBuilder(overlay)
    private config: GestureOverlayConfig

    /**
     * The default constructor.
     * @param player The player instance of CcPlayer.
     */
    constructor(player: CcPlayer) {
        super()
        this.config = new GestureOverlayConfig(player)
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
            this.builderNode?.update(this.config)
        }
    }

    /**
     * Set the color of text.
     * @param color The color of text.
     */
    setTextColor(color: ResourceColor) {
        if (this.config.textColor != color) {
            this.config.textColor = color
            this.builderNode?.update(this.config)
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

    /**
     * Set the gesture type of CcPlayerView.
     * @param type The gesture type.{@link GestureType}
     */
    setGestureType(type: GestureType) {
        if (this.config.gestureType != type) {
            this.config.gestureType = type
            this.builderNode?.update(this.config)
        }
    }

    /**
     * Set the gesture percent of CcPlayerView.
     * @param type The gesture percent value.
     */
    setGesturePercent(percent: number) {
        if (this.config.gesturePercent != percent) {
            this.config.gesturePercent = percent
            this.builderNode?.update(this.config)
        }
    }

    /**
     * Set the visible of overlay.
     * @param type The visible of this view.
     */
    setGestureOverlayVisible(visible: boolean) {
        if (this.config.gestureOverlayVisible != visible) {
            this.config.gestureOverlayVisible = visible
            this.builderNode?.update(this.config)
        }
    }
}

@Builder
function overlay(config: GestureOverlayConfig) {
    if (config.gestureOverlayVisible) {
        if (config.gestureType == GestureType.PROGRESS) {
            Row() {
                SymbolGlyph($r('sys.symbol.fast_forward'))
                    .fontColor([config.textColor])
                    .fontSize(config.textSize + 2)
                Text(timeToString(config.player.getDuration() * config.gesturePercent) + " / " + timeToString(config.player.getDuration()))
                    .fontSize(config.textSize)
                    .fontColor(config.textColor)
                    .margin({ left: 8 })
            }
            .borderRadius(4)
            .backgroundColor(config.bgColor)
            .padding({
                left: 24,
                right: 24,
                top: 12,
                bottom: 12
            })
        } else if (config.gestureType == GestureType.VOLUME) {
            Row() {
                SymbolGlyph(config.gesturePercent == 0 ? $r('sys.symbol.speaker') : $r('sys.symbol.speaker_wave_1'))
                    .fontColor([config.textColor])
                    .fontSize(config.textSize + 2)
                Text(Math.round(config.gesturePercent * 100) + "%")
                    .fontSize(config.textSize)
                    .fontColor(config.textColor)
                    .margin({ left: 8 })
            }
            .borderRadius(4)
            .backgroundColor(config.bgColor)
            .padding({
                left: 24,
                right: 24,
                top: 12,
                bottom: 12
            })
        } else {
            Row() {
                SymbolGlyph($r('sys.symbol.sun_max'))
                    .fontColor([config.textColor])
                    .fontSize(config.textSize + 2)
                Text(Math.round(config.gesturePercent * 100) + "%")
                    .fontSize(config.textSize)
                    .fontColor(config.textColor)
                    .margin({ left: 8 })
            }
            .borderRadius(4)
            .backgroundColor(config.bgColor)
            .padding({
                left: 24,
                right: 24,
                top: 12,
                bottom: 12
            })
        }
    }
}

