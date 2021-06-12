import Foundation

/**
 mock entry struct
 */
struct MockEntry: Codable {
    // constants
    private static let defaultResponseTime = 400
    private static let defaultStatusCode = 200

    // ok
    let path: String

    // todo: less mutability
    var files: [String] = []

    // todo: more thread safety
    var selectedFile = 0

    //
    private var statusCode = defaultStatusCode

    //
    var responseTime = defaultResponseTime

    ///
    init(path: String, files: [String]) {
        self.path = path
        self.files = files
    }

    // this is the key for the selected file in the files list for an entry
    func getSelectedFile() -> String {
        let index = UserDefaultsHelper.getInteger(key: path, item: .mockFile)
        return files[index]
    }

    // get status code for an entry
    func getStatusCode() -> Int {
        return UserDefaultsHelper.getObject(
            key: path,
            item: .statusCode) ?? MockEntry.defaultStatusCode
    }

    // get use real api
    func useRealAPI() -> Bool {
        return Self.getGlobalUseRealAPIs()
            || getEndpointUseRealAPI(key: path)
    }

    // get response time
    func getResponseTime() -> Int {
        return UserDefaultsHelper.getObject(
            key: path,
            item: .responseTime) ?? MockEntry.defaultResponseTime
    }

    func getHeaders() -> [String: String]? {
        // get a group or an array?
        // ok this one is funny
        var headers: [String: String] = [:]
        func getHeaderKey(_ i: Int) -> String {
            let selectedFile = getSelectedFile()
            let trimIndex = selectedFile.lastIndex(of: ".")
            // probably a more readable way
            let filename =  trimIndex != nil
                ? String(selectedFile.prefix(upTo: trimIndex!))
                : selectedFile
            return "\(filename)\(i)"
        }

        var i = 0
        while
            let (title, value) = UserDefaultsHelper.getTitleValuePair(key: getHeaderKey(i)) {
            headers[title ?? ""] = value ?? ""
            i += 1
        }
        return headers
    }

    private func getEndpointUseRealAPI(key: String) -> Bool {
        return UserDefaultsHelper.getObject(key: key, item: .useRealApi) ?? false
    }

    // read global from user defaults
    static func getGlobalUseRealAPIs() -> Bool {
        return UserDefaultsHelper.getObject(key: "", item: .globalUseRealApis) ?? false
    }
}
