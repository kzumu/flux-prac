//
//  SignInController.swift
//  flux-prac
//
//  Created by 下村一将 on 2018/01/19.
//  Copyright © 2018年 kazu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate struct State {
	enum LoginButtonState {
		case enable
		case disable
	}

	enum NetworkState {
		case nothing
		case requesting
		case error(Error)
	}

	var loginButtonState: LoginButtonState
	var networkState: NetworkState
}

fileprivate enum Action {
	case requested
	case errorOccured(error: Error)
}

fileprivate class Store {
	static let initialState = State(loginButtonState: .disable, networkState: .nothing)

	var states: Observable<State> = .empty()
	var currentState: State {
		return try! stateCache.value()
	}

	private let stateCache: BehaviorSubject<State> = BehaviorSubject(value: Store.initialState)

	init(inputs: Observable<View.Event>) {
		states = inputs
			.flatMap { event in ActionCreator.action(for: event, store: self) }
			.scan(Store.initialState, accumulator: Store.reduce)
			.multicast(stateCache)
			.refCount()
	}

	static func reduce(state: State, action: Action) -> State {
		var nextState = state

		switch action {
		case .requested:
			nextState.networkState = .requesting
		case let .errorOccured(error):
			nextState.networkState = .error(error)
		}

		return nextState
	}
}

fileprivate class ActionCreator {
	static func action(for event: View.Event, store: Store) -> Observable<Action> {
		switch event {
		case .signInButtonTapped:
			print("will request")
			return Observable.just(Action.requested)
		}
	}
}

typealias View = SignInViewController
final class SignInViewController: UIViewController {
	fileprivate enum Event {
		case signInButtonTapped
	}

	@IBOutlet weak var userIdField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var signInButton: UIButton!

	private let store: Store
	private let events = PublishSubject<Event>()
	let disposeBag = DisposeBag()

	init() {
		store = Store(inputs: events)
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		bind()
	}

	required init?(coder aDecoder: NSCoder) {
		store = Store(inputs: events)
		super.init(coder: aDecoder)
	}

	private func bind() {
		store.states
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: {
				self.render(state: $0)
			})
			.disposed(by: disposeBag)


		Observable.combineLatest(userIdField.rx.text, passwordField.rx.text)
			.map {
				guard let s1 = $0.0, let s2 = $0.1 else {
					return true
				}
				return s1.count != 0 && s2.count != 0
			}
			.bind(to: signInButton.rx.isEnabled)
			.disposed(by: disposeBag)

		signInButton.rx.tap
			.subscribe(onNext: { [weak self] _ in
				self?.events.onNext(.signInButtonTapped)
			})
			.disposed(by: disposeBag)

		store.states.subscribe().disposed(by: disposeBag)
	}

	private func render(state: State) {
		switch state.networkState {
		case .nothing:
			break
		case .requesting:
			let ac = UIAlertController(title: "ログイン機能が実装されていません", message: "実装してください", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "たぶん後でやる", style: .default, handler: nil))
			present(ac, animated: true, completion: nil)
			break
		case .error(_):
			break
		}
	}
}

