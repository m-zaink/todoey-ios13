//
//  ViewController.swift
//  Todoey
//
//  Created by Mohammed Sadiq on 22/11/20.
//

import UIKit

class ToDoListViewController: UITableViewController {
    static let toDoListCellReuseIdentifier = "ToDoListCell"
    
    var todos = [
        "Bring Super Siyan",
        "Eat more healthy food",
        "Keep talking"
    ]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    @IBAction func onAddTodoItemPressed(_ sender: UIBarButtonItem) {
        var todoTextField: UITextField?
        
        let addTodoItemAlert = UIAlertController(
            title: "Add a ToDoey Item",
            message: "",
            preferredStyle: .alert
        )
        
        addTodoItemAlert.addTextField {
            (textField) in
            textField.placeholder = "ToDo goes here"
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
                    
                    if let todo = todoTextField?.text, todo.isNotEmpty {
                        self.todos.append(todo)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ToDoListViewController.toDoListCellReuseIdentifier,
            for: indexPath
        )
        
        cell.textLabel?.text = todos[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(
            at: indexPath
        )
        
        if selectedCell?.accessoryType == .checkmark {
            selectedCell?.accessoryType = .none
        } else {
            selectedCell?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { (deleteAction, uiView, success) in
            self.todos.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            success(true)
        }
        
        return UISwipeActionsConfiguration(
            actions: [
                deleteAction
            ]
        )
    }
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
