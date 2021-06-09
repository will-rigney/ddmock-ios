import Foundation

/**
 Implementation of NSURLProtocol used to intercept requests.
 Needs to be inserted into the list protocal classes ...

 */
public class DDMockURLProtocolClass: URLProtocol {

    /**
     convenience function to insert
     todo: more detail and change this interface somehow, check what others do
     */
    public static func insertProtocolClass(
        _ protocolClasses: [AnyClass])-> [AnyClass] {

        var protocolClasses = protocolClasses
        protocolClasses.insert(
            DDMockURLProtocolClass.self,
            at: 0)
        return protocolClasses
    }

    // todo: is this called for every request? is the mock retreived 2ce?
    ///
    public override class func canInit(with task: URLSessionTask) -> Bool {
        guard
            let req = task.currentRequest,
            let path = req.url?.path,
            let method = req.httpMethod else {

            return false
        }

        // this canInit is the only place that calls hasMockEntry
        // this actually retreives the mock as part of its execution
        // todo: caching
        return DDMock.shared.hasEntry(path: path, method: method)
    }

    /**
     The canonical version of a request is used to lookup objects in the URL cache.
     This process performs equality checks between URLRequest instances.

     This is an abstract class by default.
     */
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // todo: move logic to correct lifecycle point
    /**
     this is where everything happens
     */
    override public func startLoading() {

        // fetch item
        guard
            let path = request.url?.path,
            let method = request.httpMethod,
            let url = request.url else {

            return
        }

        // note: remove singleton could just mean restrict its usage to
        // within the public interface boundary or make it more explicit

        // todo: remove singleton
        guard let entry = DDMock.shared.getEntry(
            path: path,
            method: method) else {

            return
        }

        // create mock response
        // todo: check in what case could this be nil
        // todo: also remove singleton
        let data: Data? = DDMock.shared.getData(entry)

        // header dictionary
        // todo: more configuration
        let headers = ResponseHelper.getMockHeaders(contentLength: data?.count)

        // get status code
        let statusCode = entry.getStatusCode()

        // create response
        guard let response = ResponseHelper.createMockResponse(
            url: url,
            statusCode: statusCode,
            headers: headers) else {

            return
        }

        // simulate response time
        // todo: use timer instead of sleep
        let time = TimeInterval(entry.getResponseTime() / 1000)
        Thread.sleep(forTimeInterval: time)

        // finally send the mock response to the client
        let client = self.client!
        sendMockResponse(client: client, response: response, data: data)
    }

    private func sendMockResponse(
        client: URLProtocolClient,
        response: HTTPURLResponse,
        data: Data?) {

        // send response
        client.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed)

        // send response data if available
        if let data = data {
            client.urlProtocol(
                self,
                didLoad: data)
        }

        // finish loading
        client.urlProtocolDidFinishLoading(self)
    }

}
