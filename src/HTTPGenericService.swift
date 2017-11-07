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
import Alamofire

public class HTTPGenericService<ResponseType> : TargetType,TargetTypeMapping {
    
    let m_baseURL: URL
    let m_path: String
    let m_method: Moya.Method
    let m_parameters: [String: Any]?
    let m_parameterEncoding: ParameterEncoding
    let m_sampleData: Data
    let m_task: Task
    let m_headers: [String: String]?
    var m_mapping: MoyaMapping<ResponseType> = Mapping({ _ in return ("" as! ResponseType) })
    
    public init(_ baseURL: URL,
                _ path: String,
                _ method: Moya.Method = .get,
                _ parameters: [String: Any]? = nil,
                _ mapping: MoyaMapping<ResponseType> = Mapping({ _ in return ("" as! ResponseType) }),
                _ parameterEncoding: ParameterEncoding = URLEncoding.default,
                _ task: Task = .requestPlain,
                _ headers: [String: String]? = nil,
                _ sampleData: Data = "Sample data".utf8Encoded) {
        m_baseURL = baseURL
        m_path = path
        m_method = method
        m_parameters = parameters
        m_parameterEncoding = parameterEncoding
        m_sampleData = sampleData
        m_task = task
        m_headers = headers
        m_mapping = mapping
    }
    
    public convenience init(_ baseURL: URL,
                            _ path: String,
                            _ method: Moya.Method,
                            _ parameters: [String: Any]?,
                            _ headers: [String: String]? = nil,
                            _ mapping: MoyaMapping<ResponseType>) {
        self.init(baseURL,path,method,parameters,mapping,URLEncoding.default,.requestPlain,headers,"Sample data".utf8Encoded)
    }
    
    public convenience init(_ baseURL: URL,
                            _ path: String,
                            _ method: Moya.Method,
                            _ parameters: [String: Any]?,
                            _ headers: [String: String]?) {
        self.init(baseURL,path,method,parameters, Mapping({ _ in return ("" as! ResponseType) }),URLEncoding.default,.requestPlain,headers, "Sample data".utf8Encoded)
    }
    
    public func setMapping(_ mapping: MoyaMapping<ResponseType>) {
        m_mapping = mapping
    }
    
    public var baseURL: URL { return m_baseURL }
    
    public var path: String { return m_path }
    
    public var method: Moya.Method { return m_method }
    
    public var parameters: [String: Any]? { return m_parameters }
    
    public var parameterEncoding: ParameterEncoding { return m_parameterEncoding }
    
    public var sampleData: Data { return m_sampleData }
    
    public var task: Task { return m_task }
    
    public var headers: [String: String]? { return m_headers }
    
    public var mapping: MoyaMapping<ResponseType> { return m_mapping }
}

