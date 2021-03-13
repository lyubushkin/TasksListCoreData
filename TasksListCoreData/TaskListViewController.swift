//
//  TaskListViewController.swift
//  TasksListCoreData
//
//  Created by Swift on 13.03.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "cell"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Bar Appearence
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do")
    }
    
    private func fetchData() {
        do {
            taskList = try context.fetch(StorageManager.shared.fetchRequest())
            tableView.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showEditTaskAlert(with title: String, and message: String, indexPath: IndexPath) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
             guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
             self.edit(task, indexPath)
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
         alert.addTextField()
         alert.textFields?.first?.text = taskList[indexPath.row].name
         alert.addAction(editAction)
         alert.addAction(cancelAction)
         present(alert, animated: true)
     }
    
    private func save(_ taskName: String) {
        guard let task = StorageManager.shared.getTask() else { return }
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func edit(_ taskName: String, _ indexPath: IndexPath) {
        StorageManager.shared.deleteTask(taskList[indexPath.row])
        guard let task = StorageManager.shared.saveContext(taskName) else { return }
        taskList[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

// MARK: - Table View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = taskList[indexPath.row]
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                StorageManager.shared.deleteTask(taskList[indexPath.row])
                taskList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else { return }
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showEditTaskAlert(with: "Edit Task", and: "You may edit curent task...", indexPath: indexPath)
    }
}
