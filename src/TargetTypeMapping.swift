//
//  TargetTypeMapping.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 15/02/17.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import Moya
import T21Mapping

public typealias MoyaMapping<OutputType> = Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,OutputType>

public protocol TargetTypeMapping {
    associatedtype T
    var mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,T> { get }
}

