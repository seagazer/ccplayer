import hilog from '@ohos.hilog';

const domain = 0x176

/**
 * The logger to print app log.
 *
 * Author: Seagazer
 * Date: 2024/9/18
 */
export class MediaLogger {
    private static DEBUG = false
    private static FILTER_NAME = "ccplayer: "

    static setDebugger(debug: boolean) {
        MediaLogger.DEBUG = debug
    }

    static setFilterName(name: string) {
        MediaLogger.FILTER_NAME = name
    }

    static attentionW(tag: string, message: string) {
        hilog.warn(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }

    static attentionE(tag: string, message: string) {
        hilog.error(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }

    static d(tag: string, message: string) {
        if (!MediaLogger.DEBUG) {
            return
        }
        hilog.debug(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }

    static w(tag: string, message: string) {
        if (!MediaLogger.DEBUG) {
            return
        }
        hilog.warn(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }

    static i(tag: string, message: string) {
        if (!MediaLogger.DEBUG) {
            return
        }
        hilog.info(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }

    static e(tag: string, message: string) {
        if (!MediaLogger.DEBUG) {
            return
        }
        hilog.error(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }

    static f(tag: string, message: string) {
        if (!MediaLogger.DEBUG) {
            return
        }
        hilog.fatal(domain, MediaLogger.FILTER_NAME, tag + " " + message)
    }
}