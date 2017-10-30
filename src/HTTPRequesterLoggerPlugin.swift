//
//  HTTPRequesterLoggerPlugin.swift
//  MyApp
//
//  Created by Eloi Guzmán Cerón on 10/02/17.
//  Copyright © 2017 Worldline. All rights reserved.
//

import Foundation
import Moya

public final class HTTPRequesterLoggerPlugin: PluginType {
    
    public enum LogType {
        case standard
        case warning
        case error
    }
    
    fileprivate let loggerId = "Default"
    fileprivate let separator = "\n "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ seperator: String, _ terminator: String, _ items: [String], _ error: LogType) -> Void
    fileprivate let responseDataFormatter: ((Data) -> (Data))?
    
    /// If true, also logs response body data.
    public let isVerbose: Bool
    public let cURL: Bool
    
    public init(verbose: Bool = true, cURL: Bool = false, output: @escaping (_ seperator: String, _ terminator: String, _ items: [String], _ error: LogType) -> Void = HTTPRequesterLoggerPlugin.print, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.isVerbose = verbose
        self.output = output
        self.responseDataFormatter = responseDataFormatter
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(separator, terminator, [request.debugDescription], .standard)
            return
        }
        outputItems(logNetworkRequest(request.request as URLRequest?), .standard)
    }
    
    public func didReceive(_ result: HTTPRequesterResult<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            var logType = LogType.standard
            if response.statusCode >= 500 {
                logType = LogType.error
            } else if response.statusCode >= 300 {
                logType = LogType.warning
            }
            outputItems(logNetworkResponse(response.response, data: response.data, target: target), logType)
            
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target), LogType.error)
        }
    }
    
    fileprivate func outputItems(_ items: [String], _ error: LogType) {
        if isVerbose {
            items.forEach { output(separator, terminator, [$0], error) }
        } else {
            output(separator, terminator, items, error)
        }
    }
}

private extension HTTPRequesterLoggerPlugin {
    
    func format(_ loggerId: String, identifier: String, message: String) -> String {
        return "\(loggerId): \(identifier): \(message)"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        
        var output = [String]()
        
        output += [format(loggerId, identifier: "Request", message: request?.description ?? "(invalid request)")]
        
        #if DEBUG
        if let headers = request?.allHTTPHeaderFields {
            output += [format(loggerId, identifier: "Request Headers", message: headers.description)]
        }
        #endif
        
        if let bodyStream = request?.httpBodyStream {
            output += [format(loggerId, identifier: "Request Body Stream", message: bodyStream.description)]
        }
        
        if let httpMethod = request?.httpMethod {
            output += [format(loggerId, identifier: "HTTP Request Method", message: httpMethod)]
        }
        
        #if DEBUG
        if let body = request?.httpBody, let stringOutput = String(data: body, encoding: .utf8), isVerbose {
            output += [format(loggerId, identifier: "Request Body", message: stringOutput)]
        }
        #endif
        
        return output
    }
    
    func logNetworkResponse(_ response: URLResponse?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
            return [format(loggerId, identifier: "Response", message: "Received empty network response for \(target).")]
        }
        
        var output = [String]()
        
        output += [format(loggerId, identifier: "Response", message: response.description)]
        
        #if DEBUG
        if let data = data, let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8), isVerbose {
            output += [stringData]
        }
        #endif
        
        return output
    }
}

 public extension HTTPRequesterLoggerPlugin {
    static func print(seperator: String, terminator: String, items: [String], error: LogType = .standard) {
        let log = items.reduce("", { (prev, item) in
            return "\(prev)\(seperator)\(item)"})
        
        switch error {
        case .standard:
            HTTPRequesterLogger.verbose(log)
            break
        case .warning:
            HTTPRequesterLogger.warning(log)
            break
        case .error:
            HTTPRequesterLogger.error(log)
            break
        }
    }
}
