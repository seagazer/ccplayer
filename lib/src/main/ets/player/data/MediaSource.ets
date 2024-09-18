import fs from '@ohos.file.fs'
import media from '@ohos.multimedia.media'
import { resourceManager } from '@kit.LocalizationKit'
import { MediaSourceType } from './MediaSourceType'

/**
 * The data source for media.
 */
export class MediaSource {
    type: MediaSourceType
    url?: string = undefined
    rawFd?: resourceManager.RawFileDescriptor = undefined
    httpHeaders?: Record<string, string> = undefined
    strategy?: media.PlaybackStrategy = undefined

    constructor(type: MediaSourceType, httpHeaders?: Record<string, string>, strategy?: media.PlaybackStrategy) {
        this.type = type
        this.httpHeaders = httpHeaders
        this.strategy = strategy
        // this.isHttp = source.startsWith("http")
    }

    release() {
        if (this.url && this.url.startsWith("fd")) {
            let fd = Number.parseInt(this.url.split("//")[1])
            fs.closeSync(fd)
        }
    }
}
