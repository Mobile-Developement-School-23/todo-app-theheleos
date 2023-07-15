import UIKit

class TodoListViewController: UIViewController {

    let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
    lazy var todoListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = Resources.Colors.primaryBack
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(Resources.Images.plusButton, for: .normal)

        button.imageView?.contentMode = .center

        button.layer.shadowColor = Resources.Colors.blueColor.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 8

        button.addTarget(self, action: #selector(tapPlusButton), for: .touchUpInside)
        button.isHidden = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let coreData = FileCache()
    var todoItems = [TodoItem]()
    var doneTodoItems = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setConstraints()
        makeLoad()
    }

    private func makeLoad() {
        coreData.loadFromCoreData()

        todoItems = coreData.todoItems.sorted { $0.dateСreation > $1.dateСreation }
        removeDoneTodoItems()
        todoItems.append(TodoItem(text: "", importance: .basic, dateСreation: Date.distantPast))
        headerView.update(doneItemsCount: doneTodoItems.count)
    }

    private func setupViews() {
        view.backgroundColor = Resources.Colors.primaryBack
        view.addSubview(todoListTableView)
        view.addSubview(plusButton)

        headerView.change = { areDoneCellsHiden in
            if areDoneCellsHiden {
                self.removeDoneTodoItems()
                self.todoListTableView.reloadData()
            } else {
                self.addDoneItems()
                self.todoListTableView.reloadData()
            }
        }

        todoListTableView.dataSource = self
        todoListTableView.delegate = self

        setupNavBar()
    }

    private func setupNavBar() {
        title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func removeDoneTodoItems() {
        var todoItems = [TodoItem]()
        var doneTodoItems = [TodoItem]()
        if !self.todoItems.isEmpty {
            for item in self.todoItems {
                if item.isDone {
                    doneTodoItems.append(item)
                } else {
                    todoItems.append(item)
                }
            }
        }
        self.todoItems = todoItems.sorted { $0.dateСreation > $1.dateСreation }
        self.doneTodoItems = doneTodoItems.sorted { $0.dateСreation > $1.dateСreation }
    }

    private func addDoneItems() {
        var todoItems = self.todoItems

        doneTodoItems.isEmpty ? nil : doneTodoItems.forEach { todoItems.append($0) }
        self.todoItems = todoItems.sorted { $0.dateСreation > $1.dateСreation }
        doneTodoItems = []
    }

    func makeSave() {
        var todoItemsToSave = todoItems + doneTodoItems
        todoItemsToSave.sort(by: { $0.dateСreation > $1.dateСreation })
        todoItemsToSave.removeLast()
        coreData.saveToCoreData(items: todoItemsToSave)
        print("SAVE", coreData.todoItems)
    }

    func doneItemAction(_ index: Int) {
        todoItems[index].isDone = !todoItems[index].isDone

        if headerView.areDoneCellsHidden {
            if todoItems[index].isDone {
                doneTodoItems.append(todoItems[index])
                todoItems.remove(at: index)
                headerView.update(doneItemsCount: doneTodoItems.count)
            }
        } else {
            headerView.update(doneItemsCount: todoItems.filter { $0.isDone }.count )
        }
    }

    // MARK: - objc Methods
    @objc private func checkMarkButtonTap(sender: UIButton) {
        doneItemAction(sender.tag)
        makeSave()

        todoListTableView.reloadData()
    }

    @objc func tapPlusButton() {

        let newVC = TodoItemViewController()
        let navigationController = UINavigationController(rootViewController: newVC)
        navigationController.modalPresentationStyle = .formSheet

        newVC.dataCompletionHandler = { [self] data in
            if let todoItem = data {
                self.todoItems.append(todoItem)
                self.todoItems.sort(by: { $0.dateСreation > $1.dateСreation })
                self.todoListTableView.reloadData()

                makeSave()
            }
        }
        newVC.setupNavBar()
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoListCell.identifier,
            for: indexPath
        ) as? TodoListCell else { fatalError("Ошибка в создании ячейки") }

        cell.configure(for: todoItems[indexPath.row])
        cell.checkMarkButton.addTarget(self, action: #selector(self.checkMarkButtonTap), for: .touchUpInside)
        cell.checkMarkButton.tag = indexPath.row
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.todoItems[indexPath.row].dateСreation != .distantPast {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, handler in
                self.todoItems.remove(at: indexPath.row)
                self.headerView.update(doneItemsCount: self.todoItems.filter { $0.isDone }.count)
                let filteredTodoItemsCount = self.todoItems.filter { $0.isDone }.count
                self.headerView.update(
                    doneItemsCount: filteredTodoItemsCount == 0 ? self.doneTodoItems.count : filteredTodoItemsCount
                )
                self.makeSave()
                tableView.reloadData()
                handler(true)
            }
            deleteAction.image = Resources.Images.trashImage
            deleteAction.backgroundColor = Resources.Colors.redColor

            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.todoItems[indexPath.row].dateСreation != .distantPast {
            let doneAction = UIContextualAction(style: .normal, title: nil) { _, _, handler in
                self.doneItemAction(indexPath.row)
                self.makeSave()
                tableView.reloadData()
                handler(true)
            }
            doneAction.image = Resources.Images.fillCheckmarkCircle
            doneAction.backgroundColor = Resources.Colors.greenColor

            let configuration = UISwipeActionsConfiguration(actions: [doneAction])
            return configuration
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentTodoItem: TodoItem?

        if todoItems[indexPath.row].dateСreation == .distantPast {
            currentTodoItem = nil
        } else {
            currentTodoItem = todoItems[indexPath.row]
        }

        let newVC = TodoItemViewController(item: currentTodoItem)
        newVC.setupNavBar()

        let navigationController = UINavigationController(rootViewController: newVC)
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self

        newVC.dataCompletionHandler = { [weak self] item in
            guard let self = self else { return }

            if currentTodoItem != nil {
                if let item = item {
                    self.todoItems[indexPath.row] = item
                } else {
                    self.todoItems.remove(at: indexPath.row)
                }
            } else {
                if let item = item {
                    self.todoItems.append(item)
                }
            }
            self.todoItems.sort(by: { $0.dateСreation > $1.dateСreation })
            self.makeSave()

            let filteredTodoItemsCount = self.todoItems.filter { $0.isDone }.count
            self.headerView.update(
                doneItemsCount: filteredTodoItemsCount == 0 ? self.doneTodoItems.count : filteredTodoItemsCount
            )
            tableView.reloadData()
        }

        tableView.deselectRow(at: indexPath, animated: true)
        present(navigationController, animated: true, completion: nil)
    }
}

extension TodoListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            todoListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            todoListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            todoListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            todoListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
