import Foundation

/**
 This is the main DDMock entry point.

 */
public final class DDMock {

    // todo: make this more obvious or configurable
    /// path under resources directory
    private let mockDirectory = "/mockfiles"

    /// enforces mocks only and no API fall-through
    internal var strict: Bool = false

    // todo: this should be thread safe
    // and have a max size
    /// chronological order of paths
    private(set) var matchedPaths: [String] = []

    /// needed for singleton
    private init() {}

    /**
     Assignable handler invoked when a mock is not present in strict mode.
     By default this is a panic, strict mode users may want
     to configure something more graceful.
     */
    public var onMissingMock: (_ path: String?) -> Void = { path in
        fatalError("missing stub for path: \(path ?? "<unknown>")")
    }

    // todo: remove the singleton if possible, require a single instance
    /// singleton instance of DDMock
    public static let shared = DDMock()

    /// repository for storing mocks
    private let repository = MockRepository()

    /**
     Initialise DDMock library
     This must be called on the DDMock.shared singleton
     by the client before DDMock can be used.
     */
    public func initialise(strict: Bool = false) {
       // todo: kinda not great maybe
        self.strict = strict

        // todo: resource path
        let path = Bundle.main.resourcePath! + mockDirectory

        // parse the files in the mock directory
        readMockFiles(path: path, fm: FileManager.default)
    }

    /**
     iterate through files & populate the mocks
     todo: move out the "create mock entry" call
     */
    private func readMockFiles(path: String, fm: FileManager) {
        fm
            .enumerator(atPath: path)?
            .forEach {
                if
                    let e = $0 as? String,
                    let url = URL(string: e),
                    url.pathExtension == "json" {

                    // does it open the file? no
                    // url is actually the path of the file (very strange)
                    repository.createMockEntry(url: url)
                }
            }
    }

    func hasEntry(path: String, method: String) -> Bool {
        return repository.hasEntry(path: path, method: method)
    }

    func getEntry(path: String, method: String) -> MockEntry? {
        // get the entry
        guard
            let entry = repository.getEntry(
                path: path,
                method: method) else {

            return nil
        }

        // add to history
        matchedPaths.append(path)

        // return the entry
        return entry
    }

    /// reset the history
    public func clearHistory() {
        matchedPaths.removeAll()
    }

    // todo: this response should be configurable somehow like the header
    // todo: hide this
    func getData(_ entry: MockEntry) -> Data? {

        var data: Data? = nil
        let f = entry.files[entry.getSelectedFile()]

        let docsPath = Bundle.main.resourcePath! + mockDirectory
        let url = URL(fileURLWithPath: "\(docsPath)/\(f)")

        data = try? Data(
            contentsOf: url,
            options: .mappedIfSafe)

        return data
    }
}
