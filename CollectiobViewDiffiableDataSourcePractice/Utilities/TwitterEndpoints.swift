//
//  TwitterEndpoints.swift
//  CollectiobViewDiffiableDataSourcePractice
//
//  Created by Vivian Phung on 2/19/23.
//

import Foundation

// MARK: - TwitterAPIEndpoint
enum TwitterAPIEndpoint: Endpoint {
    case getInfoForHandle, getHandlesForString, getProfilePhoto

    var path: String {
        switch self {
        case .getInfoForHandle:
            return "2/users/by"
        case .getHandlesForString:
            return "1.1/users/search.json"
        default:
            return ""
        }
    }

    var method: Method {
        switch self {
        default:
            return .GET
        }
    }
}
