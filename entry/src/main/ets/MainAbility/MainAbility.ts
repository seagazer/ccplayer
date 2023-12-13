import UIAbility from '@ohos.app.ability.UIAbility';
import { Logger } from '@seagazer/ccplayer';

export default class MainAbility extends UIAbility {
    onCreate(want, launchParam) {
        globalThis.abilityWant = want;
    }

    onWindowStageCreate(windowStage) {
        windowStage.setUIContent(this.context, "pages/logo", null)
    }

}
