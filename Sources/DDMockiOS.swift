import Foundation

/**
 This is the main DDMock entry point.

 */
public final class DDMock {

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
    private var repository: MockRepository!

    /**
     Initialise DDMock library
     This must be called on the DDMock.shared singleton
     by the client before DDMock can be used.
     */
    public func initialise(strict: Bool = false) {
       // todo: more consistent configuration
        self.strict = strict

        // todo: resource path
        let path = Bundle.main.resourcePath! + Constants.mockDirectory

        // load the files in the mock directory
        repository = MockRepository(path: path, fm: FileManager.default)
    }

    /**
     Check if an entry exists for a given path
     */
    func hasEntry(path: String, method: String) -> Bool {
        return repository.hasEntry(path: path, method: method)
    }

    /**
     Return the entry for a given path, if one exists
     */
    func getEntry(path: String, method: String) -> MockEntry? {
        // get the entry
        guard
            let entry = repository.getEntry(
                path: path,
                method: method,
                strict: strict,
                onMissing: onMissingMock) else {

            return nil
        }

        // add to history
        matchedPaths.append(path)

        // return the entry
        return entry
    }

    /**
     reset the history
     */
    public func clearHistory() {
        matchedPaths.removeAll()
    }
}
