import Foundation

/**
 Internal storage wrapper for mock entries.
 To reinitialise a list of mocks, just create a new MockRepository
 and drop the old one.
 */
final class MockRepository {

    /// map storage of mock entries
    private let storage: MockStorage

    /**
     iterate through files & populate the mocks
     */
    init(path: String, fm: FileManager) {

        var entries: [String: MockEntry] = [:]
        var headers: [String: [String: String]] = [:]

        // load mock files
        fm
            .enumerator(atPath: path)?
            .forEach {

                guard
                    let path = $0 as? String,
                    let url = URL(string: path) else {

                    return
                }
                // todo: next step is to alllow arbitrary types
                // this might cause an issue with string slices in python
                guard url.pathExtension == "json" else {
                    return
                }

                // get the key
                let key = url.deletingLastPathComponent().absoluteString

                // if this is a file describing headers
                if url.lastPathComponent == "h.json" {
                    // actually parse the file here!
                    // need a real url
                    if
                        let result = FileHelper.getHeaders(url: url) {
                        // add the headers to the entry
                        // definitely much more pythonic ways to do this
                        headers[key] = result
                    }

                    return
                }

                // put into the dictionary
                if var entry = entries[key] {
                   // add the mock to the existing file list for this entry
                    entry.files.append(url)
                }
                else {
                    // create a new entry
                    let entry = MockEntry(
                        path: key,
                        files: [url])
                    entries[key] = entry
                }
            }

        // add all of the headers to the entries
        headers.forEach { (item, value) in
            entries[item]?.headers = value
        }

        self.storage = MockStorage(entries: entries)
    }

    /// todo: doc
    func hasEntry(path: String, method: String) -> Bool {
        // get the key
        let key = ResponseHelper.getKeyFromPath(path: path, method: method)
        // return an entry for either a non-wildcard or wildcard path
        // todo: slightly confusing names
        guard
            let entry = storage.getEntry(path: key) else {
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
        let key = ResponseHelper.getKeyFromPath(path: path, method: method)

        // return an entry for either a non-wildcard or wildcard path
        let entry = storage.getEntry(path: key)

        // If strict mode is enabled, a missing entry is an error. Call handler.
        // this will still fall through and return nil
        if strict && entry == nil {
            onMissing(path)
        }

        return entry
    }
}
