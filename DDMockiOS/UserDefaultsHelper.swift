import Foundation

class UserDefaultsHelper {
    enum SettingsKey: String {
        case statusCode = "_status_code"
        case responseTime = "_response_time"
        case endpoint = "_endpoint"
        case mockFile = "_mock_file"
        case useRealApi = "_use_real_api"
        case globalUseRealApis = "use_real_apis"
    }

    static func getInteger(key: String, item: SettingsKey) -> Int {
        let key = getSettingsBundleKey(key: key) + item.rawValue
        return UserDefaults.standard.integer(forKey: key)
    }

    static func getObject<T>(key: String, item: SettingsKey) -> T? {
        let key = getSettingsBundleKey(key: key) + item.rawValue
        return UserDefaults.standard.object(forKey: key) as? T
    }
}

// replaces / with . for some undocumented reason
private func getSettingsBundleKey(key: String) -> String {
    return key.replacingOccurrences(of: "/", with: ".")
}
