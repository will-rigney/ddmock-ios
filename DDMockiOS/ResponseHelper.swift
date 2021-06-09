import Foundation

// todo: maybe think about replacing this with a builder
// todo: move this out of amorphous 'helper'
internal struct ResponseHelper {

    // todo: allow headers to be configurable
    static func getMockHeaders(contentLength: Int?) -> [String: String] {
        var headers: [String: String] = [:]
        // content type
        // todo: get these from somewhere
        headers["Content-Type"] = "application/json"
        if let contentLength = contentLength {
            headers["Content-Length"] = "\(contentLength)"
        }
        return headers
    }

    static func createMockResponse(
        url: URL,
        statusCode: Int,
        headers: [String: String]) -> HTTPURLResponse? {

        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers)
    }

    // todo: this response should be configurable somehow like the header
    // todo: hide this
    // should know what the path is from the entry
    static func getData(_ entry: MockEntry) -> Data? {

        let file = entry.getSelectedFile()

        // get the path
        // todo: isn't this encoded in the entry?
        let path = entry.path

        let url = URL(fileURLWithPath: "\(path)/\(file)")

        return try? Data(
            contentsOf: url,
            options: .mappedIfSafe)

    }

    ///
    static func sendMockResponse(
        urlProtocol: URLProtocol,
        client: URLProtocolClient,
        response: HTTPURLResponse,
        data: Data?) {

        // send response
        client.urlProtocol(
            urlProtocol,
            didReceive: response,
            cacheStoragePolicy: .notAllowed)

        // send response data if available
        if let data = data {
            client.urlProtocol(
                urlProtocol,
                didLoad: data)
        }

        // finish loading
        client.urlProtocolDidFinishLoading(urlProtocol)
    }
}
