import Foundation
import UIKit

// switlint:disable type_body_length

class DefaultNetworkingService {
    private let networkingManager = NetworkingManager.shared
    var networkTodoItems: [TodoItem] = []
    let urlSession: URLSession = URLSession(configuration: .default)

    @discardableResult
    func getInfFormNetwork() -> Bool {
        var isSuccess = false

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global().async {
            self.getItem { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success:
                    self.networkingManager.isDirty = false
                    isSuccess = true
                case .failure(let error):
                    print(error)
                    self.networkingManager.isDirty = true
                }
            }
        }
        group.wait()

        return isSuccess
    }

    func getListFromNetwork(completion: @escaping (Bool) -> Void) {
        patch { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                    self.networkingManager.isDirty = false
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion(false)
                    self.networkingManager.isDirty = true
                }
            }
        }
    }

    func sendNewItemToNetwork(item: TodoItem, completion: @escaping (Bool) -> Void) {
        post(item: item) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                    self.networkingManager.isDirty = false
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion(false)
                    self.networkingManager.isDirty = true
                }
            }
        }

    }

    func removeItemFromNetwork(id: String, completion: @escaping (Bool) -> Void) {
        delete(withId: id) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                    self.networkingManager.isDirty = false
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion(false)
                    self.networkingManager.isDirty = true
                }
            }
        }

    }

    func updateItemInfo(id: String, item: TodoItem, completion: @escaping (Bool) -> Void) {
        put(withId: id, newItem: item) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                    self.networkingManager.isDirty = false
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion(false)
                    self.networkingManager.isDirty = true
                }
            }
        }
    }

    // MARK: - privat

   private func getItem(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(URLInfo.baseURL)") else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(networkingManager.token)"
        ]

        let task = urlSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkingError.invalidData))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let result = json as? [String: Any] else {
                    completion(.failure(NetworkingError.invalidResponse))
                    return
                }

                if let status = result[NetworkKeys.status] as? String, status == "ok" {
                    if let revision = result[NetworkKeys.revision] as? Int {
                        self.networkingManager.revision = revision
                    }
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkingError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

  private func patch(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(URLInfo.baseURL)") else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(networkingManager.token)",
            "X-Last-Known-Revision": "\(networkingManager.revision)"
        ]

        let task = urlSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkingError.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let netList = try decoder.decode(NetworkList.self, from: data)
                if netList.status == "ok" {
                    self.networkTodoItems = netList.list.map { netToDoItem in
                        return TodoItem(
                            id: netToDoItem.id,
                            text: netToDoItem.text,
                            importance: Importance(rawValue: netToDoItem.importance) ?? .low,
                            dateDeadline: netToDoItem.dateDeadline.map { Date(timeIntervalSince1970: TimeInterval($0))},
                            isDone: netToDoItem.isDone,
                            dateСreation: Date(timeIntervalSince1970: TimeInterval(netToDoItem.dateCreation)),
                            dateChanging: Date(timeIntervalSince1970: TimeInterval(netToDoItem.dateChanging))
                        )

                    }
                    self.networkingManager.revision = netList.revision
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkingError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

   private func post(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(URLInfo.baseURL)/") else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let jsonData = createJSONElement(
            from: NetworkItem.init(from: item),
            revision: NetworkingManager.shared.revision
        ) {
                request.httpBody = jsonData
            } else {
                completion(.failure(NetworkingError.jsonSerializationFailed))
                return
            }

        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(networkingManager.token)",
            "X-Last-Known-Revision": "\(NetworkingManager.shared.revision)"
        ]

        let task = urlSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard data != nil else {
                completion(.failure(NetworkingError.invalidData))
                return
            }

            completion(.success(()))
        }

        task.resume()
    }

  private func delete(withId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(URLInfo.baseURL)/" + withId) else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }
        print(networkingManager.revision)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(networkingManager.token)",
            "X-Last-Known-Revision": "\(networkingManager.revision)"
        ]

            let task = urlSession.dataTask(with: request) { (_, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.networkingManager.revision += 1
                        completion(.success(()))
                    } else {
                        let error = NSError(domain: "NetworkingError", code: httpResponse.statusCode, userInfo: nil)
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NetworkingError.invalidResponse))
                }
            }

            task.resume()
        }

  private func put(withId id: String, newItem: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(URLInfo.baseURL)/\(id)") else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        if let jsonData = createJSONElement(
            from: NetworkItem(from: newItem),
            revision: NetworkingManager.shared.revision
        ) {
            request.httpBody = jsonData
        } else {
            completion(.failure(NetworkingError.jsonSerializationFailed))
            return
        }

        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(networkingManager.token)",
            "X-Last-Known-Revision": "\(NetworkingManager.shared.revision)"
        ]

        let task = urlSession.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.networkingManager.revision += 1
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "NetworkingError", code: httpResponse.statusCode, userInfo: nil)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NetworkingError.invalidResponse))
            }
        }

        task.resume()
    }

  private func createJSONElement(from netToDoItem: NetworkItem, revision: Int) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            let jsonData = try encoder.encode(netToDoItem)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let jsonObject: [String: Any] = [
                "status": "ok",
                "element": json,
                "revision": revision
            ]
            return try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        } catch {
            print("Error creating JSON: \(error)")
            return nil
        }
    }

   private enum NetworkingError: Error {
        case invalidURL
        case invalidData
        case invalidResponse
        case jsonSerializationFailed
    }
}
// switlint:enable type_body_length
