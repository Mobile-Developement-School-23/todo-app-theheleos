import Foundation
import UIKit

extension TodoListViewController {
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {
        if todoItems[indexPath.row].dateСreation != .distantPast {
            let conifguration = UIContextMenuConfiguration(
                identifier: todoItems[indexPath.row].id as NSCopying, previewProvider: nil) { _ in
                var textSaveAction = "Выполнено"
                var imageSaveAction = Resources.Images.checkDoneMarkImage
                if self.todoItems[indexPath.row].isDone {
                    textSaveAction = "Отменить выполнение"
                    imageSaveAction = Resources.Images.checkMarkImage
                }

                let saveAction = UIAction(title: textSaveAction, image: imageSaveAction) { _ in
                    self.doneItemAction(indexPath.row)
                    self.makeSave()
                    tableView.reloadData()
                }

                    let deleteAction = UIAction(title: "Delete", image: Resources.Images.trashImage) { _ in
                    self.todoItems.remove(at: indexPath.row)
                    let filteredTodoItemsCount = self.todoItems.filter { $0.isDone }.count
                    self.headerView.update(
                        doneItemsCount: filteredTodoItemsCount == 0 ? self.doneTodoItems.count : filteredTodoItemsCount)
                    self.makeSave()
                    tableView.reloadData()
                }

                let menu = UIMenu(
                    title: "",
                    image: nil,
                    identifier: nil,
                    options: [],
                    children: [saveAction, deleteAction]
                )

                return menu
            }

            return conifguration
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView,
                   willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                   animator: UIContextMenuInteractionCommitAnimating) {
        let item = todoItems.first(where: { $0.id == configuration.identifier as? String })
        let newVC = TodoItemViewController(item: item)
        newVC.navigationItem.largeTitleDisplayMode = .never
        newVC.modalPresentationStyle = .custom
        newVC.transitioningDelegate = self
        newVC.setUserInteractionDisabled()

        show(newVC, sender: nil)
    }
}
