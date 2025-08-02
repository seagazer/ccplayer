import { IjkTest } from "@seagazer/ccplayer_ijk"

/**
 *
 * Author: Seagazer
 * Date: 2025/8/2
 */
@ComponentV2
export struct IjkSample {
    build() {
        NavDestination() {
            IjkTest()
        }.title("IjkSample")
    }
}