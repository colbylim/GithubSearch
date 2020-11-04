//
//  SearchAPI.swift
//  GithubSearch
//
//  Created by 임현준 on 2020/11/03.
//

import Foundation

enum SearchAPI: BaseRequestProtocol {

    typealias ResponseType = GithubData
    
    case get(query: String, page: Int)
    
    var method: HttpMethod {
        switch self {
        case .get: return .get
        }
    }
    
    var path: APIUrls {
        return .repositories
    }
    
    var headers: HttpHeaders? {
        return nil
    }
    
    var parameters: Params? {
        switch self {
        case let .get(query, page):
            return ["q": query,
                    "page": page]
        }
    }
}
