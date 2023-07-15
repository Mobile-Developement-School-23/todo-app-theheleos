import CoreData
import UIKit

class FileCache {

    private var coreDataSettings = CoreDataSettings()
    private(set) var todoItems = [TodoItem]()

    func load() {
        let fetchRequest: NSFetchRequest<CoreDataItem> = CoreDataItem.fetchRequest()
        do {
            let response = try coreDataSettings.context.fetch(fetchRequest)
            todoItems = response.map { convertToTodoItem(item: $0) }
        } catch {
            print(error)
        }
    }

    func save(items: [TodoItem]) {
        clearCoreData()
        for item in items {
            convertToCoreData(item: item)
            todoItems.append(item)
        }
        coreDataSettings.saveContext()
        
    }
/*
    func update() {

    }

    func delete(item: TodoItem) {
        let fetchRequest: NSFetchRequest<CoreDataItem> = CoreDataItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)

        do {
            let response = try coreDataSettings.context.fetch(fetchRequest)
            coreDataSettings.context.delete(convertToCoreData(item: item))

            if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
                todoItems.remove(at: index)
            }

        } catch {
            print(error)
        }

    }
 */

    private func clearCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CoreDataItem.fetchRequest()
        fetchRequest.includesPropertyValues = false // Опция для экономии памяти

        // Создание пакетной операции удаления
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            // Выполнение пакетной операции удаления
            try coreDataSettings.context.execute(batchDeleteRequest)
            // Сохранение изменений в контексте CoreData
            try coreDataSettings.context.save()

        } catch {
        }
    }

    private func convertToTodoItem(item: CoreDataItem) -> TodoItem {
        let importance = Importance(rawValue: item.importance ?? "basic") ?? .basic
        return TodoItem(
            id: item.id ?? UUID().uuidString,
            text: item.text ?? "",
            importance: importance,
            dateDeadline: item.dateDeadline,
            isDone: item.isDone,
            dateСreation: item.dateCreation ?? Date(),
            dateChanging: item.dateChanging
        )
    }

    @discardableResult
    private func convertToCoreData(item: TodoItem) -> CoreDataItem {
        let coreDataItem = CoreDataItem(context: coreDataSettings.context)
        coreDataItem.id = item.id
        coreDataItem.text = item.text
        coreDataItem.importance = item.importance.rawValue
        coreDataItem.dateDeadline = item.dateDeadline
        coreDataItem.dateCreation = item.dateСreation
        coreDataItem.dateChanging = item.dateChanging
        return coreDataItem
    }
}
