import Foundation

class UserDefaultsHelper {
    enum SettingsKey: String {
        case statusCode = "_status_code"
        case responseTime = "_response_time"
        case endpoint = "_endpoint"
        case mockFile = "_mock_file"
        case useRealApi = "_use_real_api"
        case headerValue = "_value"
        case headerTitle = "_title"
        case globalUseRealApis = "use_real_apis"
    }

    /**
     Helper function, gets an item from the settings bundle
     by replacing '/'s with '.' in the key, then adding the item ray value
     Returns userdefaults item for this key.
     */
    static func getInteger(key: String, item: SettingsKey) -> Int {
        let key = getSettingsBundleKey(key: key) + item.rawValue
        return UserDefaults.standard.integer(forKey: key)
    }

    static func getObject<T>(key: String, item: SettingsKey) -> T? {
        let key = getSettingsBundleKey(key: key) + item.rawValue
        return UserDefaults.standard.object(forKey: key) as? T
    }

    static func getString(key: String, item: SettingsKey) -> String? {
        let key = getSettingsBundleKey(key: key) + item.rawValue
        return UserDefaults.standard.string(forKey: key)
    }

    static func getTitleValuePair(key: String) -> (title: String?, value: String?)? {
        let title = getString(key: key, item: .headerTitle)
        let value = getString(key: key, item: .headerValue)

        if title == nil && value == nil { return nil }

        return (title, value)
    }
}

// replaces / with . to be consistent with other keys
private func getSettingsBundleKey(key: String) -> String {
    return key.replacingOccurrences(of: "/", with: ".")
}
