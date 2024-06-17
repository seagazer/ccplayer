import fs from '@ohos.file.fs'
import media from '@ohos.multimedia.media'

/**
 * The data source for media.
 */
export class MediaSource {
    source: string
    httpHeaders: Record<string, string> | null = null
    isHttp: boolean = false
    strategy: media.PlaybackStrategy | null = null

    constructor(source: string, httpHeaders: Record<string, string> = null, strategy: media.PlaybackStrategy = null) {
        this.source = source
        this.httpHeaders = httpHeaders
        this.strategy = strategy
        this.isHttp = source.startsWith("http")
    }

    release() {
        if (this.source.startsWith("fd")) {
            let fd = Number.parseInt(this.source.split("//")[1])
            fs.closeSync(fd)
        }
    }
}