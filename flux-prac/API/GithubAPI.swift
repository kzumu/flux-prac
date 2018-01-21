//
//  GithubAPI.swift
//  flux-prac
//
//  Created by 下村一将 on 2018/01/21.
//  Copyright © 2018年 kazu. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Unbox

final class GitHubAPI {
	let baseURL = Secret.API_END_POINT
	let parameterEncoding = URLEncoding.methodDependent

	func send<Req: GithubAPIRequest>(req: Req) -> Single<Req.Response> where Req.Response: Unboxable {
		let url = baseURL.appending(req.path)
		let req = Alamofire.request(url, method: req.method, parameters: req.parameters, encoding: parameterEncoding, headers: req.headers)
		print(req.debugDescription)
		return Single.create(subscribe: { observer in
			req.responseJSON(completionHandler: { dataResponse in
				print(dataResponse.debugDescription)
				switch dataResponse.result {
				case .success(let v):
					guard let dic =  v as? UnboxableDictionary else {
						observer(.error(NSError(domain: "Unbox Error", code: -1, userInfo: nil)))
						return
					}
					do {
						observer(.success(try unbox(dictionary: dic)))
					} catch (let e) {
						observer(.error(e))
					}
				case .failure(let e):
					observer(.error(e))
				}
			})
			return Disposables.create()
		})
	}
}

protocol GithubAPIRequest {
	associatedtype Response
	var path: String { get }
	var headers: HTTPHeaders? { get }
	var method: HTTPMethod { get }
	var parameters: Parameters? { get }
}

struct APIRequest {}

