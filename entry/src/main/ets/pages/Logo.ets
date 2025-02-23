import router from '@ohos.router';
import { LOGO_COLOR } from '../Extentions';

@Extend(Text)
function logoStyle() {
    .fontSize(64)
    .fontWeight(FontWeight.Bold)
}

@Entry
@Component
struct Logo {
    private logoName = ["c", "c", "p", "l", "a", "y", "e", "r",]
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
                    .fontColor(LOGO_COLOR[Math.floor(Math.random() * LOGO_COLOR.length)])
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