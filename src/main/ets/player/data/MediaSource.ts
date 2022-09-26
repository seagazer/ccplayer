/**
 * The data source for media.
 * @param title The display name of media.
 * @param source The filePath, assetsPath or url for media.
 */
export class MediaSource {
    title: string
    source: string

    constructor(title: string, source: string) {
        this.title = title
        this.source = source
    }
}