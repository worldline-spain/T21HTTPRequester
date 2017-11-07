//
//  HTTPService.swift
//  T21HTTPRequester
//
//  Created by Eloi Guzmán Cerón on 11/05/2017.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation

import Foundation
import Moya
import T21Mapping
import Alamofire

public class HTTPService : TargetType {
    
    let m_baseURL: URL
    let m_path: String
    let m_method: Moya.Method
    let m_parameters: [String: Any]?
    let m_parameterEncoding: ParameterEncoding
    let m_sampleData: Data
    let m_task: Task
    let m_headers: [String: String]?
    
    public init(_ baseURL: URL,
                _ path: String,
                _ method: Moya.Method = .get,
                _ parameters: [String: Any]? = nil,
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
    }
    
    public convenience init(_ baseURL: URL,
                            _ path: String,
                            _ method: Moya.Method,
                            _ parameters: [String: Any]?,
                            _ headers: [String: String]?) {
        self.init(baseURL,path,method,parameters,URLEncoding.default,.requestPlain,headers,"Sample data".utf8Encoded)
    }
    
    public var baseURL: URL { return m_baseURL }
    
    public var path: String { return m_path }
    
    public var method: Moya.Method { return m_method }
    
    public var parameters: [String: Any]? { return m_parameters }
    
    public var parameterEncoding: ParameterEncoding { return m_parameterEncoding }
    
    public var sampleData: Data { return m_sampleData }
    
    public var task: Task { return m_task }
    
    public var headers: [String: String]? { return m_headers }
}

extension String {
    public var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    public var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
