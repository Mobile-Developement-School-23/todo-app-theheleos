import Foundation

protocol NetworkingServiceProtocol {
    // Properties
    var networkTodoItems: [TodoItem] { get set }

    // Methods
    func sendNewItemToNetwork(item: TodoItem, completion: @escaping (Bool) -> Void)
    func removeItemFromNetwork(id: String, completion: @escaping (Bool) -> Void)
}
