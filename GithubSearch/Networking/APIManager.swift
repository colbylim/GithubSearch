//
//  APIManager.swift
//  GithubSearch
//
//  Created by colbylim on 2020/11/03.
//

import Foundation
import Alamofire
import RxSwift

struct APIManager {
        
    static func call<T, V>(_ request: T) -> Observable<V>
        where T: BaseRequestProtocol, V: Codable, T.ResponseType == V {
        return Observable<V>.create { observer in
            let request = AF.request(request)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data) :
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .iso8601
                            let model : V = try decoder.decode(V.self, from: data)
                            observer.onNext(model)
                        } catch let error {
                            observer.onError(error)
                        }

                    case .failure(let error):
                        observer.onError(error)
                    }

                    observer.onCompleted()
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
