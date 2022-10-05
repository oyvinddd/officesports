//
//  URLSession+Decodable.swift
//  OfficeSports
//
//  Created by Øyvind Hauge on 05/10/2022.
//

import Foundation

extension URLSession {
    
    func dataTask<T: Decodable>(with request: URLRequest, decodable: T.Type, result: @escaping OSResultBlock<T>) -> URLSessionDataTask {
        return dataTask(with: loggedRequest(request)) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    result(.failure(error))
                    return
                }
                guard let urlResponse = response as? HTTPURLResponse, let data = data else {
                    result(.failure(OSError.unknown))
                    return
                }
                guard 200 ..< 300 ~= urlResponse.statusCode else {
                    print("status code was \(urlResponse.statusCode), but expected 2xx")
                    do {
                        let error = try JSONDecoder().decode(OSError.self, from: data)
                        result(.failure(error))
                    } catch {
                        result(.failure(OSError.unknown))
                    }
                    return
                }
                do {
                    let entity = try JSONDecoder().decode(T.self, from: data)
                    result(.success(entity))
                } catch {
                    result(.failure(OSError.decodingFailed))
                }
            }
        }
    }
    
    private func loggedRequest(_ request: URLRequest) -> URLRequest {
        if let url = request.url, let method = request.httpMethod {
            var headersString = ""
            if let headers = request.allHTTPHeaderFields {
                for header in headers {
                    headersString += "[\(header.key): \(header.value)]"
                }
            }
            print("[🐶][\(method)][\(url.absoluteString)]\(headersString)")
        }
        return request
    }
}
