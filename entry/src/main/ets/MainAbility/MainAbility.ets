import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import { MediaLogger } from '@seagazer/ccplayer';

export default class MainAbility extends UIAbility {

    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        MediaLogger.setDebugger(true)
    }

    onWindowStageCreate(windowStage: window.WindowStage): void {
        windowStage.loadContent("pages/Logo")
    }
}
