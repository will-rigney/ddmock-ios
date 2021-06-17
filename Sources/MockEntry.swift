import Foundation

/**
 mock entry struct

 this refers to the endpoint + method
 */
struct MockEntry: Codable {
    // constants
    private static let defaultResponseTime = 400
    private static let defaultStatusCode = 200

    // ok
    let path: String

    // todo: should have more obvious structures for data

    // todo: less mutability
    var files: [URL] = []

    // todo: more thread safety
    var selectedFile = 0

    // ok hear me out here
    // key is string for a file
    // can just be the value with the path
    // value is key / value pair of headers default value encoded in json
    /**/
    // this is now just headings by endpoint
    var headers: [String: String] = [:]

    //
    private var statusCode = defaultStatusCode

    //
    var responseTime = defaultResponseTime

    ///
    init(path: String, files: [URL]) {
        self.path = path
        self.files = files
    }

    // this is the key for the selected file in the files list for an entry
    func getSelectedFile() -> String {
        let index = UserDefaultsHelper.getInteger(key: path, item: .mockFile)
        return files[index].absoluteString
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

    // nice
    func getHeaders() -> [String: String]? {
        // needs to return the overridden value from userdefaults
        var headers = self.headers
        // get all the values from user defaults if they exist
        for title in headers.keys {
            let key = "\(path.replacingOccurrences(of: "/", with: "."))\(title)"
            if let value = UserDefaultsHelper.getString(key: key, item: .headerValue) {
                headers[title] = value
            }
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
