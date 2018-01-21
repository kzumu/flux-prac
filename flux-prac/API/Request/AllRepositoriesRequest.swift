//
//  AllRepositoriesRequest.swift
//  flux-prac
//
//  Created by 下村一将 on 2018/01/21.
//  Copyright © 2018年 kazu. All rights reserved.
//

import Foundation
import Alamofire

extension APIRequest {
	struct AllRepositoriesRequest: GithubAPIRequest {
		typealias Response = RepositoryEntity

		var path: String {
			return ""
		}

		var headers: HTTPHeaders? {
			return [:]
		}

		var method: HTTPMethod {
			return .get
		}

		var parameters: Parameters? {
			return nil
		}
	}
}
