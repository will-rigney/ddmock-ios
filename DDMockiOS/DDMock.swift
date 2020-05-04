import Foundation

public class DDMock {
    private let mockDirectory = "/mockfiles"
    private let jsonExtension = "json"
    
    private var mockEntries = [String: MockEntry]()

    private(set) var strict: Bool  = false  // Enforces mocks only and no API fall-through
    public private(set) var matchedPaths = [String]()  // chronological order of paths
    public var onMissingMock: (_ path: String?) -> Void = {path in
        fatalError("missing stub for path: \(path ?? "<unknown>")")
    }
    
    public static let shared = DDMock()

    public func initialise(strict: Bool = false) {
        self.strict = strict
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
    
    public func clearHistory() {
        matchedPaths.removeAll()
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
    }

    private func mockEntry(for path: String, isTest: Bool) -> MockEntry? {
        let entry = mockEntries[path] ?? getRegexEntry(path: path)
        guard !isTest else {
            return entry
        }
        // If strict mode is enabled, a missing entry is an error. Call handler.
        if strict && entry == nil {
            onMissingMock(path)
        }
        // Here we log the entries so that clients (like a unit test) can verify a call was made.
        matchedPaths.append(path)
        return entry
    }

    func hasMockEntry(path: String, method: String) -> EntrySetting {
        switch getMockEntry(path: path, method: method, isTest: true)?.useRealAPI() {
        case .none:
            return .notFound
        case .some(false):
            return .mocked
        case .some(true):
            return .useRealAPI
        }
    }

    func getMockEntry(path: String, method: String) -> MockEntry? {
        return getMockEntry(path: path, method: method, isTest: false)
    }

    private func getMockEntry(path: String, method: String, isTest: Bool) -> MockEntry? {
        guard let path = mockPath(path: path, method: method) else { return nil}
        return mockEntry(for: path, isTest: isTest)
    }

    func hasMockEntry(request: URLRequest) -> EntrySetting {
        guard let path = request.url?.path, let method = request.httpMethod else { return .notFound }
        return hasMockEntry(path: path, method: method)
    }
    
    func getMockEntry(request: URLRequest) -> MockEntry? {
        guard let path = request.url?.path, let method = request.httpMethod else { return nil }
        return getMockEntry(path: path, method: method, isTest: false)
    }

    private func getRegexEntry(path: String) -> MockEntry? {
        var matches = [MockEntry]()
        for key in mockEntries.keys {
            if (key.contains("_")) {
                let regex = key.replacingRegexMatches(pattern: "_[^/]*_", replaceWith: "[^/]*")
                if (path.matches(regex)) {
                    if let match = mockEntries[key] {
                        matches.append(match)
                    }
                }
            }
        }
        guard matches.count <= 1 else {
            fatalError("Fatal Error: Multiple matches for regex entry.")
        }
        return matches.first
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

extension DDMock {
    func mockPath(request: URLRequest) -> String? {
        if let url = request.url,
            let method = request.httpMethod {
            return mockPath(path: url.path, method: method)
        } else {
            return nil
        }
    }
    
    func mockPath(path: String, method: String) -> String? {
        return path.replacingRegexMatches(pattern: "^/", replaceWith: "") + "/" + method.lowercased()
    }
}
