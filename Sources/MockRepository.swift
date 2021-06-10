import Foundation

/**
 Internal storage wrapper for mock entries.
 To reinitialise a list of mocks, just create a new MockRepository
 and drop the old one.
 */
internal class MockRepository {

    /// map storage of mock entries
    private let mockEntries: [String: MockEntry]

    /**
     iterate through files & populate the mocks
     */
    init(path: String, fm: FileManager) {
        var entries: [String: MockEntry] = [:]

        // load mock files
        fm
            .enumerator(atPath: path)?
            .forEach {

                guard
                    let path = $0 as? String,
                    let url = URL(string: path) else {

                    return
                }
                guard
                    // todo: new file schema
                    url.pathExtension == "json" else {

                return
            }

                // get the key
                let key = url.deletingLastPathComponent().absoluteString

                // put into the dictionary
                if var entry = entries[key] {
                   // add the mock to the existing file list for this entry
                    entry.files.append(url.path)
                }
                else {
                    // create a new entry
                    entries[key] = MockEntry(path: key, files: [url.path])
                }
            }

        self.mockEntries = entries
    }

    /// todo: doc
    func hasEntry(path: String, method: String) -> Bool {

        // idk what the idea of this map function useRealAPI

        // get the entry
        // todo: cache
        guard
            let entry = getMockEntry(path: path, method: method) else {

            return false
        }

        // entry can override this value itself
        return !entry.useRealAPI()
    }

    /**
     get the mock entry, respecting strict mode
     */
    func getEntry(
        path: String,
        method: String,
        strict: Bool,
        onMissing: (_ path: String?) -> Void) -> MockEntry? {

        // get the entry
        let entry = getMockEntry(path: path, method: method)

        // If strict mode is enabled, a missing entry is an error. Call handler.
        // this will still fall through
        if strict && entry == nil {
            onMissing(path)
        }

        return entry
    }

    /*
     todo: consolidate mock entry types, add regex to mock entry itself
     If regex entries were included in the same ds
     hasMockEntry would look much simpler
     and would not require retreiving the item
     */

    /**
     this returns an entry simply by path
     need to include the method to get it in a way that makes sense
     */
    private func getMockEntry(path: String, method: String) -> MockEntry? {
        let matches = path.replacingRegexMatches(
            pattern: "^/",
            replaceWith: "")
        // method string is always lowercased
        let fullPath = "\(matches)/\(method.lowercased())/"

        // return an entry for either a non-wildcard or wildcard path
        return mockEntries[fullPath] ?? getRegexEntry(path: fullPath)
    }

    // todo: simplify this a little

    private func getRegexEntry(path: String) -> MockEntry? {
        //
        var matches: [MockEntry] = []

        // iterate through mock entry keys (what are these)
        // these are the path without the filename, including method
        // whatever we're looking for should be in the value
        // to keep this lookup O(1)
        for key in mockEntries.keys {

            // if key contains _
            // this is to test if there is a wildcard to replace
            // todo: mock entry should have its own regex
            // shouldn't have to recompile for every request
            if (key.contains("_")) {

                // replace matches of the wildcard with ...
                let regex = key.replacingRegexMatches(pattern: "_[^/]*_", replaceWith: "[^/]*")

                // 
                if path.matches(regex) {

                    if let match = mockEntries[key] {
                        matches.append(match)
                    }
                }
            }
        }
        // maximum of 1 match or panic
        guard matches.count <= 1 else {
            fatalError("Fatal Error: Multiple matches for regex entry.")
        }
        // return first or none
        return matches.first
    }

    /**
     Create a mock entry for the given url and returns it.
     If a mock entry exists for this path it returns a new entry with the
     new path added.
     // todo: can we do this all at once?
     */
}
