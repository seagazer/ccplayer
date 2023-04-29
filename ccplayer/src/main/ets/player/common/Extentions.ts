/**
 * Converter time duration to display string like 00:00.
 * @param time The duration by million seconds.
 */
export function timeToString(time: number): string {
    let seconds = Math.floor((time / 1000))
    let minute = Math.floor(seconds / 60)
    seconds %= 60
    let hour = 0
    if (minute > 60) {
        hour = minute / 60
        minute %= 60
    }
    let resultMinute: string = minute < 10 ? `0${minute}` : minute.toString()
    let resultSecond: string = seconds < 10 ? `0${seconds}` : seconds.toString()
    let result = hour != 0 ? `${hour}:${resultMinute}:${resultSecond}` : `${resultMinute}:${resultSecond}`
    return result
}

// @ts-ignore
import systemParameter from '@ohos.systemParameter'

export function getOSVersion(): number {
    // const.product.software.version = OpenHarmony 3.2.11.9
    let version: string = systemParameter.getSync("const.product.software.version", "3.1")
    version = version.replace("OpenHarmony", "").trim()
    if (version.indexOf(".") > 0) {
        let split = version.split(".")
        version = split[0] + "." + split[1]
    }
    return Number.parseFloat(version)
}