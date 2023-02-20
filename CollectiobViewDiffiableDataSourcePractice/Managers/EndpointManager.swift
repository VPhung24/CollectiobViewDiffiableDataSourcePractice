//
//  EndpointManager.swift
//  CollectiobViewDiffiableDataSourcePractice
//
//  Created by Vivian Phung on 2/19/23.
//

import Foundation

public enum Method: String {
    case GET
    case POST
}

public protocol Endpoint {
    var path: String { get }
    var method: Method { get }
}
