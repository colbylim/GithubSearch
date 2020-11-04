//
//  APIProtocols.swift
//  GithubSearch
//
//  Created by 임현준 on 2020/11/03.
//

import Alamofire

typealias HttpMethod = HTTPMethod
typealias Params = Parameters
typealias HttpHeaders = HTTPHeaders

// MARK: - Base API Protocol
protocol BaseAPIProtocol {
    associatedtype ResponseType
    
    var baseURL: String { get }
    var method: HttpMethod { get }
    var path: APIUrls { get }
    var headers: HttpHeaders? { get }
}

extension BaseAPIProtocol {

    var baseURL: String {
        return "https://developer.github.com/v3/"
    }
}

// MARK: - BaseRequestProtocol
protocol BaseRequestProtocol: BaseAPIProtocol, URLRequestConvertible {
    var parameters: Params? { get }
    var encoding: ParameterEncoding { get }
}

extension BaseRequestProtocol {
    
    var encoding: ParameterEncoding {
        if method == .get {
            return URLEncoding.default
        } else {
            return JSONEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlRequest = try URLRequest(url: URL(string: "\(baseURL)\(path.rawValue)")!,
                                        method: method,
                                        headers: headers)
        urlRequest.timeoutInterval = TimeInterval(5)
        
        if let params = parameters {
            urlRequest = try encoding.encode(urlRequest, with: params)
        }
        
        return urlRequest
    }
}
