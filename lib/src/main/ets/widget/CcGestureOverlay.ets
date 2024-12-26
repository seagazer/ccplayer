import { CcPlayer } from '../CcPlayer'
import { GestureType } from '../config/GestureType'

/**
 * The default overlay for gesture actions of CcPlayerView.
 *
 * Author: Seagazer
 * Date: 2024/12/26
 */
@Component
export struct CcGestureOverlay {
    @Prop gestureType: GestureType
    @Prop gesturePercent: number
    @Prop gestureOverlayVisible: boolean
    /**
     * The player instance of CcPlayer, must not be null.
     */
    player?: CcPlayer
    /**
     * The size of text of overlay.
     */
    textSize: number = 14
    /**
     * The color of text of overlay.
     */
    textColor: ResourceColor = "#ffffffff"
    /**
     * The background color of overlay.
     */
    bgColor: ResourceColor = "#a6000000"

    build() {
        if (this.player && this.gestureOverlayVisible) {
            if (this.gestureType == GestureType.PROGRESS) {

                Row() {
                    SymbolGlyph($r('sys.symbol.fast_forward'))
                        .fontColor([this.textColor])
                        .fontSize(this.textSize + 2)
                    Text(this.timeToString(this.player.getDuration() * this.gesturePercent) + " / " + this.timeToString(this.player.getDuration()))
                        .fontSize(this.textSize)
                        .fontColor(this.textColor)
                        .margin({ left: 8 })
                }
                .borderRadius(4)
                .backgroundColor(this.bgColor)
                .padding({
                    left: 24,
                    right: 24,
                    top: 12,
                    bottom: 12
                })
            } else if (this.gestureType == GestureType.VOLUME) {
                Row() {
                    SymbolGlyph(this.gesturePercent == 0 ? $r('sys.symbol.speaker') : $r('sys.symbol.speaker_wave_1'))
                        .fontColor([this.textColor])
                        .fontSize(this.textSize + 2)
                    Text(Math.round(this.gesturePercent * 100) + "%")
                        .fontSize(this.textSize)
                        .fontColor(this.textColor)
                        .margin({ left: 8 })
                }
                .borderRadius(4)
                .backgroundColor(this.bgColor)
                .padding({
                    left: 24,
                    right: 24,
                    top: 12,
                    bottom: 12
                })
            } else {
                Row() {
                    SymbolGlyph($r('sys.symbol.sun_max'))
                        .fontColor([this.textColor])
                        .fontSize(this.textSize + 2)
                    Text(Math.round(this.gesturePercent * 100) + "%")
                        .fontSize(this.textSize)
                        .fontColor(this.textColor)
                        .margin({ left: 8 })
                }
                .borderRadius(4)
                .backgroundColor(this.bgColor)
                .padding({
                    left: 24,
                    right: 24,
                    top: 12,
                    bottom: 12
                })
            }
        }
    }

    private timeToString(time: number): string {
        let seconds = Math.floor((time / 1000))
        let minute = Math.floor(seconds / 60)
        seconds %= 60
        let hour = 0
        if (minute > 60) {
            hour = minute / 60
            minute %= 60
        }
        let resultMinute: string = minute < 10 ? `0${minute}` : minute.toString()
        let resultSecond: string = seconds < 10 ? `0${seconds}` : seconds.toString()
        let result = hour != 0 ? `${hour}:${resultMinute}:${resultSecond}` : `${resultMinute}:${resultSecond}`
        return result
    }
}