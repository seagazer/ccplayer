import router from '@system.router';

@Entry
@Component
struct Index {
    build() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            Button("Audio")
                .fontSize(30)
                .width(300)
                .height(60)
                .onClick(() => {
                    router.push({
                        uri: "pages/audio"
                    })
                })
            Button("Video")
                .fontSize(30)
                .width(300)
                .height(60)
                .onClick(() => {
                    router.push({
                        uri: "pages/video"
                    })
                })
                .margin({ top: 50 })
            Button("PlayerView")
                .fontSize(30)
                .width(300)
                .height(60)
                .onClick(() => {
                    router.push({
                        uri: "pages/player_view"
                    })
                })
                .margin({ top: 50 })
        }
        .width("100%")
        .height("100%")
    }
}