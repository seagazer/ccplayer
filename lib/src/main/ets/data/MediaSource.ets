import fs from '@ohos.file.fs'
import media from '@ohos.multimedia.media'
import { MediaSourceType } from './MediaSourceType'
import common from '@ohos.app.ability.common'

/**
 * The data source for media.
 *
 * Author: Seagazer
 * Date: 2024/09/18
 */
export class MediaSource {
    type: MediaSourceType
    title: string
    cover?: string | PixelMap
    url?: string = undefined
    rawAssetsPath?: string = undefined
    httpHeaders?: Record<string, string> = undefined
    strategy?: media.PlaybackStrategy = undefined

    constructor(type: MediaSourceType, title: string, cover?: string | PixelMap, httpHeaders?: Record<string, string>,
        strategy?: media.PlaybackStrategy) {
        this.type = type
        this.title = title
        this.cover = cover
        this.httpHeaders = httpHeaders
        this.strategy = strategy
    }

    release(context: common.Context) {
        if (this.url && this.url.startsWith("fd")) {
            let fd = Number.parseInt(this.url.split("//")[1])
            fs.closeSync(fd)
        } else if (this.rawAssetsPath) {
            context.resourceManager.closeRawFdSync(this.rawAssetsPath)
        }
    }
}
