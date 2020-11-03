//
//  ViewModel.swift
//  GithubSearch
//
//  Created by colbylim on 2020/11/03.
//

import Foundation
import RxSwift
import RxCocoa

enum SearchViewStateType {
    case ok
    case message(message: String?)
    case error(message: String?)
}

class SearchViewModel: ViewStateStreamModel<SearchViewStateType> {
    private var page: Int = 1
    private var isEnd: Bool = false
    
    let repositories = BehaviorRelay<[String]>(value: [])
    let searchText = BehaviorRelay<String>(value: "")
    
    override init() {
        super.init()

        searchText.asObservable()
            .subscribe(onNext: { [weak self] t in
                self?.search(t)
            })
            .disposed(by: disposeBag)
    }
    
    func search(_ text: String) {
        page = 1
        isEnd = false
        
        if !repositories.value.isEmpty {
            repositories.accept([])
        }
        
        fetch(text)
    }
    
    func fetchNextPage(_ row: Int) {
        if row == repositories.value.count - 1 {
            fetch(searchText.value)
        }
    }
    
    func fetch(_ text: String) {
        if isEnd == true {
            return
        }

        // TODO: API CALL
        var temp = [String]()
        for i in 0 ..< 10 {
            temp.append("TEST\(i)")
        }
        repositories.accept(temp)
        isEnd = true
    }
}
