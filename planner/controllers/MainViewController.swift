//
//  ViewController.swift
//  planner
//
//  Created by Daniil Subbotin on 30/06/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var filterControl: HeaderFilterControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskCountLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var completedPredicate: NSPredicate?
    var uncompletedPredicate: NSPredicate?
    var fetchController: NSFetchedResultsController<Task>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterControl.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 100, right: 0)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        fetchData()
    }
    
    private func fetchData() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        uncompletedPredicate = NSPredicate(format: "isDone == %@", NSNumber(booleanLiteral: false))
        completedPredicate = NSPredicate(format: "isDone == %@", NSNumber(booleanLiteral: true))
        
        request.predicate = uncompletedPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataStack.shared.viewContent,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchController?.delegate = self
        
        do {
            try fetchController?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TaskViewController, let indexPath = tableView.indexPathForSelectedRow {
            vc.mode = .edit
            
            guard let task = fetchController?.object(at: indexPath) as Task? else {
                return
            }
            
            vc.taskToEdit = task
        }
    }
    
    @IBAction func backFromTask(segue: UIStoryboardSegue) {
        
    }
}
    
extension MainViewController: FilterDelegate {
    
    func filterDidChanged(filterValue: TaskFilterType) {
        
        if filterValue == .unchecked {
            fetchController?.fetchRequest.predicate = uncompletedPredicate
            emptyLabel.text = "Предстоящих задач нет.\nНажмите «+» чтобы добавить новую задачу."
        } else {
            fetchController?.fetchRequest.predicate = completedPredicate
            emptyLabel.text = "Выполненных задач нет.\nНажмите «+» чтобы добавить новую задачу."
        }
        
        do {
            try fetchController?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        tableView.reloadData()
    }
    
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
            if let task = fetchController?.object(at: indexPath) as Task? {
                
                task.isDone = !task.isDone
                cell.update()
                
                if let id = task.notificationID, task.isDone {
                    LocalNotificationHelper.cancel(id)
                }
                
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .destructive, title: "Удалить", handler: removeRow)
        return [removeAction]
    }
    
    func removeRow(action: UITableViewRowAction, at indexPath: IndexPath) {
        if let frc = fetchController {
            let task: Task = frc.object(at: indexPath)
            if let id = task.notificationID {
                LocalNotificationHelper.cancel(id)
            }
            CoreDataStack.shared.viewContent.delete(task)
            CoreDataStack.shared.saveContext()
        }
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController!.viewControllers.count > 1 {
            return true
        }
        return false
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchController?.sections else {
            fatalError("No sections in fetchController")
        }
        let sectionInfo = sections[section]
        
        taskCountLabel.text = String(sectionInfo.numberOfObjects)
        
        emptyLabel.isHidden = sectionInfo.numberOfObjects != 0
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "task_cell", for: indexPath) as? TaskTableViewCell
        
        guard let task = fetchController?.object(at: indexPath) as Task? else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell?.delegate = self
        
        cell?.task = task
        
        return cell!
    }
    
}

extension MainViewController: TaskCellCheckDelegate {
    func checkToggle(cell: UITableViewCell) {
        let indexPath: NSIndexPath = tableView.indexPath(for: cell)! as NSIndexPath
        tableView.delegate?.tableView!(tableView, accessoryButtonTappedForRowWith: indexPath as IndexPath)
    }
}
