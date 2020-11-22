//
//  ViewController.swift
//  Todoey
//
//  Created by Mohammed Sadiq on 22/11/20.
//

import UIKit

class TodoListViewController: UITableViewController {
    static let toDoListCellReuseIdentifier = "ToDoListCell"
    
    let todos = [
        "Bring Super Siyan",
        "Eat more healthy food",
        "Keep talking"
    ]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoListViewController.toDoListCellReuseIdentifier,
            for: indexPath
        )
        
        cell.textLabel?.text = todos[indexPath.row]
        
        return cell
    }
}

