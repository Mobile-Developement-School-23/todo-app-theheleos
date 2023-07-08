import Foundation

protocol NetworkingServiceProtocol {
    var httpResponse: HTTPResponse? { get set }
}

class DefaultNetworkService: NetworkingServiceProtocol {
    var httpResponse: HTTPResponse?

    // куда-то перенести
    static var revision: Int {
        get {
            UserDefaults.standard.integer(forKey: "revision")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "revision")
        }
    }

    private var header = [
        "Authorization": "Bearer auricled"
    ]

    private func configureResponse(selectedResponse: MethodHttp) -> HTTPResponse {
        header["X-Last-Known-Revision"] = String(DefaultNetworkService.revision)
        switch selectedResponse {
        case .get:
            return HTTPResponse(header: header)
        case .post(let item):
            return HTTPResponse(
                httpMethod: .post(item),
                header: header,
                httpBody: try? JSONSerialization.data(withJSONObject: ["element": item.json], options: [])
            )

        case .patch(let items):
            return HTTPResponse(
                httpMethod: .patch(items),
                header: header,
                httpBody: try? JSONSerialization.data(withJSONObject: ["list": items.map { $0.json }])
            )
        case .delete(let id):
            return HTTPResponse(
                httpMethod: .delete(id),
                path: "/\(id)",
                header: header
            )
        case .put(let id, let item):
            return HTTPResponse(
                httpMethod: .put(id, item),
                path: "/\(id)",
                header: header,
                httpBody: try? JSONSerialization.data(withJSONObject: ["element": item.json], options: [])
            )
        case .getElement(let id):
            return HTTPResponse(
                httpMethod: .getElement(id),
                path: "/\(id)",
                header: header
            )
        }
    }

    func makeRequest(with response: MethodHttp = .get, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        self.httpResponse = configureResponse(selectedResponse: response)
        httpResponse?.updateRevision = { value in
            DefaultNetworkService.revision = value
        }
        httpResponse?.getResponse(completion: completion)
    }
}

enum MethodHttp {
    case get
    case post(TodoItem)
    case patch([TodoItem])
    case delete(String)
    case put(String, TodoItem)
    case getElement(String)

    var rawValue: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .put: return "PUT"
        case .getElement: return "GET"
        }
    }
}

enum NetworkingError: Error {
    case incorrectURL, invalidData, decoderError
}
