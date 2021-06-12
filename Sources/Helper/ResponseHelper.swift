import Foundation

//struct MockResponse {
//    let headers: [String: String]
//    // other elements a response might have
//    fileprivate init(
//        headers: [String: String]) {
//
//        self.headers = headers
//    }
//}
//
//fileprivate class MockResponseBuilder {
//    private var headers: [String: String] = [:]
//
//    func addHeaders(contentLength: Int?) {
//        self.headers = ResponseHelper.getMockHeaders(contentLength: contentLength)
//    }
//
//    func build() -> MockResponse {
//        return MockResponse(headers: headers)
//    }
//}
/*
 basically we want to have some response type, and we want to both create it
 and send it
 
 */

// todo: maybe think about replacing this with a builder
// todo: move this out of amorphous 'helper'
class ResponseHelper {

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

    // this maybe doesn't belong here
    static func getKeyFromPath(path: String, method: String) -> String {
        let matches = path.replacingRegexMatches(
            pattern: "^/",
            replaceWith: "")
        // method string is always lowercased
        return "\(matches)/\(method.lowercased())/"
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

//        todo: file should just be a string of the directory (?)
        let path = Bundle.main.resourcePath! + Constants.mockDirectory

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
