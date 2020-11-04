//
//  SearchViewController.swift
//  GithubSearch
//
//  Created by colbylim on 2020/11/03.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var emptyView: UIView!
    
    let disposeBag = DisposeBag()
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

    func configure() {
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableView.automaticDimension
        
        // view tap, 키패드 searchButton 클릭시 키패드 숨김
        tableView.keyboardDismissMode = .onDrag
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
                
        Observable.merge(tap.rx.event.map({ _ in }).asObservable(),
                         searchBar.rx.searchButtonClicked.asObservable())
            .bind(to: resignFirstResponder)
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .skip(1)
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest({ Observable.just($0) })
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        // paging 처리
        tableView.rx.willDisplayCell
            .subscribe { [weak self] (_, indexPath) in
                self?.viewModel.fetchNextPage(indexPath.row)
            }.disposed(by: disposeBag)
                
//        UITableViewAlertForLayoutOutsideViewHierarchy warning이 발생함
//        해당 이슈는 RxSwift의 이슈로 https://github.com/ReactiveX/RxSwift/pull/2076에 보고되어 있음.
//        임시방편으로 DispatchQueue.main.async안에서 바인딩하여 수정함
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewModel.repositories.asObservable()
                .bind(to: self.tableView.rx.items(cellIdentifier: "TableViewCell", cellType: TableViewCell.self)) { (_, element, cell) in
                    cell.configure(name: element.name, desc: element.itemDescription)
                }.disposed(by: self.disposeBag)
        }
        
        viewModel.hiddenEmptyView
            .bind(to: emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.viewStateStream.subscribe(onNext: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .loading(isHidden):
                self.loadingView.isHidden = isHidden
                
            case let .message(message):
                self.showAlert(message)
                
            case let .error(message):
                self.showAlert(message)
                
            case .ok: break
            }
        }).disposed(by: disposeBag)
    }
    
    private func showAlert(_ messages: String?) {
        guard let messages = messages else { return }
        
        let alert = UIAlertController(title: "", message: messages, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private var resignFirstResponder: AnyObserver<Void> {
        return Binder(self) { me, _ in
            me.searchBar.resignFirstResponder()
        }.asObserver()
    }
}
