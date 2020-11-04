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
    case loading(isHidden: Bool)
    case message(message: String?)
    case error(message: String?)
}

class SearchViewModel: ViewStateStreamModel<SearchViewStateType> {
    private var page: Int = 1
    private var isEnd: Bool = false
    
    let repositories = BehaviorRelay<[Repository]>(value: [])
    let searchText = BehaviorRelay<String>(value: "")
    let hiddenEmptyView = BehaviorRelay<Bool>(value: true)
    
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
        if text.isEmpty == true {
            hiddenEmptyView.accept(true)
            return
        }
        
        if isEnd == true {
            return
        }

        viewState = .loading(isHidden: false)
        
        APIManager.call(SearchAPI.get(query: text, page: page))
            .subscribe { [weak self] (res) in
                guard let self = self else { return }
                self.viewState = .loading(isHidden: true)
                
                if self.page == 1 {
                    self.hiddenEmptyView.accept(res.totalCount == 0 ? false : true)
                }
                
                self.page += 1
                if self.repositories.value.count + res.items.count == res.totalCount {
                    self.isEnd = true
                }
                
                if !res.items.isEmpty {
                    self.repositories.accept(self.repositories.value + res.items)
                }
            } onError: { [weak self] (error) in
                self?.viewState = .loading(isHidden: true)
                
                if let code = error.asAFError?.responseCode, code == 403 {
                    self?.viewState = .error(message: "API rate limit exceeded")
                    return
                }
                
                self?.viewState = .error(message: error.localizedDescription)
            }.disposed(by: disposeBag)
    }
}
