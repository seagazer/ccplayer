import Ability from '@ohos.application.Ability'
import AbilityDelegatorRegistry from '@ohos.application.abilityDelegatorRegistry'
import { Hypium } from 'hypium/index'
import testsuite from '../test/List.test'

export default class TestAbility extends Ability {
    onCreate(want, launchParam) {
        console.log('TestAbility onCreate')
        var abilityDelegator: any
        abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        var abilityDelegatorArguments: any
        abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments()
        console.info('start run testcase!!!')
        Hypium.hypiumTest(abilityDelegator, abilityDelegatorArguments, testsuite)
    }

    onDestroy() {
        console.log('TestAbility onDestroy')
    }

    onWindowStageCreate(windowStage) {
        console.log('TestAbility onWindowStageCreate')
        windowStage.setUIContent(this.context, 'TestAbility/pages/index', null)

        globalThis.abilityContext = this.context;
    }

    onWindowStageDestroy() {
        console.log('TestAbility onWindowStageDestroy')
    }

    onForeground() {
        console.log('TestAbility onForeground')
    }

    onBackground() {
        console.log('TestAbility onBackground')
    }
};