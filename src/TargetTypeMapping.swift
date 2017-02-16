//
//  TargetTypeMapping.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 15/02/17.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import Moya
import Result
import T21Mapping

public protocol TargetTypeMapping {
    associatedtype T
    var mapping: Mapping<Result<Moya.Response, MoyaError>,T> { get }
}
