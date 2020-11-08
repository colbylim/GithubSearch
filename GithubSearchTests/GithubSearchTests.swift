//
//  GithubSearchTests.swift
//  GithubSearchTests
//
//  Created by colbylim on 2020/11/03.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import GithubSearch

class GithubSearchTests: XCTestCase {

    var disposeBag: DisposeBag!
    var viewModel: SearchViewModel!
    var scheduler: TestScheduler!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        disposeBag = DisposeBag()
        viewModel = SearchViewModel()
        scheduler = TestScheduler(initialClock: 0, resolution: 0.001)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let promise = expectation(description: "testExample error")

        let list = PublishSubject<[Repository]>()
        viewModel.repositories.asObservable()
            .bind(to: list).disposed(by: disposeBag)

        list.subscribe { (doc) in
            // 최초 검색시 30개가 나오므로 30개가 아니면 실패
            if doc.count == 30 {
                promise.fulfill()
            } else {
                XCTFail("testExample error")
            }
        } onError: { (_) in
            XCTFail("testExample error")
        }.disposed(by: disposeBag)
        
        scheduler
            .createColdObservable([.next(10, "github")])
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        scheduler.start()

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
