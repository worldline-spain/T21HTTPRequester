//
//  HTTPRequesterResult.swift
//  T21HTTPRequester
//
//  Created by Eloi Guzmán Cerón on 17/02/17.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import Result

/**
 There is a Swift bug regarding Namespace conflicts. Alamofire.Result (Alamofire pod) conflicts with Result.Result
 (Result pod), even trying with Namespace specification fails.
 
 This typealias solves this conflict.
 
 http://stackoverflow.com/questions/26774101/swift-namespace-conflict
 */
public typealias HTTPRequesterResult<A,B: Swift.Error> = Result<A,B>
