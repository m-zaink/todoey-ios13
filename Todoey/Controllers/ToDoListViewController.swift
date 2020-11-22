//
//  ViewController.swift
//  Todoey
//
//  Created by Mohammed Sadiq on 22/11/20.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    static let toDoListCellReuseIdentifier = "ToDoListCell"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var parentCategory: Category! {
        didSet(parentCategory) {
            retrieveAllToDosFromPersistentStorage()
        }
    }
    
    var todos: [ToDo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = parentCategory.name
    }
    
    @IBAction func onAddTodoItemPressed(
        _ sender: UIBarButtonItem
    ) {
        var todoTextField: UITextField?
        
        let addToDoItemAlert = UIAlertController(
            title: "Add a ToDoey Item",
            message: "",
            preferredStyle: .alert
        )
        
        addToDoItemAlert.addTextField {
            (textField) in
            textField.placeholder = "ToDo goes here"
            textField.autocapitalizationType = .sentences
            todoTextField = textField
        }
        
        addToDoItemAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        addToDoItemAlert.addAction(
            UIAlertAction(
                title: "Add ToDo",
                style: .default,
                handler: {
                    (addTodoAction) in
                    
                    if let todoTitle = todoTextField?.text, todoTitle.isNotEmpty {
                        let todo = ToDo(context: self.context)
                        
                        todo.title = todoTitle
                        todo.parentCategory = self.parentCategory
                        
                        self.todos.append(todo)
                        
                        self.commitToDosInPersistentStorage()
                        
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
            addToDoItemAlert,
            animated: true,
            completion: nil
        )
    }
    
    func commitToDosInPersistentStorage() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print(error)
        }
    }
    
    func retrieveAllToDosFromPersistentStorage() {
        let allToDosRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        allToDosRequest.predicate = categoryPredicate
        
        retrieveToDosFromPersistentStorage(request: allToDosRequest)
    }
    
    func retrieveAllToDosFromPersistentStroage(baseOn searchWord: String) {
        let searchQueryRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        searchQueryRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                categoryPredicate,
                NSPredicate(
                    format: "title CONTAINS[cd] %@",
                    searchWord
                )
            ]
        )
        
        searchQueryRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        retrieveToDosFromPersistentStorage(request: searchQueryRequest)
    }
    
    func retrieveToDosFromPersistentStorage(request: NSFetchRequest<ToDo>) {

        do {
            todos = try context.fetch(request)
        } catch {
            print(error)
        }
    }
    
    var categoryPredicate: NSPredicate {
        return NSPredicate(
            format: "parentCategory.name MATCHES %@",
            parentCategory.name!
        )
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
        didSelectRowAt indexPath: IndexPath
    ) {
        todos[indexPath.row].isDone = !todos[indexPath.row].isDone
        
        commitToDosInPersistentStorage()
        
        tableView.reloadRows(
            at: [indexPath],
            with: .none
        )
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
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
                        self.context.delete(self.todos[indexPath.row])
                        self.todos.remove(at: indexPath.row)
                        self.commitToDosInPersistentStorage()
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
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchWord = searchBar.text, searchWord.isNotEmpty {
            retrieveAllToDosFromPersistentStroage(baseOn: searchWord)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        retrieveAllToDosFromPersistentStorage()
        DispatchQueue.main.async {
            searchBar.text = ""
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchWord = searchBar.text, searchWord.isNotEmpty {
            retrieveAllToDosFromPersistentStroage(baseOn: searchWord)
        } else {
            retrieveAllToDosFromPersistentStorage()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

