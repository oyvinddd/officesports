//
//  URLRequestBuilder.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 05/10/2022.
//

import Foundation

// Authorization header field
private let kHeaderAuthorization = "Authorization"
private let kHeaderContentType = "Content-Type"

final class URLRequestBuilder {
    
    var method: String
    
    var url: String
    
    var headers: [String: String] = [:]
    
    var params: [String: String]?
    
    var token: String?
    
    var body: Data?
    
    init(_ method: String, _ url: String) {
        self.method = method.uppercased()
        self.url = url
        // set default content-type header for all requests
        headers[kHeaderContentType] = "application/json"
    }
    
    @discardableResult func set(headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }
    
    @discardableResult func set(params: [String: String]?) -> Self {
        self.params = params
        return self
    }
    
    @discardableResult func set(body: Data?) -> Self {
        self.body = body
        return self
    }
    
    @discardableResult func set(token: String?) -> Self {
        if let token = token {
            headers[kHeaderAuthorization] = "Bearer \(token)"
        }
        return self
    }
    
    func build() -> URLRequest {
        let url = URL(string: url)!
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        // add query parameters to the end of the url
        if let params = params, !params.isEmpty {
            comps.queryItems = params.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        var request = URLRequest(url: comps.url!)
        request.httpMethod = method
        // add all headers
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpBody = body
        return request
    }
}
