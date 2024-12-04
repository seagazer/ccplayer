import { AspectRatio, CcPlayer, CcPlayerView, MediaSourceFactory } from '@seagazer/ccplayer';
import { timeToString } from '../Extentions';
import { Logger } from '../Logger';

const TAG = '[PagePlayerSample]'

@Component
export struct PagePlayerSample {
    private dataList = new DataProvider()
    @State curIndex: number = 0

    aboutToAppear(): void {
        this.dataList.uriList.push('video1.mp4')
        this.dataList.uriList.push('video2.mp4')
        this.dataList.uriList.push('video3.mp4')
        this.dataList.uriList.push('video4.mp4')
        this.dataList.uriList.push('video5.mp4')
    }

    build() {
        NavDestination() {
            Swiper() {
                LazyForEach(this.dataList, (uri: string, index: number) => {
                    ItemPage({
                        uri: uri,
                        pageIndex: index,
                        curPageIndex: this.curIndex
                    })
                })
            }
            .width('100%')
            .height('100%')
            .vertical(true)
            .loop(true)
            .cachedCount(1)
            .duration(300)
            .onAnimationStart((_, targetIndex) => {
                this.curIndex = targetIndex
            })
        }.width('100%')
        .height('100%')
        .title("PagePlayerSample")
    }
}

class DataProvider implements IDataSource {
    uriList: Array<string> = []

    totalCount(): number {
        return this.uriList.length
    }

    getData(index: number): string {
        return this.uriList[index]
    }

    registerDataChangeListener(listener: DataChangeListener): void {
    }

    unregisterDataChangeListener(listener: DataChangeListener): void {
    }
}

@Component
struct ItemPage {
    private player = new CcPlayer(getContext(this))
    pageIndex: number = 0
    uri: string = ""
    @Watch('onPageChanged') @Prop curPageIndex: number = 0
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    private preparedListener = () => {
        this.totalDuration = this.player.getDuration()
        Logger.d(TAG, "page " + this.pageIndex + " is prepared= " + this.totalDuration)
    }
    private progressChangedListener = (position: number) => {
        this.currentPosition = position
    }

    onPageChanged() {
        if (this.curPageIndex == this.pageIndex) {
            Logger.d(TAG, "onPageChanged: page " + this.pageIndex + " play")
            this.player.start()
        } else {
            if (this.player.isPlaying()) {
                Logger.d(TAG, "onPageChanged: page " + this.pageIndex + " pause")
                this.player.pause()
            }
        }
    }

    aboutToAppear(): void {
        this.player
            .addOnPreparedListener(this.preparedListener)
            .addOnProgressChangedListener(this.progressChangedListener)
    }

    aboutToDisappear(): void {
        this.player
            .removeOnPreparedListener(this.preparedListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
        this.player.release()
        Logger.w(TAG, "page " + this.pageIndex + " is destroyed")
    }

    build() {
        Stack() {
            CcPlayerView({
                player: this.player,
                asRatio: this.ratio,
                renderType: XComponentType.SURFACE,
                isSupportGesture: false,
                onSurfaceCreated: () => {
                    Logger.d(TAG, "page " + this.pageIndex + " is surface ready")
                    let src = MediaSourceFactory.createAssets('', this.uri)
                    this.player.setMediaSource(src, () => {
                        if (this.curPageIndex == this.pageIndex) {
                            Logger.d(TAG, "page " + this.pageIndex + " start play")
                            this.player.start()
                        }
                    })
                }
            }).width('100%')
                .height('100%')

            Row() {
                Text(timeToString(this.currentPosition))
                    .fontSize(14).fontColor('#ffffff')
                Progress({
                    value: this.currentPosition,
                    total: this.totalDuration,
                    type: ProgressType.Linear
                }).backgroundColor('#ffffff')
                    .layoutWeight(1)
                    .padding({ left: 8, right: 8 })
                Text(timeToString(this.totalDuration))
                    .fontSize(14).fontColor('#ffffff')
            }
            .width('100%')
            .padding({ left: 8, right: 8, bottom: 16 })

        }
        .width('100%')
        .height('100%')
        .align(Alignment.Bottom)
    }
}