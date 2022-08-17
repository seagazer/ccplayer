import hilog from '@ohos.hilog';

const domain = 110

export class Logger {
    private static DEBUG = true
    private static FILTER_NAME = "[ZPlayer]: "

    static setDebugger(debug: boolean) {
        this.DEBUG = debug
    }

    static setFilterName(name: string) {
        this.FILTER_NAME = "[" + name + "]: "
    }

    static d(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.debug(domain, this.FILTER_NAME + tag, message)
    }

    static w(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.warn(domain, this.FILTER_NAME + tag, message)
    }

    static i(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.info(domain, this.FILTER_NAME + tag, message)
    }

    static e(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.error(domain, this.FILTER_NAME + tag, message)
    }

    static f(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.fatal(domain, this.FILTER_NAME + tag, message)
    }
}