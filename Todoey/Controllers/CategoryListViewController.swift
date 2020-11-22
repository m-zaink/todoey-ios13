//
//  CategoryListTableViewController.swift
//  Todoey
//
//  Created by Mohammed Sadiq on 22/11/20.
//

import UIKit
import CoreData

class CategoryListViewController: UITableViewController {
    static let categoryListCellReuseIdentifier = "CategoryListCell"
    static let segueToToDoListVC = "SegueToToDoListVC"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveAllToDosFromPersistentStorage()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    @IBAction func onAddButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField: UITextField?
        
        let addToDoItemAlert = UIAlertController(
            title: "Add a ToDoey Category",
            message: "",
            preferredStyle: .alert
        )
        
        addToDoItemAlert.addTextField {
            (textField) in
            textField.placeholder = "Category name goes here"
            textField.autocapitalizationType = .sentences
            categoryTextField = textField
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
                    
                    if let categoryName = categoryTextField?.text, categoryName.isNotEmpty {
                        let category = Category(context: self.context)
                        
                        category.name = categoryName
                        
                        self.categories.append(category)
                        
                        self.commitCategoriesInPersistentStorage()
                        
                        self.tableView.insertRows(
                            at: [
                                IndexPath(
                                    row: self.categories.count - 1,
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CategoryListViewController.segueToToDoListVC {
            if let toDoListVC = segue.destination as? ToDoListViewController, let selectIndexPath = tableView.indexPathForSelectedRow {
                toDoListVC.parentCategory = categories[selectIndexPath.row]
            }
        }
    }
    
    func commitCategoriesInPersistentStorage() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print(error)
        }
    }
    
    func retrieveAllToDosFromPersistentStorage() {
        let allCategoriesRequest: NSFetchRequest<Category> = Category.fetchRequest()
        retrieveCategoriesFromPersistentStorage(request: allCategoriesRequest)
    }
    
    func retrieveAllToDosFromPersistentStroage(baseOn searchWord: String) {
        let searchQueryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        searchQueryRequest.predicate = NSPredicate(
            format: "title CONTAINS[cd] %@",
            searchWord
        )
        
        searchQueryRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        retrieveCategoriesFromPersistentStorage(request: searchQueryRequest)
    }
    
    func retrieveCategoriesFromPersistentStorage(request: NSFetchRequest<Category>) {
        do {
            categories = try context.fetch(request)
        } catch {
            print(error)
        }
    }
}

// MARK: - TableViewDataSource
extension CategoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(
            withIdentifier: CategoryListViewController.categoryListCellReuseIdentifier,
            for: indexPath
        )
        
        categoryCell.textLabel?.text = categories[indexPath.row].name
        
        return categoryCell
    }
}

// MARK: - TableViewUIDelegate
extension CategoryListViewController {
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: CategoryListViewController.segueToToDoListVC,
            sender: self
        )
        
        tableView.deselectRow(
            at: indexPath,
            animated: true
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
                title: "Are you sure you want to delete this category?",
                message: self.categories[indexPath.row].name,
                preferredStyle: .actionSheet
            )
            
            confirmDeleteAlert.addAction(
                UIAlertAction(
                    title: "Yes",
                    style: .destructive,
                    handler: { (deleteAction) in
                        self.context.delete(self.categories[indexPath.row])
                        self.categories.remove(at: indexPath.row)
                        self.commitCategoriesInPersistentStorage()
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
