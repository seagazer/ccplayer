/**
 * The data source for media.
 * @param source The filePath, assetsPath or url for media.
 */
export class MediaSource {
    source: string

    constructor(source: string) {
        this.source = source
    }
}