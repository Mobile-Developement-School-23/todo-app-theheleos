import Foundation
import UIKit

struct NetworkItem: Codable {
    let id: String
    let text: String
    let importance: String
    let dateDeadline: Int?
    let isDone: Bool
    let dateCreation: Int
    let dateChanging: Int
    let color: String?
    let deviceId: String

    init(from toDoItem: TodoItem) {
        self.id = toDoItem.id
        self.text = toDoItem.text
        self.importance = toDoItem.importance.rawValue
        self.dateDeadline = toDoItem.dateDeadline.flatMap { Int($0.timeIntervalSince1970) }
        self.isDone = toDoItem.isDone
        self.dateCreation = Int(toDoItem.dateСreation.timeIntervalSince1970)
        self.dateChanging = Int((toDoItem.dateСreation).timeIntervalSince1970)
        self.color = nil
        self.deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case dateDeadline = "deadline"
        case isDone = "done"
        case dateCreation = "created_at"
        case dateChanging = "changed_at"
        case color
        case deviceId = "last_updated_by"
    }
}
struct NetworkList: Codable {
    let status: String
    let list: [NetworkItem]
    let revision: Int

    init(status: String = "ok", list: [NetworkItem], revision: Int = 0) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}

 enum NetworkKeys {
      static let status = "status"
      static let element = "element"
      static let list = "list"
      static let revision = "revision"
  }
