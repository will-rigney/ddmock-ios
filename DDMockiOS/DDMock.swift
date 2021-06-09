import Foundation

/**
 This is the main DDMock entry point.


 */
public final class DDMock {

    /// path under resources directory
    private let mockDirectory = "/mockfiles"

    /// map
    private var mockEntries: [String: MockEntry] = [:]

    /// enforces mocks only and no API fall-through
    internal var strict: Bool = false

    // todo: this should be thread safe
    // and have a max size
    /// chronological order of paths
    private(set) var matchedPaths: [String] = []

    /// needed for singleton
    private init() {}

    /**
     Assignable handler when a mock is not present in strict mode.
     By default this is a panic!
     */
    public var onMissingMock: (_ path: String?) -> Void = { path in
        fatalError("missing stub for path: \(path ?? "<unknown>")")
    }

    // todo: remove the singleton if possible, require a single instance
    /// Singleton instance of DDMock
    public static let shared = DDMock()

    /**
     Initialise DDMock library
     This must be called on the DDMock.shared singleton
     by the client before DDMock can be used.
     */
    public func initialise(strict: Bool = false) {
       // todo: kinda not great maybe
       // this is called by the client on the singleton? archaic
        self.strict = strict

        // todo: resource path
        let path = Bundle.main.resourcePath! + mockDirectory

        // parse the files in the mock directory
        readMockFiles(path: path, fm: FileManager.default)

    }

    private func readMockFiles(path: String, fm: FileManager) {
        fm
            .enumerator(atPath: path)?
            .forEach {
                if
                    let e = $0 as? String,
                    let url = URL(string: e),
                    url.pathExtension == "json" {

                    createMockEntry(url: url)
                }
            }
    }

    /// reset the history
    public func clearHistory() {
        matchedPaths.removeAll()
    }

    // should be a "get or insert" function in the map
    private func createMockEntry(url: URL) {

        // todo: check this matching
        let fileName = "/" + url.lastPathComponent
        let key = url.path.replacingOccurrences(of: fileName, with: "")

        // todo: separate the assignment
        if var entry = mockEntries[key] {
            entry.files.append(url.path)
            mockEntries[key] = entry
        }
        else {
            mockEntries[key] = MockEntry(path: key, files: [url.path])
        }
    }

    /**
     get the mock entry
     */
    private func getMockEntry(path: String, isTest: Bool) -> MockEntry? {
        let entry = mockEntries[path] ?? getRegexEntry(path: path)
        guard !isTest else {
            return entry
        }
        // If strict mode is enabled, a missing entry is an error. Call handler.
        if strict && entry == nil {
            onMissingMock(path)
        }
        // Here we log the entries so that clients (like a unit test) can verify a call was made.
        // todo: this is guarded by isTest flag so doesn't apply to tests
        // todo: remove istest flag
        matchedPaths.append(path)
        return entry
    }

    /// wraps internal to always use false for isTest param
    internal func getMockEntryByPath(path: String, method: String) -> MockEntry? {
        return getMockEntryInternal(path: path, method: method, isTest: false)
    }


    /// todo: doc
    internal func hasMockEntryByPath(path: String, method: String) -> Bool {

        // idk what the idea of this map function useRealAPI

        // get the entry
        // todo: cache
        guard let entry = getMockEntryInternal(
                path: path,
                method: method,
                isTest: true) else {

            return false
        }

        // entry can override this value itself
        return entry.useRealAPI()
    }

    // called by the two above functions
    private func getMockEntryInternal(path: String, method: String, isTest: Bool) -> MockEntry? {
        guard
            let path = getMockPath(path: path, method: method) else {
            return nil
        }
        return getMockEntry(path: path, isTest: isTest)
    }


    //
    private func getMockPath(path: String, method: String) -> String? {
        return path.replacingRegexMatches(
            pattern: "^/",
            replaceWith: "") + "/" + method.lowercased()
    }


    // todo: high complexity function in the public interface
    private func getRegexEntry(path: String) -> MockEntry? {
        var matches = [MockEntry]()
        for key in mockEntries.keys {
            if (key.contains("_")) {
                let regex = key.replacingRegexMatches(pattern: "_[^/]*_", replaceWith: "[^/]*")
                if path.matches(regex) {
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

    // todo: this response should be configurable somehow like the header
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
