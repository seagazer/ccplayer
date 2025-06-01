/**
 * Converter time duration to display string like 00:00.
 * @param time The duration by million seconds.
 *
 * Author: Seagazer
 * Date: 2022/9/17
 */
export function timeToString(time: number): string {
    let seconds = Math.floor((time / 1000))
    let minute = Math.floor(seconds / 60)
    seconds %= 60
    let hour = 0
    if (minute > 60) {
        hour = Math.floor(minute / 60)
        minute %= 60
    }
    let resultMinute: string = minute < 10 ? `0${minute}` : minute.toString()
    let resultSecond: string = seconds < 10 ? `0${seconds}` : seconds.toString()
    let result = hour != 0 ? `${hour}:${resultMinute}:${resultSecond}` : `${resultMinute}:${resultSecond}`
    return result
}
