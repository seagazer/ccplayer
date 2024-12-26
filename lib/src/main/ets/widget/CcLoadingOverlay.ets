import { CcPlayer } from '../CcPlayer'

/**
 * The default overlay for loading state of CcPlayer.
 *
 * Author: Seagazer
 * Date: 2024/12/26
 */
@Component
export struct CcLoadingOverlay {
    @State isLoading: boolean = false
    /**
     * The player instance of CcPlayer, must not be null.
     */
    player?: CcPlayer
    /**
     * The size of loading view.
     */
    loadingSize: Size = { width: 56, height: 56 }
    /**
     * The color of loading progress.
     */
    loadingColor: ResourceColor = Color.White
    private preparedListener = () => {
        this.isLoading = true
    }
    private firstFrameListener = () => {
        this.isLoading = false
    }

    aboutToAppear(): void {
        if (this.player) {
            this.player.addOnPreparedListener(this.preparedListener)
            this.player.addOnRenderFirstFrameListener(this.firstFrameListener)
        }
    }

    aboutToDisappear(): void {
        if (this.player) {
            this.player.removeOnPreparedListener(this.preparedListener)
            this.player.removeOnRenderFirstFrameListener(this.firstFrameListener)
        }
    }

    build() {
        if (this.isLoading) {
            Column() {
                LoadingProgress()
                    .color(this.loadingColor)
                    .size(this.loadingSize)
            }
        }
    }
}