import { AspectRatio, CcPlayer, CcPlayerView, GestureType, MediaSourceFactory } from '@seagazer/ccplayer';
import { timeToString } from '../Extentions';
import { window } from '@kit.ArkUI';
import { CustomControlOverlay } from './CustomControlOverlay';

const TAG = '[CustomOverlaySample]'

@Component
export struct CustomOverlaySample {
    private player = new CcPlayer(getContext(this))
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State isLoading: boolean = false
    @State gestureOverlayVisible: boolean = false
    @State gestureType: GestureType = GestureType.PROGRESS
    @State seekPercent: number = 0
    @State volumePercent: number = 0
    @State brightnessPercent: number = 0
    private controlOverlay?: CustomControlOverlay = undefined;
    private firstFrameListener = () => {
        this.isLoading = false
    }
    private playerWindow?: window.Window = undefined

    aboutToAppear(): void {
        this.playerWindow = window.findWindow(this.getUIContext().getWindowName())
        this.player.addOnRenderFirstFrameListener(this.firstFrameListener)
        this.controlOverlay = new CustomControlOverlay(this.player);
    }

    aboutToDisappear(): void {
        this.player.removeOnRenderFirstFrameListener(this.firstFrameListener)
        this.player.release()
    }

    private handleGesture = (type: GestureType, percent: number, isTouchUp: boolean) => {
        this.gestureType = type
        switch (type) {
            case GestureType.PROGRESS:
                this.seekPercent = percent
                if (isTouchUp) {
                    this.player.seekTo(this.player.getDuration() * percent)
                }
                break
            case GestureType.BRIGHTNESS:
                this.brightnessPercent = percent
                this.playerWindow?.setWindowBrightness(percent)
                break
            case GestureType.VOLUME:
                this.volumePercent = percent
                this.player.setVolume(percent)
                break
        }
    }

    @Builder
    GestureOverlay() {
        if (this.gestureOverlayVisible && !this.isLoading) {
            if (this.gestureType == GestureType.PROGRESS) {
                Row() {
                    Text(timeToString(this.player.getDuration() * this.seekPercent) + " / " + timeToString(this.player.getDuration()))
                        .fontSize(18)
                        .fontColor("#ffde4545")
                        .backgroundColor("#b3e5d179")
                        .borderRadius(4)
                        .padding(8)
                }.width(150)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .animation({ duration: 150 })
            } else if (this.gestureType == GestureType.VOLUME) {
                Row() {
                    Text("音量：" + Math.round(this.volumePercent * 100) + "%")
                        .fontSize(18)
                        .fontColor("#ffde4545")
                        .backgroundColor("#b3e5d179")
                        .borderRadius(4)
                        .padding(8)
                }.width(150)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .animation({ duration: 150 })
            } else {
                Row() {
                    Text("亮度：" + Math.round(this.brightnessPercent * 100) + "%")
                        .fontSize(18)
                        .fontColor("#ffde4545")
                        .backgroundColor("#b3e5d179")
                        .borderRadius(4)
                        .padding(8)
                }
                .width(150)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .animation({ duration: 150 })
            }
        }
    }

    @Builder
    LoadingOverlay() {
        if (this.isLoading) {
            LoadingProgress()
                .color(Color.White)
                .width(60).height(60)
        }
    }

    build() {
        NavDestination() {
            // video view
            Stack() {
                CcPlayerView({
                    player: this.player,
                    asRatio: this.ratio,
                    renderType: XComponentType.SURFACE,
                    onGestureAction: this.handleGesture,
                    onGestureUIListener: (visible) => {
                        this.gestureOverlayVisible = visible
                    },
                    onSurfaceCreated: () => {
                        this.isLoading = true
                        // let src = MediaSourceFactory.createAssets("TestVideo1", "video1.mp4",
                        // "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                        let src = MediaSourceFactory.createUrl('',
                            'http://vd3.bdstatic.com/mda-re23rzrhznhfjp9a/cae_h264/1746240582840699857/mda-re23rzrhznhfjp9a.mp4')
                        this.player.setMediaSource(src, () => {
                            this.player.start()
                        })
                    }
                })
                this.GestureOverlay()
                this.LoadingOverlay()

                NodeContainer(this.controlOverlay)
                    .width('100%')
                    .height(60)
                    .position({ y: '90%' })
            }
            .width("100%")
            .height("100%")
        }
        .width("100%")
        .height("100%")
        .title("CustomOverlaySample")
    }
}