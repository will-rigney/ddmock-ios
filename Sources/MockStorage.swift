/**
 Class to wrap storage for mocks with nice get methods
 */
final class MockStorage {
    private let entries: [String: MockEntry]

    init(entries: [String: MockEntry]) {
        self.entries = entries
    }

    /**
     get either the value for the key if it exists,
     or a regex entry if there is a match,
     or nil
     */
    func getEntry(path: String) -> MockEntry? {
        return entries[path] ?? getRegexEntry(path: path)
    }

    /**
     get a possible regex entry map
     iterates through the keys, for every key with a '_'
     turns it into a regex and matches against path
     panics on > 1 match
     */
    private func getRegexEntry(path: String) -> MockEntry? {
        // empty array
        var matches: [MockEntry] = []

        // iterate through mock entry keys (what are these?)
        // these are the path without the filename, including method
        // whatever we're looking for should be in the value
        // to keep this lookup O(1)
        for key in entries.keys {

            // if key contains _
            // this is to test if there is a wildcard to replace
            // todo: mock entry should have its own regex
            // shouldn't have to recompile for every request
            if (key.contains("_")) {

                // replace matches of the wildcard with ...
                // this matches _[^/]*_ in the path
                // and replaces it with the string literal "_[^/]*_
                // this lets us use it as the string matcher later
                let regex = key.replacingRegexMatches(
                    pattern: "_[^/]*_",
                    replaceWith: "[^/]*")

                // try and match the path with the new regex string
                if path.matches(regex) {

                    if let match = entries[key] {
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
}
