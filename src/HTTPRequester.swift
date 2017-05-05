//
//  HTTPRequester.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 23/11/16.
//  Copyright © 2016 Worldline. All rights reserved.
//

import UIKit
import Moya
import T21Mapping

public protocol HTTPRequesterProtocol {
    func request<RequestType>( _ service : RequestType, _ completion: @escaping (_ response: RequestType.T) -> (Void) ) where RequestType : TargetType, RequestType : TargetTypeMapping
    func requestSimple( _ service : TargetType, _ completion: @escaping (_ response: HTTPRequesterResult<Moya.Response, MoyaError>) -> Void)
}

public class HTTPRequester : HTTPRequesterProtocol {
    
    public let provider : MoyaProvider<MultiTarget>
    
    private let queue = OperationQueue()
    
    public init( _ provider: MoyaProvider<MultiTarget>) {
        queue.qualityOfService = QualityOfService.userInitiated
        self.provider = provider
    }
    
    public func request<RequestType>( _ service : RequestType, _ completion: @escaping (_ response: RequestType.T) -> (Void) ) where RequestType : TargetType, RequestType : TargetTypeMapping {
        let q = queue
        let currentQueue = OperationQueue.current!
        provider.request(MultiTarget(service), completion: { (result) in
            q.addOperation({
                let mapping: MoyaMapping<RequestType.T> = service.mapping
                let response: RequestType.T = mapping.map(result)
                currentQueue.addOperation({
                    completion(response)
                })
            })
        })
    }
    
    public func requestSimple( _ service : TargetType, _ completion: @escaping (_ response: HTTPRequesterResult<Moya.Response, MoyaError>) -> Void){
        provider.request(MultiTarget(service), completion: { (result) in
            completion(result)
        })
    }
}
