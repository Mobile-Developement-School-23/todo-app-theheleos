import CoreData
import UIKit
import SQLite

class FileCache {

    private var coreDataSettings = CoreDataSettings()
    private(set) var todoItems = [TodoItem]()
    private var SQLTodoItems = [TodoItem]()

    func loadFromCoreData() {
        let fetchRequest: NSFetchRequest<CoreDataItem> = CoreDataItem.fetchRequest()
        do {
            let response = try coreDataSettings.context.fetch(fetchRequest)
            todoItems = response.map { convertToTodoItem(item: $0) }
        } catch {
            print(error)
        }
    }

    func saveToCoreData(items: [TodoItem]) {
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
        fetchRequest.includesPropertyValues = false

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try coreDataSettings.context.execute(batchDeleteRequest)
            try coreDataSettings.context.save()
        } catch {
            print(error)
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

extension FileCache {

    private func getDatabasePath() -> String? {
        let fileManager = FileManager.default
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
                .userDomainMask,
            true
        ).first

        guard let appSupportPath = applicationSupportPath else { return nil }
        let databasePath = "\(appSupportPath)/\("sqlTodoBase").\("db")"

        if !fileManager.fileExists(atPath: databasePath) {
            do {
                try fileManager.createDirectory(
                    atPath: appSupportPath,
                    withIntermediateDirectories: true,
                    attributes: nil
                 )
            } catch { return nil }
            guard let bundlePath = Bundle.main.path(forResource: "sqlTodoBase", ofType: "db") else { return nil }
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: databasePath)
            } catch { return nil }
        }

        return databasePath
    }

    func saveToSQL(items: [TodoItem]) -> String {
        var sqlReplaceStatements: [String] = []

        guard let databasePath = getDatabasePath() else {
            print("Ошибка получения пути базы данных")
            return ""
        }

        guard let dataBase = try? Connection(databasePath) else {
            print("Ошибка подключения к базе данных")
            return ""
        }

        for item in items {
            var sqlColumns: [String] = []
            var sqlValues: [String] = []

            sqlColumns.append("id")
            sqlValues.append("'\(item.id)'")

            sqlColumns.append("text")
            sqlValues.append("'\(item.text)'")

            sqlColumns.append("importance")
            sqlValues.append("\(item.importance.rawValue)")

            if let deadline = item.dateDeadline {
                sqlColumns.append("dateDeadline")
                sqlValues.append("'\(deadline)'")
            }

            sqlColumns.append("isDone")
            sqlValues.append("\(item.isDone ? 1 : 0)")

            sqlColumns.append("dateСreation")
            sqlValues.append("'\(item.dateСreation)'")

            if let dateChanging = item.dateChanging {
                sqlColumns.append("dateChanging")
                sqlValues.append("'\(dateChanging)'")
            }

            // Создание строки запроса REPLACE INTO
            let sqlReplaceStatement = "REPLACE INTO YourTableName (\(sqlColumns.joined(separator: ","))) VALUES (\(sqlValues.joined(separator: ",")))"

            sqlReplaceStatements.append(sqlReplaceStatement)
        }

        let combinedStatements = sqlReplaceStatements.joined(separator: "; ")

        do {
            try dataBase.execute(combinedStatements)
            print("Данные успешно сохранены в базе данных")
        } catch {
            print("Ошибка сохранения данных в базе данных: \(error)")
        }

        return combinedStatements
    }

    func loadFromSQL() -> [TodoItem] {
        var newTodoItems: [TodoItem] = []

        guard let databasePath = getDatabasePath() else {
            print("Ошибка получения пути базы данных")
            return newTodoItems
        }

        guard let database = try? Connection(databasePath) else {
            print("Ошибка подключения к базе данных")
            return newTodoItems
        }

        do {
            let query = "SELECT * FROM sqlTodoBase"
            let rows = try database.prepare(query)

            for row in rows {
                guard let id = row[0] as? String,
                      let text = row[1] as? String,
                      let importanceValue = row[2] as? Int64,
                      let importance = Importance(rawValue: importanceValue),
                      let isDoneValue = row[5] as? Int64
                else {
                    print("Ошибка чтения данных из базы данных")
                    continue
                }

                let dateDeadline = row[3] as? Date
                let isDone = isDoneValue == 1 ? true : false
                let dateСreation = (row[6] as? Date) ?? Date()
                let dateChanging = row[7] as? Date

                let todoItem = TodoItem(
                    id: id,
                    text: text,
                    importance: importance,
                    dateDeadline: dateDeadline,
                    isDone: isDone,
                    dateСreation: dateСreation,
                    dateChanging: dateChanging
                )

                newTodoItems.append(todoItem)
            }

            print("Данные успешно загружены из базы данных")
        } catch {
            print("Ошибка загрузки данных из базы данных: (error)")
        }

        return newTodoItems
    }
}
