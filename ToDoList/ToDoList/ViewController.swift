//
//  ViewController.swift
//  ToDoList
//
//  Created by Davide Cidu on 25/06/2026.
//

import UIKit


class MyCell : UITableViewCell{
    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var doBtn: UIButton!
}




class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var numbers = [Int]()
    //var refCon = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.tableView.refreshControl = refCon
        //refCon.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        for _ in 0..<30 {
            numbers.append(Int(arc4random()))
        }
        
        
    }
    
    @objc
    func refreshTable(){
        //refCon.endRefreshing()
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    /*
     func numberOfSections(in tableView: UITableView) -> Int {
         4
     }
     */
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count //sarebbe il numero degli elementi dell'array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cellThing", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellThing", for: indexPath)
        
        if let cell = cell as? MyCell {
            cell.lbl.text = Date().formatted()
        } else {
            var config = cell.defaultContentConfiguration()
            config.text = "\(numbers[indexPath.row])"
            config.secondaryText = Date().formatted()
            cell.contentConfiguration = config
        }
        
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let del = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            self.numbers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [del])
    }
}

