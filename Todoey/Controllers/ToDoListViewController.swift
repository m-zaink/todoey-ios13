//
//  ViewController.swift
//  Todoey
//
//  Created by Mohammed Sadiq on 22/11/20.
//

import UIKit

class ToDoListViewController: UITableViewController {
    static let toDoListCellReuseIdentifier = "ToDoListCell"
    static let toDoListUserDefaultsKey = "ToDoListUserDefaultsKey"
    static let toDoPListPath = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first?.appendingPathComponent("ToDos.plist")
    
    var todos: [ToDo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshToDosFromUserDefaults()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @IBAction func onAddTodoItemPressed(
        _ sender: UIBarButtonItem
    ) {
        var todoTextField: UITextField?
        
        let addTodoItemAlert = UIAlertController(
            title: "Add a ToDoey Item",
            message: "",
            preferredStyle: .alert
        )
        
        addTodoItemAlert.addTextField {
            (textField) in
            textField.placeholder = "ToDo goes here"
            textField.autocapitalizationType = .sentences
            todoTextField = textField
        }
        
        addTodoItemAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        addTodoItemAlert.addAction(
            UIAlertAction(
                title: "Add ToDo",
                style: .default,
                handler: {
                    (addTodoAction) in
                    
                    if let todoTitle = todoTextField?.text, todoTitle.isNotEmpty {
                        self.todos.append(ToDo(title: todoTitle))
                        self.saveCurrentStateOfToDosToUserDefaults()
                        self.tableView.insertRows(
                            at: [
                                IndexPath(
                                    row: self.todos.count - 1,
                                    section: 0
                                )
                            ],
                            with: .automatic
                        )
                    }
                }
            )
        )
        
        present(
            addTodoItemAlert,
            animated: true,
            completion: nil
        )
    }
    
    func saveCurrentStateOfToDosToUserDefaults() {
        if let toDoPListPath = ToDoListViewController.toDoPListPath {
            let encoder = PropertyListEncoder()
            
            do {
                let encodedData = try encoder.encode(todos)
                try encodedData.write(
                    to: toDoPListPath
                )
            } catch {
                print(error)
            }
        }
    }
    
    func refreshToDosFromUserDefaults() {
        if let toDoPListPath = ToDoListViewController.toDoPListPath {
            let decoder = PropertyListDecoder()
            
            do {
                let todoEncodedData = try Data(contentsOf: toDoPListPath)
                todos = try decoder.decode(
                    [ToDo].self, from: todoEncodedData
                )
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - TableViewDataSource
extension ToDoListViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return todos.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoListViewController.toDoListCellReuseIdentifier,
            for: indexPath
        )
        
        cell.textLabel?.text = todos[indexPath.row].title
        cell.accessoryType = todos[indexPath.row].isDone ? .checkmark : .none
        
        return cell
    }
}

// MARK: - TableViewUIDelegate
extension ToDoListViewController {
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { (deleteAction, uiView, success) in
            
            let confirmDeleteAlert = UIAlertController(
                title: "Are you sure you want to delete?",
                message: self.todos[indexPath.row].title,
                preferredStyle: .actionSheet
            )
            
            confirmDeleteAlert.addAction(
                UIAlertAction(
                    title: "Yes",
                    style: .destructive,
                    handler: { (deleteAction) in
                        self.todos.remove(at: indexPath.row)
                        self.saveCurrentStateOfToDosToUserDefaults()
                        success(true)
                        self.tableView.deleteRows(
                            at: [indexPath],
                            with: .left
                        )
                    }
                )
            )
            
            confirmDeleteAlert.addAction(
                UIAlertAction(
                    title: "No",
                    style: .cancel,
                    handler: { (cancelAction) in
                        success(false)
                    }
                )
            )
            
            self.present(
                confirmDeleteAlert,
                animated: true,
                completion: nil
            )
        }
        
        return UISwipeActionsConfiguration(
            actions: [
                deleteAction
            ]
        )
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        todos[indexPath.row].isDone = !todos[indexPath.row].isDone
        
        saveCurrentStateOfToDosToUserDefaults()
        
        tableView.reloadRows(
            at: [
                indexPath
            ],
            with: .none
        )
    }
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
