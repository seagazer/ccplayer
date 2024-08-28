import router from '@ohos.router';


@Extend(Button)
function btnStyle() {
    .fontSize(30)
    .width(300)
    .height(60)
}

@Entry
@Component
struct Main {
    @State pageScale: number = 0
    @State pageAlpha: number = 0

    aboutToAppear(): void {
        router.clear()
    }

    build() {
        Column() {
            Navigator({ target: "pages/audio", type: NavigationType.Push }) {
                Button("Audio").btnStyle()
            }

            Navigator({ target: "pages/video", type: NavigationType.Push }) {
                Button("Video").btnStyle().margin({ top: 50 })
            }

            Navigator({ target: "pages/player_view", type: NavigationType.Push }) {
                Button("CcPlayerView").btnStyle().margin({ top: 50 })
            }

            Navigator({ target: "pages/custom_ui", type: NavigationType.Push }) {
                Button("CustomUI").btnStyle().margin({ top: 50 })
            }
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }
}