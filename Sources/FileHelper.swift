// todo: caching of response objects
// should know what the path is from the entry
final class FileHelper {

    static func getMockData(_ entry: MockEntry) -> Data? {

        let file = entry.getSelectedFile()

        let path = Bundle.main.resourcePath! + Constants.mockDirectory

        let url = URL(fileURLWithPath: "\(path)/\(file)")

        return try? Data(
            contentsOf: url,
            options: .mappedIfSafe)
    }

    static func getHeaders(url: URL) -> [String: String]? {
        let decoder = JSONDecoder()

        guard
            let data = getHeadersData(file: url.absoluteString)
            else { return nil }

        return try? decoder.decode([String: String].self, from: data)
    }

    // todo: potentially move json here too

    static func getHeadersData(file: String) -> Data? {
        let path = Bundle.main.resourcePath! + Constants.mockDirectory
        let url = URL(fileURLWithPath: "\(path)/\(file)")

        return try? Data(
            contentsOf: url,
            options: .mappedIfSafe)
    }
}
