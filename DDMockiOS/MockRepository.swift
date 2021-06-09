import Foundation

// maybe protocol?
internal class MockRepository {

    /// map
    private var mockEntries: [String: MockEntry] = [:]

    // should be a "get or insert" function in the map
    func createMockEntry(url: URL) {

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

    /// todo: doc
    internal func hasEntry(path: String, method: String) -> Bool {

        // idk what the idea of this map function useRealAPI

        // get the entry
        // todo: cache
        guard
            let entry = getMockEntry(path: path, method: method) else {

            return false
        }

        // entry can override this value itself
        return entry.useRealAPI()
    }

    /**
     get the mock entry, respecting strict mode, "isTest"
     */
    internal func getEntry(
        path: String,
        method: String,
        strict: Bool,
        onMissing: (_ path: String?) -> Void) -> MockEntry? {

        // get the entry
        let entry = getMockEntry(path: path, method: "") // todo

        // If strict mode is enabled, a missing entry is an error. Call handler.
        // this will still fall through
        if strict && entry == nil {
            onMissing(path)
        }
        // Here we log the entries so that clients (like a unit test) can verify a call was made.
        // todo: this is guarded by isTest flag so doesn't apply to tests
        // todo: remove istest flag

        return entry
    }

    /**
     this returns an entry simply by path
     need to include the method to get it in a way that makes sense
     */
    private func getMockEntry(path: String, method: String) -> MockEntry? {
        let fullPath = path.replacingRegexMatches(
            pattern: "^/",
            replaceWith: "") + "/" + method.lowercased()

        // return an entry for either a non-wildcard or wildcard path
        return mockEntries[fullPath] ?? getRegexEntry(path: fullPath)
    }


    // todo: simplify this a little

    private func getRegexEntry(path: String) -> MockEntry? {
        //
        var matches: [MockEntry] = []

        // iterate through mock entry keys (what are these)
        //
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
        guard matches.count <= 1 else {
            fatalError("Fatal Error: Multiple matches for regex entry.")
        }
        return matches.first
    }
}
