import Foundation

struct MockEntry: Codable {
    internal static let defaultResponseTime = 400
    internal static let defaultStatusCode = 200
    
    let path: String
    var files = [String]()
    var selectedFile = 0
    private var statusCode = defaultStatusCode
    var responseTime = defaultResponseTime
    
    init(path: String, files: [String]) {
        self.path = path
        self.files = files
    }
    
    func getSelectedFile() -> Int {
        return DDMockSettingsBundleHelper.getSelectedMockFile(key: path)
    }
    
    func getStatusCode() -> Int {
        return DDMockSettingsBundleHelper.getStatusCode(key: path)
    }
    
    func useRealAPI() -> Bool {
        return DDMockSettingsBundleHelper.useRealAPI(key: path) ||
            DDMockSettingsBundleHelper.globalUseRealAPIs()
    }
    
    func getResponseTime() -> Int {
        return DDMockSettingsBundleHelper.getResponseTime(key: path)
    }
}
