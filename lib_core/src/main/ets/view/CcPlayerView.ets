import { CcPlayer } from '../CcPlayer';
import { GestureLiveData } from '../overlay/livedata/GestureLiveData';
import { GestureEvent } from '../overlay/CcGestureOverlay';
import { AspectRatio, GestureAreaConfig, GestureType, IJK } from '@seagazer/ccplayer-base';
import { PlayerType } from '../common/PlayerType';
import { PlayerViewLogic } from './PlayerViewLogic';

const TAG = "[CcPlayerView]"

/**
 * A component to play video, you can control media player with gesture and change the aspect ratio of the picture.
 *
 * Author: Seagazer
 * Date: 2022/9/12
 *
 * The controller area define:
 * |----  Widget Width  ----|
 * |----|----|----|----|----|
 * |    |              |    |
 * |Brt |   Progress   | Vol|
 * |    |              |    |
 * |____|____|____|____|____|
 */
@Component
export struct CcPlayerView {
    /*-------------------------------------outer settings--------------------------------------------*/
    /**
     * The instance of a ccplayer to bind.
     */
    player?: CcPlayer = undefined
    /**
     * The config of gesture action, default is [left:brightness, right:volume].
     */
    gestureAreaConfig: GestureAreaConfig = new GestureAreaConfig()
    /**
     * The damping of progress gesture move, the value must be positive, default is 2.
     */
    horizontalGestureDamping: number = 2
    /**
     * The damping of brightness and volume gesture move, the value must be positive, default is 1.5.
     */
    verticalGestureDamping: number = 1.5
    /**
     * The type of XComponent to render video, default is Surface.
     */
    renderType: XComponentType = XComponentType.SURFACE
    /**
     * Set the video ratio, the value is from # AspectRatio.
     */
    @Link @Watch("onAspectRatioChanged") asRatio: AspectRatio
    /**
     * Set the delay to auto hide gesture controller ui, default is 1500ms.
     */
    autoHideControllerDelay: number = 1500
    /**
     * The duration of animation for aspect ratio changed.
     */
    aspectRatioChangeAnimationDuration: number = 150
    /**
     * Set support gesture action to control or not, default is true.
     */
    isSupportGesture: boolean = true
    /**
     * Set a callback to observe the touch event of this view.
     */
    onTouchCallback?: ((event: TouchEvent) => void) = undefined
    /**
     * Set a callback to observe the surface state when onLoad.
     */
    onSurfaceCreated?: ((surfaceId: string) => void) = undefined
    /**
     * Set a callback to observe the surface state when onDestroy.
     */
    onSurfaceDestroy?: ((surfaceId: string) => void) = undefined
    /**
     * Set a listener to handle the gesture ui visible.
     */
    onGestureUIListener?: ((visible: boolean) => void) = (visible: boolean) => {
        GestureLiveData.getInstance().setVisibleState(visible)
    }
    /**
     * The listener to handle the gesture actions.
     */
    onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => void =
        (type: GestureType, percent: number, isTouchUp: boolean) => {
            if (this.gestureEvent === null) {
                this.gestureEvent = new GestureEvent(this.getUIContext(), type, percent, isTouchUp)
            } else {
                this.gestureEvent.uiContext = this.getUIContext()
                this.gestureEvent.type = type
                this.gestureEvent.percent = percent
                this.gestureEvent.isTouchUp = isTouchUp
            }
            GestureLiveData.getInstance().setGestureState(this.gestureEvent)
        }
    /**
     * The listener to handle the double click action.
     */
    onDoubleClickAction: () => void = () => {
        GestureLiveData.getInstance().onDoubleClick()
    }
    private gestureEvent: GestureEvent | null = null
    /**
     * Set the default brightness, the value is [0,1], default is 0.5.
     */
    defaultBrightness: number = 0.5
    /**
     * Set the default volume, the value is [0,1], default is 1.
     */
    defaultVolume: number = 1
    /*-----------------------------------------------------------------------------------------------*/
    private controller = new XComponentController()
    private surfaceId: string = ""
    private playerViewLogic: PlayerViewLogic | null = null
    @State surfaceWidth: number = 0
    @State surfaceHeight: number = 0
    @State isShowSurface: boolean = false
    @State pipState: string = ''

