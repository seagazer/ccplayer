import { GestureAreaConfig, GestureType } from "@seagazer/ccplayer-base"
import { CcPlayer } from "../CcPlayer"

const TOUCH_SHOT = 10

/**
 * Author: Seagazer
 * Date: 2025/8/11
 */
export class GestureHandler {
    private downX: number = -1
    private downY: number = -1
    private controlType: GestureType = GestureType.PROGRESS
    private isUserMoved: boolean = false
    private viewWidth: number = 0
    private viewHeight: number = 0
    private totalDuration: number = 0
    private gesturePercentResult: number = 0
    private hideControllerTimer: number = -1
    private player: CcPlayer
    private gestureAreaConfig: GestureAreaConfig
    private horizontalGestureDamping: number
    private verticalGestureDamping: number
    private currentBrightness: number
    private currentVolume: number
    private autoHideControllerDelay: number
    private onControllerVisibleChanged: (visible: boolean) => void
    private onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => void

    constructor(player: CcPlayer,
        gestureAreaConfig: GestureAreaConfig, horizontalGestureDamping: number, verticalGestureDamping: number,
        currentBrightness: number, currentVolume: number, autoHideControllerDelay: number,
        onControllerVisibleChanged: (visible: boolean) => void,
        onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => void) {
        this.player = player
        this.gestureAreaConfig = gestureAreaConfig
        this.horizontalGestureDamping = horizontalGestureDamping
        this.verticalGestureDamping = verticalGestureDamping
        this.currentBrightness = currentBrightness
        this.currentVolume = currentVolume
        this.autoHideControllerDelay = autoHideControllerDelay
        this.onControllerVisibleChanged = onControllerVisibleChanged
        this.onGestureAction = onGestureAction
    }

    setTotalDuration(duration: number) {
        this.totalDuration = duration
    }

    setViewSize(width: number, height: number) {
        this.viewWidth = width
        this.viewHeight = height
    }

    release() {
        clearTimeout(this.hideControllerTimer)
    }

    handleTouchEvent(event: TouchEvent) {
        let touchEvent = event.touches[0]
        switch (event.type) {
            case TouchType.Down:
                this.handleTouchDown(touchEvent)
                break
            case TouchType.Move:
                this.handleTouchMove(touchEvent)
                break
            case TouchType.Up:
            case TouchType.Cancel:
                this.handleTouchUp()
                break
            default:
                break
        }
    }

    private handleTouchDown(touchEvent: TouchObject) {
        clearTimeout(this.hideControllerTimer)
        this.onControllerVisibleChanged(false)
        this.downX = touchEvent.x
        this.downY = touchEvent.y
    }

    private handleTouchMove(touchEvent: TouchObject) {
        let dx = touchEvent.x - this.downX
        let dy = touchEvent.y - this.downY
        if (Math.abs(dx) > TOUCH_SHOT || Math.abs(dy) > TOUCH_SHOT) {
            // check the gesture type
            if (!this.isUserMoved) {
                this.isUserMoved = true
                if (Math.abs(dy) > Math.abs(dx)) { // vertical gesture
                    if (this.downX < this.viewWidth / 2) { // left
                        this.controlType = this.gestureAreaConfig.left
                    } else { // right
                        this.controlType = this.gestureAreaConfig.right
                    }
                } else { // horizontal gesture
                    this.controlType = GestureType.PROGRESS
                }
                this.onControllerVisibleChanged(true)
            }
            if (this.controlType == GestureType.PROGRESS) {
                let changePercent = dx / this.viewWidth / this.horizontalGestureDamping
                let begin = this.player!.getCurrentPosition()
                let current = begin + this.totalDuration * changePercent
                let result = this.limit(current, this.totalDuration, 0)
                this.gesturePercentResult = result / this.totalDuration
            } else if (this.controlType == GestureType.VOLUME) {
                let changePercent = -dy / this.viewHeight / this.verticalGestureDamping
                let begin = this.currentVolume
                let current = begin + 1 * changePercent
                let result = this.limit(current, 1, 0)
                this.gesturePercentResult = result / 1
            } else if (this.controlType == GestureType.BRIGHTNESS) {
                let changePercent = -dy / this.viewHeight / this.verticalGestureDamping
                let begin = this.currentBrightness
                let current = begin + 1 * changePercent
                let result = this.limit(current, 1, 0)
                this.gesturePercentResult = result / 1
            }
            this.onGestureAction(this.controlType, this.gesturePercentResult, false)
        }
    }

    private limit(value: number, max: number, min: number): number {
        value = Math.max(value, min)
        value = Math.min(value, max)
        return value
    }

    private handleTouchUp() {
        if (!this.isUserMoved) {
            return
        }
        this.isUserMoved = false
        this.onGestureAction(this.controlType, this.gesturePercentResult, true)
        if (this.controlType == GestureType.VOLUME) {
            this.currentVolume = this.gesturePercentResult
        } else if (this.controlType == GestureType.BRIGHTNESS) {
            this.currentBrightness = this.gesturePercentResult
        }
        this.downX = -1
        this.downY = -1
        this.hideControllerTimer = setTimeout(() => {
            this.onControllerVisibleChanged(false)
        }, this.autoHideControllerDelay)
    }
}