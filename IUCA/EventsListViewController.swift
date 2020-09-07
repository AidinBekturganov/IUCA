//
//  EventsListViewController.swift
//  IUCA
//
//  Created by User on 8/27/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit

class EventsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var spots: Spots!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spots = Spots()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        spots.loadData {
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func cancelBarButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! DetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.spot = spots.spotArray[selectedIndexPath.row]
        }
    }
    
    
}

extension EventsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = spots.spotArray[indexPath.row].name
        
        return cell
    }
}
