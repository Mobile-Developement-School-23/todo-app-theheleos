import CocoaLumberjack

class LoggerFormatter: NSObject, DDLogFormatter {
    private let dateFormatter: DateFormatter
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        super.init()
    }
    func format(message logMessage: DDLogMessage) -> String? {
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        let logLevel = "\(logMessage.flag.rawValue)"
        let logMsg = logMessage.message
        return "\(timestamp) [\(logLevel)] \(logMsg)"
    }
}

class LoggerConfig {

    static func configureLogger() {
        
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(DDFileLogger())

        #if DEBUG
            DDLog.setLevel(.debug, for: DDOSLogger.self)
            DDLog.setLevel(.debug, for: DDFileLogger.self)
        #else
            DDLog.setLevel(.warning, for: DDOSLogger.self)
            DDLog.setLevel(.warning, for: DDFileLogger.self)
        #endif

        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 14

        let formatter = LoggerFormatter()
        DDTTYLogger.sharedInstance?.logFormatter = formatter
        fileLogger.logFormatter = formatter
    }
}
