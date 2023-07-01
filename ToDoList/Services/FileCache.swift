import Foundation
import CocoaLumberjackSwift
import TodoItem

// MARK: - Class

final class FileCache {
    private(set) var todoItems: [String: TodoItem] = [:]

    func add(_ item: TodoItem) {
        DDLogInfo("Added new ToDoItem with ID: \(item.id)")
        return todoItems[item.id] = item
    }

    func remove(with id: String) -> TodoItem? {
        if let itemIntList = todoItems[id] {
            todoItems[id] = nil
            DDLogInfo("Deleted ToDoItem with ID: \(id)")
            return itemIntList
        } else {
            DDLogInfo("ID not found")
            return nil
        }
    }
}

// MARK: - Extensions

extension FileCache {
    func loadFromJSON(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)
        
        guard let data = try? Data(contentsOf: pathWithFileName) else { throw FileCacheErrors.PathToFileNotFound }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any] else { throw FileCacheErrors.JSONConvertationError }
        
        for jsonItem in jsonObject {
            if let parsedItem = TodoItem.parse(json: jsonItem) {
                add(parsedItem)
                DDLogInfo("Loaded ToDoItem with ID: \(parsedItem.id)")
            }
        }
    }
    
    
    func saveToJSON(file name: String) throws {
        
        let todoJsonItems = todoItems.map { $1.json }
        
        guard let data = try? JSONSerialization.data(withJSONObject: todoJsonItems) else { throw FileCacheErrors.JSONConvertationError }
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.json.rawValue)
        
        do {
            try data.write(to: pathWithFileName)
            DDLogInfo("Saved ToDoItems to JSON file: \(pathWithFileName)")
        } catch {
            throw FileCacheErrors.PathToFileNotFound
        }
    }
}

extension FileCache {
    func loadFromCSV(file name: String) throws {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.csv.rawValue)

        guard let data = try? String(contentsOf: pathWithFileName, encoding: .utf8) else { throw FileCacheErrors.PathToFileNotFound }

        var rows = data.description.components(separatedBy: csvLineSeparator)
        rows.removeFirst()

        for row in rows {
            if let item = TodoItem.parse(csv: String(row)) {
                add(item)
                DDLogInfo("Loaded ToDoItem from CSV: \(item)")
            }
        }
    }


    func saveToCSV(file name: String) throws {
        var dataToSave = [csvHeaderFormat]

        for todoCSVItem in todoItems.map({ $1.csv }) {
            dataToSave.append(todoCSVItem)
        }

        let joinedString = dataToSave.joined(separator: csvLineSeparator)

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw FileCacheErrors.DirectoryNotFound }
        let pathWithFileName = documentDirectory.appendingPathComponent(name + FileFormat.csv.rawValue)

        do {
            try joinedString.write(to: pathWithFileName, atomically: true, encoding: .utf8)
            DDLogInfo("Saved ToDoItems to CSV file: \(pathWithFileName)")
        } catch {
            throw FileCacheErrors.PathToFileNotFound
        }
    }
}

// MARK: - Enums

enum FileCacheErrors: String, Error {
    case DirectoryNotFound = "Директория файла не найдена, попробуйте поменять в fileCache папки"
    case JSONConvertationError = "Ошибка с конвертацией JSON файла"
    case PathToFileNotFound = "Путь до файла не найден, проверьте конечный путь"
    case WriteFileError = "Ошибка при записи файла"
}

private enum FileFormat: String {
    case csv = ".csv"
    case json = ".json"
}

private let csvHeaderFormat = "id;text;importance;date_deadline;is_done;date_creation;date_changing"
private let csvLineSeparator = "/r/n"
