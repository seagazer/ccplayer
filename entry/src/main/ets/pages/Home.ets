import router from '@ohos.router';
import { AspectRatio, CcPlayer, CcPlayerView, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';

const TAG = '[ccplayer]'

@Entry
@Component
struct Home {
    private player = new CcPlayer()
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State isLoading: boolean = false
    private stateChangedListener = (state: PlayerState) => {
        console.debug(TAG, "new state= " + state)
    }
    private firstFrameListener = () => {
        this.isLoading = false
    }

    aboutToAppear(): void {
        router.clear()
        this.player
            .addOnStateChangedListener(this.stateChangedListener)
            .addOnRenderFirstFrameListener(this.firstFrameListener)
    }

    aboutToDisappear(): void {
        this.player
            .removeOnStateChangedListener(this.stateChangedListener)
            .removeOnRenderFirstFrameListener(this.firstFrameListener)
        this.player.release()
    }

    private controller = new XComponentController()

    build() {
        Scroll() {
            Column() {
                Stack() {
                    // XComponent({
                    //     id: 'play',
                    //     type: XComponentType.SURFACE,
                    //     controller: this.controller
                    // }).onLoad(() => {
                    //     this.player.setSurface(this.controller.getXComponentSurfaceId())
                    // }).width('100%')
                    //     .height('100%')
                    CcPlayerView({
                        player: this.player,
                        asRatio: this.ratio
                    })
                    if (this.isLoading) {
                        LoadingProgress()
                            .color(Color.White)
                            .width(60).height(60)
                    }
                }.width(300)
                .height(200)

                Row() {
                    Button('setSource')
                        .onClick(() => {
                            this.isLoading = true
                            this.player.reset()
                            MediaSourceFactory.createAssets(getContext(this), "test.mp4")
                                .then((src) => {
                                    src && this.player.setMediaSource(src, () => {
                                        this.player.start()
                                    })
                                })
                        })
                    Button('start')
                        .onClick(() => {
                            this.player.start()
                        })
                    Button('pause')
                        .onClick(() => {
                            this.player.pause()
                        })
                }
                .width("100%")
                .margin({ top: 16 })
                .justifyContent(FlexAlign.SpaceEvenly)
            }
            .width("100%")
        }
        .width("100%")
        .height("100%")
        .padding(16)
    }
}