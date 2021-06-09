import Foundation

// ?
enum EntrySetting {
    case notFound
    case mocked
    case useRealAPI
}

// implements URLProtocol for some reason
public class DDMockProtocolClass: URLProtocol {

    // convenience function
    public static func protocolClass(_ protocolClasses: [AnyClass])-> [AnyClass] {
        var protocolClasses = protocolClasses
        protocolClasses.insert(DDMockProtocolClass.self, at: 0)
        return protocolClasses
    }

    // initiailise: note this is mutating config and not returning
    // todo: remove
    public static func initialise(config: inout URLSessionConfiguration) {
        var protocolClasses = config.protocolClasses ?? []
        protocolClasses.insert(DDMockProtocolClass.self, at: 0)
        config.protocolClasses = protocolClasses
    }

    // todo: what is this switch
    override public class func canInit(with request: URLRequest) -> Bool {
        switch DDMock.shared.hasMockEntry(request: request) {
        case .mocked:                       return true
        case .notFound, .useRealAPI:        return false
        }
    }

    // canonical request does nothing atm
    // todo: what is this
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {

        // fetch item
        if
            let path = request.url?.path,
            let method = request.httpMethod {

            // todo: singleton
            if let entry = DDMock.shared.getMockEntry(
                path: path,
                method: method) {

                // create mock response
                let data: Data? = DDMock.shared.getData(entry)

                // header dictionary
                var headers: [String: String] = [:]

                // content type
                // todo
                headers["Content-Type"] = "application/json"
                if let data = data {
                    headers["Content-Length"] = "\(data.count)"
                }

                // create response
                // todo: dynamically
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: entry.getStatusCode(),
                    httpVersion: "HTTP/1.1",
                    headerFields: headers)!

                // Simulate response time
                // todo: check thread model
                Thread.sleep(forTimeInterval: TimeInterval(entry.getResponseTime() / 1000))

                // send response
                client!.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed)

                // send response data if available
                if let data = data {
                    client!.urlProtocol(self, didLoad: data)
                }

                // finish loading
                client!.urlProtocolDidFinishLoading(self)
            }
        }
    }

    override public func stopLoading() {
        // nothing is ever in flight so always do nothing
    }
}
