import { Logger } from './Logger';
import fileIO from '@ohos.fileio'

const TAG = "MediaSource"

/**
 * Helper to create media source from file and assets.
 */
export class MediaSource {
    /**
     * Create a media source for local file.
     * @param filePath The path of media file.
     */
    public static async createFile(filePath: string): Promise<string> {
        let fdPath = 'fd://'
        Logger.d(TAG, "filePath = " + filePath)
        let fd = await fileIO.open(filePath)
        let result = fdPath + '' + fd
        Logger.d(TAG, "createFile = " + result)
        return result
    }

    /**
     * Create a media source for assets file.
     * @param abilityContext The context of ability.
     * @param assetsPath The path of raw assets file.
     */
    public static async createAssets(abilityContext, assetsPath: string): Promise<string> {
        if (abilityContext == undefined) {
            Logger.e(TAG, "The context is null!!!")
        }
        let fdPath = 'fd://'
        Logger.d(TAG, "assetsPath = " + assetsPath)
        let rfd = await abilityContext.resourceManager.getRawFileDescriptor(assetsPath)
        let result = fdPath + '' + rfd.fd
        Logger.d(TAG, "createAssets = " + result)
        return result
    }
}