import { PiPWindow } from '@kit.ArkUI';
import { IPip, MediaLogger, PlayerState } from '@seagazer/ccplayer_base';
import { CcPlayer } from '../CcPlayer';

/**
 * The manager to handle pip mode.
 *
 * Author: Seagazer
 * Date: 2025/3/6
 */

const TAG = "[PipManager]"

export class PipManager implements IPip {
    private pipType: PiPWindow.PiPTemplateType = PiPWindow.PiPTemplateType.VIDEO_PLAY
    private isControllerChanged: boolean = false
    private player: CcPlayer
    private context: Context
    private pipController?: PiPWindow.PiPController = undefined
    private navigationId: string = ''
    private defaultStateChangedListener = (state: PlayerState) => {
        if (state == PlayerState.STATE_STARTED) {
            this.pipController?.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, PiPWindow.PiPControlStatus.PLAY)
        } else {
            this.pipController?.updatePiPControlStatus(PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE, PiPWindow.PiPControlStatus.PAUSE)
        }
    }
    private defaultVideoSizeChangedListener = (w: number, h: number) => {
        if (w <= 0 || h <= 0) {
            MediaLogger.attentionE(TAG, 'The size of video is illegal value, not update the pip size!')
            return
        }
        this.pipController?.updateContentSize(w, h)
    }
    private pipActionEventListener = (event: PiPWindow.PiPActionEventType, status?: number) => {
        switch (event) {
            case "playbackStateChanged":
                if (status == 0) {
                    this.player.pause();
                } else {
                    this.player.start();
                }
                break;
        }
    }
    private pipStateChangedListeners: Array<(state: PiPWindow.PiPState, reason: string) => void> = []

    constructor(player: CcPlayer, context: Context) {
        this.player = player
        this.context = context
    }

    /**
     * Notify the xComponent controller is changed, must recreate the pipController instance next time.
     */
    notifyControllerChanged() {
        this.isControllerChanged = true
    }

    canUsePip(): boolean {
        if (canIUse('SystemCapability.Window.SessionManager')) {
            if (PiPWindow.isPiPEnabled()) {
                return true
            }
        }
        return false
    }

    async enablePip(navigationId: string, pipType: PiPWindow.PiPTemplateType): Promise<void> {
        if (!PiPWindow.isPiPEnabled()) {
            MediaLogger.attentionW(TAG, "The platform is not support pip mode.")
            return undefined
        }
        if (!this.player.getXComponentController()) {
            MediaLogger.attentionE(TAG, "The xComponentController is null, must call #setXComponentController first.")
            return undefined
        }
        if (this.pipController) {
            MediaLogger.attentionW(TAG, "The pip is enabled, can not enable again!")
            return
        }
        MediaLogger.d(TAG, "enable pip")
        this.navigationId = navigationId
        this.pipType = pipType
        this.pipController = await this.createPipController()
        this.pipController.on("stateChange", (state: PiPWindow.PiPState, reason: string) => {
            MediaLogger.d(TAG, "pip state changed= " + state + ", reason= " + reason)
            this.pipStateChangedListeners.forEach((callback) => {
                callback(state, reason)
            })
        })
    }

    async disablePip() {
        if (this.pipController) {
            MediaLogger.d(TAG, "disable pip")
            await this.stopPip()
            this.pipController.off("controlPanelActionEvent")
        }
    }

    async startPip() {
        if (!this.pipController) {
            return
        }
        if (this.isControllerChanged) {
            this.pipController = await this.createPipController();
        }
        MediaLogger.d(TAG, "start pip")
        this.player.addOnStateChangedListener(this.defaultStateChangedListener)
        this.player.addOnVideoSizeChangedListener(this.defaultVideoSizeChangedListener)
        await this.pipController.startPiP()
    }

    private async createPipController(): Promise<PiPWindow.PiPController> {
        const pipController = await PiPWindow.create({
            context: this.context,
            componentController: this.player.getXComponentController(),
            navigationId: this.navigationId,
            templateType: this.pipType
        });
        this.isControllerChanged = false;
        pipController.on("controlPanelActionEvent", this.pipActionEventListener)
        MediaLogger.d(TAG, "create pip controller success")
        return pipController
    }

    async stopPip() {
        if (!PiPWindow.isPiPEnabled()) {
            MediaLogger.attentionW(TAG, "The platform is not support pip mode.")
            return
        }
        if (!this.player.getXComponentController()) {
            MediaLogger.attentionE(TAG, "The xComponentController is null, must call #setXComponentController first.")
            return
        }
        if (this.pipController) {
            MediaLogger.d(TAG, "stop pip")
            this.player.removeOnStateChangedListener(this.defaultStateChangedListener)
            this.player.removeOnVideoSizeChangedListener(this.defaultVideoSizeChangedListener)
            await this.pipController.stopPiP()
        }
    }

    addOnPipStateChangedListener(listener: (state: PiPWindow.PiPState, reason: string) => void) {
        if (this.pipStateChangedListeners.indexOf(listener) < 0) {
            this.pipStateChangedListeners.push(listener)
        }
    }

    removeOnPipStateChangedListener(listener: (state: PiPWindow.PiPState, reason: string) => void) {
        const index = this.pipStateChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.pipStateChangedListeners.splice(index, 1)
        }
    }
}