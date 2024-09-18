import router from '@ohos.router';
import { AspectRatio, CcPlayer, CcPlayerView, MediaSourceFactory } from '@seagazer/ccplayer';

const TAG = '[ccplayer]'

@Entry
@Component
struct Home {
    private player = new CcPlayer()
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State isLoading: boolean = true

    aboutToAppear(): void {
        router.clear()
        this.player.addOnStateChangedListener((state) => {
            console.warn(TAG, "new state= " + state)
        }).addOnRenderFirstFrameListener(() => {
            this.isLoading = false
        })
    }

    build() {
        Scroll() {
            Column() {
                Stack() {
                    CcPlayerView({
                        player: this.player,
                        asRatio: this.ratio,
                        viewSize: {
                            width: '100%', height: '100%'
                        },
                        onSurfaceCreated: () => {
                            MediaSourceFactory.createAssets(getContext(this), "test.mp4")
                                .then((src) => {
                                    src && this.player.setMediaSource(src, () => {
                                        this.player.start()
                                    })
                                })
                        }
                    })
                    if (this.isLoading) {
                        LoadingProgress()
                            .color(Color.White)
                            .width(60).height(60)
                    }
                }.width(300)
                .height(200)

                Row() {
                    Button('init')
                        .onClick(() => {
                            this.player.reset()
                            MediaSourceFactory.createAssets(getContext(this), "test.mp4")
                                .then((src) => {
                                    this.isLoading = true
                                    src && this.player.setMediaSource(src, () => {
                                        this.player.start()
                                    })
                                })
                        })
                    Button('play')
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
                .justifyContent(FlexAlign.SpaceAround)
            }
            .width("100%")
        }
        .width("100%")
        .height("100%")
        .padding(16)
    }
}