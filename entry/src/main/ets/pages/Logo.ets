import router from '@ohos.router';

@Extend(Text)
function logoStyle() {
    .fontSize(64)
    .fontWeight(FontWeight.Bold)
}

@Entry
@Component
struct Logo {
    private logoName = ["c", "c", "p", "l", "a", "y", "e", "r",]
    private logoColor = ["#ffc84747", "#ff5dd2c8", "#ff021fb2", "#ffb3d84f", "#ff6ac847", "#ffd29f5d", "#ff5d8cd7", "#ffd84f4f", "#ffdd77e8"]
    @State alphas: Array<number> = [0, 0, 0, 0, 0, 0, 0, 0,]
    private duration = 350
    private delay = 200
    @State pageScale: number = 1
    @State pageAlpha: number = 1

    build() {
        Row() {
            ForEach(this.logoName, (name: string, index: number) => {
                Text(name)
                    .logoStyle()
                    .scale({ x: this.alphas[index], y: this.alphas[index] })
                    .opacity(this.alphas[index])
                    .fontColor(this.logoColor[Math.floor(Math.random() * this.logoColor.length)])
                    .padding(1)
            })
        }
        .width("100%")
        .height("100%")
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
        .justifyContent(FlexAlign.Center)
        .onAreaChange(() => {
            for (let i = 0; i < this.logoName.length; i++) {
                animateTo(
                    {
                        duration: this.duration,
                        delay: this.delay * i,
                        curve: Curve.Friction
                    },
                    () => {
                        this.alphas[i] = 1
                    })
            }
            setTimeout(() => {
                router.pushUrl({
                    url: "pages/Home"
                })
            }, 500 + this.duration + this.delay * this.logoName.length)
        })
    }
}