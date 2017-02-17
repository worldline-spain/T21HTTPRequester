//
//  GenericService.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 10/02/17.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import Moya
import T21Mapping

public class HTTPGenericService<ResponseType> : TargetType,TargetTypeMapping {
    
    let m_baseURL: URL
    let m_path: String
    let m_method: Moya.Method
    let m_parameters: [String: Any]?
    let m_parameterEncoding: ParameterEncoding
    let m_sampleData: Data
    let m_task: Task
    var m_mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ResponseType> = Mapping({ _ in return ("" as! ResponseType) })
    
    public init(_ baseURL: URL,
                _ path: String,
                _ method: Moya.Method = .get,
                _ parameters: [String: Any]? = nil,
                _ mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ResponseType> = Mapping({ _ in return ("" as! ResponseType) }),
                _ parameterEncoding: ParameterEncoding = URLEncoding.default,
                _ task: Task = .request,
                _ sampleData: Data = "Sample data".utf8Encoded) {
        m_baseURL = baseURL
        m_path = path
        m_method = method
        m_parameters = parameters
        m_parameterEncoding = parameterEncoding
        m_sampleData = sampleData
        m_task = task
        m_mapping = mapping
    }
    
    public convenience init(_ baseURL: URL,
                            _ path: String,
                            _ method: Moya.Method,
                            _ parameters: [String: Any]?,
                            _ mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ResponseType>) {
        self.init(baseURL,path,method,parameters,mapping)
    }
    
    public convenience init(_ baseURL: URL,
                            _ path: String,
                            _ method: Moya.Method,
                            _ parameters: [String: Any]?) {
        self.init(baseURL,path,method,parameters)
    }
    
    public func setMapping(_ mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ResponseType>) {
        m_mapping = mapping
    }
    
    public var baseURL: URL { return m_baseURL }
    
    public var path: String { return m_path }
    
    public var method: Moya.Method { return m_method }
    
    public var parameters: [String: Any]? { return m_parameters }
    
    public var parameterEncoding: ParameterEncoding { return m_parameterEncoding }
    
    public var sampleData: Data { return m_sampleData }
    
    public var task: Task { return m_task }
    
    public var mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ResponseType> { return m_mapping }
}

extension String {
    public var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    public var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
