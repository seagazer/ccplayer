import TestRunner from '@ohos.application.testRunner'
import AbilityDelegatorRegistry from '@ohos.application.abilityDelegatorRegistry'

var abilityDelegator = undefined
var abilityDelegatorArguments = undefined

function translateParamsToString(parameters) {
    const keySet = new Set([
        '-s class', '-s notClass', '-s suite', '-s it',
        '-s level', '-s testType', '-s size', '-s timeout'
    ])
    let targetParams = '';
    for (const key in parameters) {
        if (keySet.has(key)) {
            targetParams = `${targetParams} ${key} ${parameters[key]}`
        }
    }
    return targetParams.trim()
}

async function onAbilityCreateCallback() {
    console.log("onAbilityCreateCallback");
}

async function addAbilityMonitorCallback(err: any) {
    console.info("addAbilityMonitorCallback : " + JSON.stringify(err))
}

export default class OpenHarmonyTestRunner implements TestRunner {
    constructor() {
    }

    onPrepare() {
        console.info("OpenHarmonyTestRunner OnPrepare ")
    }

    async onRun() {
        console.log('OpenHarmonyTestRunner onRun run')
        abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments()
        abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        var testAbilityName = abilityDelegatorArguments.bundleName + '.TestAbility'
        let lMonitor = {
            abilityName: testAbilityName,
            onAbilityCreate: onAbilityCreateCallback,
        };
        abilityDelegator.addAbilityMonitor(lMonitor, addAbilityMonitorCallback)
        var cmd = 'aa start -d 0 -a TestAbility' + ' -b ' + abilityDelegatorArguments.bundleName
        cmd += ' '+translateParamsToString(abilityDelegatorArguments.parameters)
        console.info('cmd : '+cmd)
        abilityDelegator.executeShellCommand(cmd,
            (err: any, d: any) => {
                console.info('executeShellCommand : err : ' + JSON.stringify(err));
                console.info('executeShellCommand : data : ' + d.stdResult);
                console.info('executeShellCommand : data : ' + d.exitCode);
            })
        console.info('OpenHarmonyTestRunner onRun end')
    }
};