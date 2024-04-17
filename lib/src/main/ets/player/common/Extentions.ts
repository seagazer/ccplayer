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

// import systemParameter from '@ohos.systemParameter'

// @deprecated since v1.0.4
// export function getApiVersion(): number {
//     // const.ohos.apiversion = 10
//     let version = systemParameter.getSync(" const.ohos.apiversion", "9")
//     return Number.parseFloat(version)
// }