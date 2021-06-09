import Foundation

// todo: maybe think about replacing this with a builder
// todo: move this out of amorphous 'helper'
internal class ResponseHelper {

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

}
