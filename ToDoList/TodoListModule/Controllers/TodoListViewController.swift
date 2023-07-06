import UIKit
import TodoItem

class TodoListViewController: UIViewController {

    private let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
    lazy var todoListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.tableHeaderView = headerView
        tableView.backgroundColor = Resources.Colors.primaryBack
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let fileCashe = FileCache()
    var todoItems = [TodoItem]()
    var doneTodoItems = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setConstraints()
        makeLoad()
    }

    private func makeLoad() {
        do {
            try fileCashe.loadFromJSON(file: Resources.Text.mainDataBaseFileName)
        } catch {
            print("Ошибка загрузки данных")
        }

        todoItems = fileCashe.returnTodoItemArray().sorted { $0.dateСreation > $1.dateСreation }
        removeDoneTodoItems()
        headerView.update(doneItemsCount: doneTodoItems.count)
        todoItems.append(TodoItem(text: "", importance: .normal, dateСreation: Date.distantPast))
    }

    private func setupViews() {
        view.backgroundColor = Resources.Colors.primaryBack
        view.addSubview(todoListTableView)

//        headerView.change = { areDoneCellsHiden in
//            if areDoneCellsHiden {
//                self.removeDoneTodoItems()
//                self.tableView.reloadData()
//            } else {
//                self.addDoneItems()
//                self.tableView.reloadData()
//            }
//        }

        if headerView.areDoneCellsHidden {
            removeDoneTodoItems()
            todoListTableView.reloadData()
        } else {
            addDoneItems()
            todoListTableView.reloadData()
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
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoListCell.identifier,
            for: indexPath
        ) as? TodoListCell else { return UITableViewCell() }

        return cell
    }
}

extension TodoListViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            todoListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            todoListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            todoListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            todoListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
