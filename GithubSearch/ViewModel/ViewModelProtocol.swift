//
//  ViewModelProtocol.swift
//  GithubSearch
//
//  Created by colbylim on 2020/11/03.
//

import Foundation
import RxSwift

protocol ViewStateStreamProtocol {
    associatedtype T
    var viewState: T? { get set }
    var viewStateStream: PublishSubject<T> { get }
}

class ViewStateStreamModel<T>: NSObject, ViewStateStreamProtocol {
    
    let disposeBag = DisposeBag()
    let viewStateStream = PublishSubject<T>()
    var viewState: T? {
        didSet {
            if let _state = viewState {
                viewStateStream.onNext(_state)
            }
        }
    }
}

