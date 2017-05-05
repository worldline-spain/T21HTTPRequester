# T21HTTPRequester

## Version 1.0.0

T21HTTPRequester makes use of the Moya network abstraction layer library to offer an easy and a common way of interacting with a REST API. 

The requester adds an extra feature which resolves each endpoint (service) with an specific mapping and as a result an specific response type as well.

### Configuring a service endpoint

There two different options available to configure an API service/endpoint.

#### Implementing the protocols TargetType & TargetTypeMapping

Each endpoint must implement these two protocols: 

* TargetType: this protocol is part of the Moya library. It declares all the needed stuff to perform a request to the endpoint.
* TargetTypeMapping: this protocol is used to declare the mapping and also the response type of this request. The requester will use this protocol to infere the resulting response type.

The following code shows an example endpoint:

```
import Foundation
import Moya
import T21Mapping
import T21HTTPRequester

public class ExampleService : TargetType,TargetTypeMapping  {
    
    public var baseURL: URL { return URL(string: "https://swapi.co/api")! }
    
    public var path: String {
        return "/films/"
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var parameters: [String: Any]? {
        return nil
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var sampleData: Data {
        return "Sample data".utf8Encoded
    }
    
    public var task: Task {
        return .request
    }
    
    public var mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ExampleResponseType> {
        return Mapping({ (inputResponse) in 
        	return ExampleResponseType(inputResponse) 
        })
    }
}
```

