import promptAction from "@ohos.promptAction"

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

export function toast(message: string, duration: number = 2000) {
    promptAction.showToast({
        message: message,
        duration: duration
    })
}

export const LOGO_COLOR =
    ["#ffc84747", "#ff5dd2c8", "#ff021fb2", "#ffb3d84f", "#ff6ac847", "#ffd29f5d", "#ff5d8cd7", "#ffd84f4f", "#ffdd77e8"]

export const MOCK_SOURCE = [
    ["TestVideo1", "video1.mp4", "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg"],
    ["TestVideo2", "video2.mp4", "https://img1.baidu.com/it/u=4039557469,3031542597&fm=253&fmt=auto&app=138&f=JPEG?w=200&h=200"],
]