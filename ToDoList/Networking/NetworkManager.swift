import Foundation

class NetworkingManager {
    static let shared = NetworkingManager()
    let token = "auricled "
    var revision = 0
    var toDoItemsFromNet: [TodoItem] = []
    var isDirty = false
    private init() {}
}
