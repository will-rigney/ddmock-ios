import Foundation

// ?
enum EntrySetting {
    case notFound
    case mocked
    case useRealAPI
}

// implements URLProtocol for some reason
public class DDMockURLProtocolClass: URLProtocol {

    // convenience function
    // todo: this api doesn't make sense
    public static func insertProtocolClass(_ protocolClasses: [AnyClass])-> [AnyClass] {
        var protocolClasses = protocolClasses
        protocolClasses.insert(
            DDMockURLProtocolClass.self,
            at: 0)
        return protocolClasses
    }

    // todo: what is this switch
    override public class func canInit(with request: URLRequest) -> Bool {
        // this canInit is the only place that calls hasMockEntry
        guard
            let path = request.url?.path,
            let method = request.httpMethod else {
            return false
        }

        switch DDMock.shared.hasMockEntryByPath(path: path, method: method) {
        case .mocked:                       return true
        case .notFound, .useRealAPI:        return false
        }
    }

    // canonical request does nothing atm
    // todo: what is this
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // todo: allow headers to be cnfigurable
    func getMockHeaders(contentLength: Int?) -> [String: String] {
        var headers: [String: String] = [:]
        // content type
        // todo: get these from somewhere
        headers["Content-Type"] = "application/json"
        if let contentLength = contentLength {
            headers["Content-Length"] = "\(contentLength)"
        }
        return headers
    }

    func createMockResponse(
        url: URL,
        statusCode: Int,
        headers: [String: String]) -> HTTPURLResponse? {

        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers)
    }

    override public func startLoading() {
        // copy bang to local scope
        let client = self.client!

        // fetch item
        guard
            let path = request.url?.path,
            let method = request.httpMethod,
            let url = request.url else {

            return
        }

        // todo: remove singleton
        // this is the only thing that is used i think
        guard let entry = DDMock.shared.getMockEntryByPath(
            path: path,
            method: method) else {

            return
        }

        // create mock response
        // todo: check in what case is this nil
        // todo: also remove singleton
        let data: Data? = DDMock.shared.getData(entry)

        // header dictionary
        let headers = getMockHeaders(contentLength: data?.count)

        // create response
        guard let response = createMockResponse(
            url: url,
            statusCode: entry.getStatusCode(),
            headers: headers) else {

            return
        }

        // Simulate response time
        // todo: check threading
        let time = TimeInterval(entry.getResponseTime() / 1000)
        Thread.sleep(forTimeInterval: time)

        // send response
        client.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed)

        // send response data if available
        if let data = data {
            client.urlProtocol(self, didLoad: data)
        }

        // finish loading
        client.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() {
        // nothing is ever in flight so always do nothing
    }
}
