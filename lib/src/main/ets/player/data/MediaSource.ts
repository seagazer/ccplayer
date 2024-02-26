import fs from '@ohos.file.fs'

/**
 * The data source for media.
 * @param title The display name of media.
 * @param source The filePath, assetsPath or url for media.
 */
export class MediaSource {
    source: string
    title: string

    constructor(source: string, title?: string) {
        this.source = source
        this.title = title
    }

    release() {
        if (this.source.startsWith("fd")) {
            let fd = Number.parseInt(this.source.split("//")[1])
            fs.closeSync(fd)
        }
    }
}