//
//  EndpointError.swift
//  Tuna
//
//  Created by Ben Williams on 27/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import Foundation

///Endpoint Error
enum EndPointError: Error {
    case couldNotParse(message: String)
    case noData(message: String)
    case unsupportedEndpoint(message: String)
    case endpointError(message: String)
    case maximumResultsReached(message: String = "You have reached maximum amount articles. Upgrade your account to see more.")
    case unknown(message: String = "Error status with no error message")
    case missing(message: String)
}

extension EndPointError: LocalizedError { //to show passed message for error.localizedDescription
    public var errorDescription: String? {
        switch self {
            case let .couldNotParse(message),
                 let .noData(message),
                 let .unsupportedEndpoint(message),
                 let .endpointError(message),
                 let .maximumResultsReached(message),
                 let .unknown(message),
                 let .missing(message):
                return message
        }
    }
}
