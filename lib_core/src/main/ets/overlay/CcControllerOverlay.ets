import { BuilderNode, UIContext } from '@kit.ArkUI';
import { timeToString } from '@seagazer/ccplayer-base';
import { CcPlayer } from '../CcPlayer';
import { BaseOverlayConfig } from './base/BaseOverlayConfig';
import { BaseOverlayController } from './base/BaseOverlayController';

/**
 * The default overlay for controller of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2025/1/5
 */
export class CcControllerOverlay extends BaseOverlayController<ControllerOverlayConfig> {
    private overlayView: WrappedBuilder<[ControllerOverlayConfig]> = wrapBuilder(overlay)
    private preparedListener = () => {
        this.config!.totalDuration = this.config!.player.getDuration()
    }
    private progressChangedListener = (position: number) => {
        if (this.config!.isSeeking) {
            return
        }
        this.config!.currentPosition = position
        this.builderNode?.update(this.config!)
    }
    private seekChangedListener = (position: number) => {
        this.config!.isSeeking = false
        this.config!.currentPosition = position
        this.builderNode?.update(this.config!)
    }

    /**
     * The default constructor.
     * @param player The player instance of CcPlayer.
     */
    constructor(player: CcPlayer) {
        super()
        this.config = new ControllerOverlayConfig(player)
    }

    aboutToAppear(): void {
        this.config!.player.addOnPreparedListener(this.preparedListener)
        this.config!.player.addOnSeekChangedListener(this.seekChangedListener)
        this.config!.player.addOnProgressChangedListener(this.progressChangedListener)
    }

    aboutToDisappear(): void {
        this.config!.player.removeOnPreparedListener(this.preparedListener)
        this.config!.player.removeOnSeekChangedListener(this.seekChangedListener)
        this.config!.player.removeOnProgressChangedListener(this.progressChangedListener)
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
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the color of text.
     * @param color The color of text.
     */
    setTextColor(color: ResourceColor) {
        if (this.config!.textColor != color) {
            this.config!.textColor = color
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the color of seekbar.
     * @param color The color of seekbar.
     */
    setSliderTrackColor(color: ResourceColor) {
        if (this.config!.trackColor != color) {
            this.config!.trackColor = color
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the color of seekbar.
     * @param color The color of seekbar.
     */
    setSliderBlockColor(color: ResourceColor) {
        if (this.config!.blockColor != color) {
            this.config!.blockColor = color
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the color of seekbar.
     * @param color The color of seekbar.
     */
    setSliderSelectedColor(color: ResourceColor) {
        if (this.config!.selectedColor != color) {
            this.config!.selectedColor = color
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the horizontal margin of seekbar.
     * @param margin The horizontal margin of seekbar.
     */
    setSliderMargin(margin: Margin) {
        if (this.config!.sliderMargin != margin) {
            this.config!.sliderMargin = margin
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the horizontal padding of overlay.
     * @param padding The horizontal padding of overlay.
     */
    setPadding(padding: Length | Padding) {
        if (this.config!.padding != padding) {
            this.config!.padding = padding
            this.builderNode?.update(this.config!)
        }
    }
}

@Builder
function overlay(config: ControllerOverlayConfig) {
    Row() {
        Text(timeToString(config.currentPosition))
            .fontSize(config.textSize)
            .fontColor(config.textColor)
        Slider({
            value: config.currentPosition,
            max: config.totalDuration,
            min: 0,
            step: 1000,
        })
            .layoutWeight(1)
            .enabled(config.totalDuration > 0)
            .trackColor(config.trackColor)
            .selectedColor(config.selectedColor)
            .blockColor(config.blockColor)
            .margin(config.sliderMargin)
            .onChange((value, mode) => {
                if (mode == SliderChangeMode.Begin) {
                    config.isSeeking = true
                } else if (mode == SliderChangeMode.End) {
                    let position = Math.ceil(value)
                    config.player.seekTo(position)
                    config.currentPosition = position
                }
            })
        Text(timeToString(config.totalDuration))
            .fontSize(config.textSize)
            .fontColor(config.textColor)
    }
    .width("100%")
    .padding(config.padding)
    .visibility(config.visible ? Visibility.Visible : Visibility.Hidden)
}

class ControllerOverlayConfig extends BaseOverlayConfig {
    currentPosition: number = 0
    totalDuration: number = 0
    textSize: Length = 14
    textColor: ResourceColor = "#ffffffff"
    isSeeking: boolean = false
    trackColor: ResourceColor = "#ccffffff"
    blockColor: ResourceColor = "#ffffff"
    selectedColor: ResourceColor = $r('sys.color.ohos_id_color_emphasize')
    sliderMargin: Margin = { left: 8, right: 8 }
    padding: Length | Padding = { left: 16, right: 16 }
}