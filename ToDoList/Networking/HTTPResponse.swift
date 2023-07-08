import Foundation

class HTTPResponse {
    private let httpMethod: MethodHttp
    private let path: String
    private let header: [String: String]
    private let httpBody: Data?
    var updateRevision: ((Int) -> Void)?

    init(
        httpMethod: MethodHttp = .get,
        path: String = "",
        header: [String: String],
        httpBody: Data? = nil
    ) {
        self.httpMethod = httpMethod
        self.path = "/todobackend/list" + path
        self.header = header
        self.httpBody = httpBody
    }

    private func makeURL() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "beta.mrdekk.ru" // ??
        components.path = path

        guard let url = components.url else { throw NetworkingError.incorrectURL }

        return url
    }

    private func configureURLRequest() throws -> URLRequest {
        let url = try makeURL()

        var request = URLRequest(url: url, timeoutInterval: 60.0)
        request.httpMethod = httpMethod.rawValue.uppercased()
        request.httpBody = httpBody
        header.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        return request
    }

    func getResponse(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        do {
            let request = try configureURLRequest()
            switch httpMethod {
            case .get, .patch:
                performListRequest(request: request, completion: completion)
            case .post, .delete, .put, .getElement:
                performElementRequest(request: request, completion: completion)
            }
        } catch {
            completion(.failure(error))
        }
    }

    private func performListRequest(request: URLRequest, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkingError.invalidData))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsn = json as? [String: Any] {
                    if let revision = jsn["revision"] as? Int {
                        self.updateRevision?(revision)
                    }
                    if let list = jsn["list"] as? [Any] {
                        completion(.success(list.compactMap { TodoItem.parse(JSON: $0) }))
                    }
                }
            } catch {
                print(NetworkingError.decoderError)
            }
        }.resume()
    }

    private func performElementRequest(request: URLRequest, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(.failure(NetworkingError.incorrectURL))
            }
            guard let data = data else {
                completion(.failure(NetworkingError.invalidData))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsn = json as? [String: Any] {
                    if let revision = jsn["revision"] as? Int {
                        self.updateRevision?(revision)
                    }
                    if let list = jsn["element"] as? [Any] {
                        completion(.success(list.compactMap { TodoItem.parse(JSON: $0) }))
                    }
                }
            } catch {
                completion(.failure(NetworkingError.decoderError))
            }
        }.resume()
    }
}
