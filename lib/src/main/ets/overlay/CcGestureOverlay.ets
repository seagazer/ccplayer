import { timeToString } from '../common/Extentions'
import { GestureType } from '../view/config/GestureType'
import { BuilderNode, FrameNode, UIContext, window } from '@kit.ArkUI'
import { CcPlayer } from '../CcPlayer'
import { BaseOverlayConfig, BaseOverlayController } from './BaseOverlay'
import { GestureLiveData } from './livedata/GestureLiveData'

/**
 * The default overlay for gesture actions of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2024/12/26
 */
export class CcGestureOverlay extends BaseOverlayController<GestureOverlayConfig> {
    private overlayView: WrappedBuilder<[GestureOverlayConfig]> = wrapBuilder(overlay)
    private player: CcPlayer
    private playerWindow?: window.Window
    private totalDuration: number = 0
    private prepareListener = () => {
        this.totalDuration = this.player.getDuration()
        if (this.config) {
            this.config.totalDuration = this.totalDuration
        }
    }
    private gestureChangedListener = (value: GestureEvent) => {
        this.handleGestureAction(value.uiContext, value.type, value.percent, value.isTouchUp)
    }
    private visibleChangedListener = (value: boolean) => {
        this.setVisible(value)
    }

    /**
     * The default constructor.
     * @param player The player instance of CcPlayer.
     */
    constructor(player: CcPlayer) {
        super()
        this.player = player
        this.config = new GestureOverlayConfig(player)
    }

    aboutToAppear(): void {
        GestureLiveData.getInstance().addOnGestureStateChangedListener(this.gestureChangedListener)
        GestureLiveData.getInstance().addOnVisibleStateChangedListener(this.visibleChangedListener)
        this.player.addOnPreparedListener(this.prepareListener)
    }

    aboutToDisappear(): void {
        GestureLiveData.getInstance().removeOnGestureStateChangedListener(this.gestureChangedListener)
        GestureLiveData.getInstance().removeOnVisibleStateChangedListener(this.visibleChangedListener)
        this.player.removeOnPreparedListener(this.prepareListener)
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
    setTextSize(size: number) {
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
     * Set background color of overlay.
     * @param color The color of overlay background.
     */
    setBackgroundColor(color: ResourceColor) {
        if (this.config!.bgColor != color) {
            this.config!.bgColor = color
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the gesture type of CcPlayerView.
     * @param type The gesture type.{@link GestureType}
     */
    setGestureType(type: GestureType) {
        if (this.config!.gestureType != type) {
            this.config!.gestureType = type
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Set the gesture percent of CcPlayerView.
     * @param type The gesture percent value.
     */
    setGesturePercent(percent: number) {
        if (this.config!.gesturePercent != percent) {
            this.config!.gesturePercent = percent
            this.builderNode?.update(this.config!)
        }
    }

    /**
     * Handle the gesture action to control the player.
     * @param uiContext The context of current ui page.
     * @param type The gesture type.{@link GestureType}.
     * @param percent The gesture percent value.
     * @param isTouchUp The touch state of touch event.
     *
     * @deprecated since V1.2.2
     */
    handleGestureAction(uiContext: UIContext, type: GestureType, percent: number, isTouchUp: boolean) {
        this.setGestureType(type)
        this.setGesturePercent(percent)
        switch (type) {
            case GestureType.PROGRESS:
                const seekPosition = this.totalDuration * percent
                if (isTouchUp) {
                    this.player.seekTo(seekPosition)
                }
                break
            case GestureType.BRIGHTNESS:
                if (this.playerWindow == undefined) {
                    this.playerWindow = window.findWindow(uiContext.getWindowName())
                }
                this.playerWindow?.setWindowBrightness(percent)
                break
            case GestureType.VOLUME:
                this.player.setVolume(percent)
                break
        }
    }
}

@Builder
function overlay(config: GestureOverlayConfig) {
    if (config.visible) {
        if (config.gestureType == GestureType.PROGRESS) {
            Row() {
                SymbolGlyph($r('sys.symbol.fast_forward'))
                    .fontColor([config.textColor])
                    .fontSize(config.textSize + 2)
                Text(timeToString(config.totalDuration * config.gesturePercent) + " / " + timeToString(config.totalDuration))
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

class GestureOverlayConfig extends BaseOverlayConfig {
    gestureType: GestureType = GestureType.PROGRESS
    gesturePercent: number = 0
    textSize: number = 14
    textColor: ResourceColor = "#ffffffff"
    bgColor: ResourceColor = "#a6000000"
    totalDuration: number = 0
}

export class GestureEvent {
    uiContext: UIContext
    type: GestureType
    percent: number
    isTouchUp: boolean

    constructor(uiContext: UIContext, type: GestureType, percent: number, isTouchUp: boolean) {
        this.uiContext = uiContext
        this.type = type
        this.percent = percent
        this.isTouchUp = isTouchUp
    }
}