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
    // yes it is
    public override class func canInit(with task: URLSessionTask) -> Bool {

        if DDMock.shared.strict { return true }

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
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // todo: move logic to correct lifecycle point
    /**
     this is where everything happens
     */
    public override func startLoading() {

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

        // get response data
        // todo: check in what case could this be nil
        let data: Data? = ResponseHelper.getData(entry)

        // header dictionary
        var headers = ResponseHelper.getMockHeaders(contentLength: data?.count)

        // if the entry has headers merge those too
        if let entryHeaders = entry.getHeaders() {
            headers.merge(
                entryHeaders,
                uniquingKeysWith: {(_, newValue) in newValue})
        }

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
        let time = TimeInterval(Float(entry.getResponseTime()) / 1000.0)

        // just use regular timer to async return the response
        // todo: this isn't working correctly
        Timer.scheduledTimer(
            withTimeInterval: time,
            repeats: false,
            block:
                { timer in
                    // finally send the mock response to the client
                    ResponseHelper.sendMockResponse(
                        urlProtocol: self,
                        client: self.client!,
                        response: response,
                        data: data)
                })
    }

    /// Required override of abstract prototype, does nothing.
    public override func stopLoading() {
        // nothing actually loading
    }
}
