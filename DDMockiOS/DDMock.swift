import Foundation

public class DDMock {
    private let mockDirectory = "/mockfiles"
    private let jsonExtension = "json"
    
    private var mockEntries = [String: MockEntry]()
    
    public static let shared = DDMock()
    
    public func initialise() {
        let docsPath = Bundle.main.resourcePath! + mockDirectory
        let fileManager = FileManager.default
        
        fileManager.enumerator(atPath: docsPath)?.forEach({ (e) in
            if let e = e as? String, let url = URL(string: e) {
                if (url.pathExtension == jsonExtension) {
                    createMockEntry(url: url)
                }
            }
        })
    }
    
    private func createMockEntry(url: URL) {
        let fileName = "/" + url.lastPathComponent
        let key = url.path.replacingOccurrences(of: fileName, with: "")
        if var entry = mockEntries[key] {
            entry.files.append(url.path)
            mockEntries[key] = entry
        } else {
            mockEntries[key] = MockEntry(path: key, files: [url.path])
        }
        print("END")
    }
    
    func getMockEntry(path: String, method: String) -> MockEntry? {
        let path = path.replacingRegexMatches(pattern: "^/", replaceWith: "") + "/" + method.lowercased()
        if let entry = mockEntries[path] {
            return entry
        } else {
            return getRegexEntry(path: path)
        }
    }
    
    func getMockEntry(request: URLRequest) -> MockEntry? {
        if let url = request.url,
            let method = request.httpMethod {
            let path = url.path.replacingRegexMatches(pattern: "^/", replaceWith: "") + "/" + method.lowercased()
            if let entry = mockEntries[path] {
                return entry
            } else {
                return getRegexEntry(path: path)
            }
        }
        return nil
    }
    
    private func getRegexEntry(path: String) -> MockEntry? {
        for key in mockEntries.keys {
            if (key.contains("_")) {
                let regex = key.replacingRegexMatches(pattern: "_.*_", replaceWith: ".*")
                if (path.matches(regex)) {
                    return mockEntries[key]
                }
            }
        }
        return nil
    }
    
    func getData(_ entry: MockEntry) -> Data? {
        var data: Data? = nil
        let f = entry.files[entry.getSelectedFile()]
        do {
            let docsPath = Bundle.main.resourcePath! + mockDirectory
            data = try Data(contentsOf: URL(fileURLWithPath: "\(docsPath)/\(f)"), options: .mappedIfSafe)
        } catch {
            data = nil
        }
        return data
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func replacingRegexMatches(pattern: String, replaceWith: String = "") -> String {
        var newString = ""
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            newString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            debugPrint("Error \(error)")
        }
        return newString
    }
}