    private getPlayerViewLogic(): PlayerViewLogic {
        if (this.playerViewLogic === null) {
            this.playerViewLogic = new PlayerViewLogic({
                tag: TAG,
                player: this.player!,
                gestureAreaConfig: this.gestureAreaConfig,
                horizontalGestureDamping: this.horizontalGestureDamping,
                verticalGestureDamping: this.verticalGestureDamping,
                defaultBrightness: this.defaultBrightness,
                defaultVolume: this.defaultVolume,
                autoHideControllerDelay: this.autoHideControllerDelay,
                onSurfaceSizeChanged: (width: number, height: number): void => {
                    this.surfaceWidth = width
                    this.surfaceHeight = height
                },
                onSurfaceVisibleChanged: (visible: boolean): void => {
                    this.isShowSurface = visible
                },
                onPipStateChanged: (state: string): void => {
                    this.pipState = state
                },
                onGestureUIVisibleChanged: (visible: boolean): void => {
                    this.onGestureUIListener && this.onGestureUIListener(visible)
                },
                onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean): void => {
                    this.onGestureAction && this.onGestureAction(type, percent, isTouchUp)
                },
                onDoubleClickAction: (): void => {
                    this.onDoubleClickAction && this.onDoubleClickAction()
                },
                getAspectRatio: (): AspectRatio => {
                    return this.asRatio
                }
            })
        }
        return this.playerViewLogic
    }

    private onAspectRatioChanged(): void {
        this.getPlayerViewLogic().onAspectRatioChanged()
    }

    aboutToAppear(): void {
        this.getPlayerViewLogic().aboutToAppear(this.isSupportGesture)
    }

    aboutToDisappear(): void {
        this.getPlayerViewLogic().aboutToDisappear()
    }

    build() {
        Stack() {
            if (this.getPlayerViewLogic().getPlayerType() === PlayerType.IJKPLAYER) {
                XComponent({
                    controller: this.controller,
                    type: this.renderType,
                    id: IJK.ID,
                    libraryname: IJK.NAPI,
                })
                    .width(this.surfaceWidth)
                    .height(this.surfaceHeight)
                    .onLoad((context) => {
                        this.surfaceId = this.getPlayerViewLogic().bindIjkXComponent(this.controller, context!)
                        this.onSurfaceCreated && this.onSurfaceCreated(this.surfaceId)
                    })
                    .onDestroy(() => {
                        this.onSurfaceDestroy && this.onSurfaceDestroy(this.surfaceId)
                    })
                    .animation({
                        duration: this.aspectRatioChangeAnimationDuration, onFinish: () => {
                            this.getPlayerViewLogic().onResizeAnimationFinish()
                        }
                    })
                    .visibility(this.isShowSurface ? Visibility.Visible : Visibility.Hidden)
            } else if (this.getPlayerViewLogic().getPlayerType() === PlayerType.AVPLAYER) {
                XComponent({
                    id: "ccplayer",
                    controller: this.controller,
                    type: this.renderType
                })
                    .width(this.surfaceWidth)
                    .height(this.surfaceHeight)
                    .onLoad(() => {
                        this.surfaceId = this.getPlayerViewLogic().bindAvPlayerXComponent(this.controller)
                        this.onSurfaceCreated && this.onSurfaceCreated(this.surfaceId)
                    })
                    .onDestroy(() => {
                        this.onSurfaceDestroy && this.onSurfaceDestroy(this.surfaceId)
                    })
                    .animation({
                        duration: this.aspectRatioChangeAnimationDuration, onFinish: () => {
                            this.getPlayerViewLogic().onResizeAnimationFinish()
                        }
                    })
                    .visibility(this.isShowSurface ? Visibility.Visible : Visibility.Hidden)
            }
            Text(this.pipState).visibility(Visibility.None)
        }
        .gesture(TapGesture({ count: 2 }).onAction(() => {
            if (this.isSupportGesture) {
                this.getPlayerViewLogic().handleDoubleClickEvent()
            }
        }))
        .onTouch((event) => {
            if (this.isSupportGesture) {
                this.getPlayerViewLogic().handleTouchEvent(event)
                this.onTouchCallback && this.onTouchCallback(event)
            }
        })
        .width('100%')
        .height('100%')
        .onSizeChange((_, newSize) => {
            this.getPlayerViewLogic().onSizeChange(newSize.width as number, newSize.height as number)
        })
        .alignContent(Alignment.Center)
        .backgroundColor("#FF000000")
        .clip(true)
    }
}