As you can see, in order to define an specific service, quite a lot of coding is needed. Then, a possible workaround would be to create a BaseService which already defines the common values like the baseURL, the parameter encoding and the type of URL request task. Subclass only defines *the needed mapping, the path, the http method* (if it's different from the BaseService) and the *parameters*.

Here the complete example:

First the base service class:

```
public class BaseService <ResponseType> : TargetType,TargetTypeMapping  {
    
    public var baseURL: URL { return URL(string: "https://swapi.co/api")! }
    
    public var path: String {
        return ""
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var parameters: [String: Any]? {
        return nil
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var sampleData: Data {
        return "Sample data".utf8Encoded
    }
    
    public var task: Task {
        return .request
    }
    
    public var mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,ResponseType> {
        //BaseService mapping is not valid, overwrite it.
        return Mapping({ _ in return ("" as! ResponseType) })
    }
}
```

Then a concrete endpoint subclass (this one includes body parameters):

```
class LoginService : BaseService<GetLoginResponseType> {
    
    let userName: String
    let password: String
    
    init( _ userName: String, _ password: String) {
        self.userName = userName
        self.password = password
    }
    
    override var path : String {
        return "/"
    }
    
    override var parameters: [String: Any]? {
        return ["user" : userName, "password" : password]
    }
    
    override var method: Moya.Method {
        return .post
    }
    
    override var mapping: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,GetLoginResponseType> {
        return MappingAPILogin()
    }
}

```

Theoretically the Moya library uses an enum approach in order to define several services, but this leads to big enum types that grow each time a new service is added. Also, when using an **enum type** it's **not possible to define an specific response type** for each different enum type (each different endpoint).


#### Using the HTTPGenericService class

The HTTPGenericService class offers the possibility of creating a generic instance of any kind of service. All the needed parameters are sent when constructing the specific new instance.

An example of how to configure a service using the HTTPGenericService class.

```
let mappingA: Mapping<HTTPRequesterResult<Moya.Response, MoyaError>,String> = Mapping{ (result : HTTPRequesterResult<Moya.Response, MoyaError>) -> String in
    return "this example mapping returns an String literal"
}
let getFilmsServiceA = HTTPGenericService<String>(URL(string: "https://swapi.co/api")!,"/films/",.get,nil,mappingA)
```

As you can see, here we are speicifyng all the types, without letting the compiler infere the generic types needed to create the Mapping nor the Service. A reduced version taking profit of what the compiler knows would be:

```
let mappingB = MoyaMapping{ (result) in
    return "this example mapping returns an String literal"
}
let getFilmsServiceB = HTTPGenericService<String>(URL(string: "https://swapi.co/api")!,"/films/",.get,nil,mappingB)
```

As **the client doesn't need to create a class for each endpoint**, this makes the HTTPGenericService class a good candidate for using when creating service factory classes (like a ServiceFactory or a ServiceStore).

### Creating an HTTPRequester

In order to launch the services calls, the client app needs to instantiate an HTTPRequester. The HTTPRequester needs a MoyaProvider in order to work (that's because the requester uses Moya under the surface). This way we can take profit of all the possible configurations also available in Moya (like for example the plugin injections and so on).

The code to create an example requester:

```
//configure a custom MoyaProvider
// https://github.com/Moya/Moya/blob/master/docs/Endpoints.md
let endpointClosure = { (target: MultiTarget) -> Endpoint<MultiTarget> in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "TODO: APP NAME"])
}
    
//add the logger plugin
let loggingPlugin = HTTPRequesterLoggerPlugin(verbose: false)
    
//create the innerRequester using a MoyaProvider
let moyaProvider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, plugins: [loggingPlugin])
self.innerRequester = HTTPRequester(moyaProvider)

```

The previous code creates an example provider which adds some example HTTP HEADER fields to all the requests. It also adds a logger plugin used to output request info to the console.

Depending of you app's architecture you may want to offer visibility of the HTTPRequester instance to other classes. You may want to use dependency injection or use a singleton appraoch.

An example singleton approach would be like:

```
import Foundation
import Moya
import T21HTTPRequester

public class HTTPProvider {
    
    private static let sharedInstance = HTTPProvider()
    private let innerRequester: HTTPRequester
    
    private init() {
        
        //configure a custom MoyaProvider
        // https://github.com/Moya/Moya/blob/master/docs/Endpoints.md
        let endpointClosure = { (target: MultiTarget) -> Endpoint<MultiTarget> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            return defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "TODO: APP NAME"])
        }
        
        //add the logger plugin
        let loggingPlugin = HTTPRequesterLoggerPlugin(verbose: false)
        
        //create the innerRequester using a MoyaProvider
        let moyaProvider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure, plugins: [loggingPlugin])
        self.innerRequester = HTTPRequester(moyaProvider)
    }
    
    public static var requester: HTTPRequester {
        return HTTPProvider.sharedInstance.innerRequester
    }
}
```

Keep in mind that Singleton pattern may not be the best approach for your project, this is only an example show case.

### Launching a service request

Once we have the service instance, now it's time to launch the request using it. The HTTPRequester offers two main methods in order to launch the request:

```
public func request<RequestType>( _ service : RequestType, _ completion: @escaping (_ response: RequestType.T) -> (Void) ) where RequestType : TargetType, RequestType : TargetTypeMapping 
```

and 

```
public func requestSimple( _ service : TargetType, _ completion: @escaping (_ response: HTTPRequesterResult<Moya.Response, MoyaError>) -> Void)
```

#### The first one

The `service` parameter expects an instance which implements the TargetType and TargetTypeMapping protocols (check the document section **Configuring a service endpoint**).

```
let mapping = MoyaMapping{ (result) in
    return "this example mapping returns an String literal"
}
let getFilmsService = HTTPGenericService<String>(URL(string: "https://swapi.co/api")!,"/films/",.get,nil,mapping)

//using the previous example singleton approach

HTTPProvider.requester.request(getFilmsService, { (response: String) in
	print(response)
})

```

As you can see, this request method, inferes the response type from the service class. That means, client will always receive a concrete type. The main objective of the mapping is to avoid returning an uncontrolled response type like for example a Data or JSON object. If the architecture forces the use of a mapping, the client is "forced" to resolve all the possible response types derived from an endpoint: the possible happy paths, a connection error, a mapping error, an unauthorized error...

The previous example, is using an **String response type**. But in a real scenario the client could have a response class representation like this:

```
public enum GetFilmsResponseType {
    case success(films: [FilmType]) // HTTP Status code: 200
    case mappingFailed // when the mapping was not possible (missing compulsory values)
    case error(error: Swift.Error) // connection related errors
    case invalidToken // specific errors from the API
}
```

As you can see, with this representation the client is not leaving any possible unmanaged path. All the possible response are grouped in this enum response type. This will help avoiding uncontrolled inputs in our app.


#### The second one

The `service` parameter expects an instance which implements only TargetType protocol (not the TargetTypeMapping). That means, no mapping will be used.

Using this method the requester is not mapping the data received to an expected type, the client will receive an `HTTPRequesterResult<Moya.Response, MoyaError>` type. This is the expected Moya result without any extra layer.

