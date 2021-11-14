//
//  ViewController.swift
//  SuperTeams
//
//  Created by evpes on 11.11.2021.
//

import UIKit
import CoreData

class TeamsTableViewController: UITableViewController {

    var teams: [Team] = []
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTeams()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTeam))
        navigationItem.title = "SuperTeams"
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TeamDetail") as? TeamDetailViewController {
            vc.teamsVCDelagate = self
            vc.team = teams[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Team", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = team.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "") { action, view, handler in
            self.context.delete(self.teams[indexPath.row])
            self.teams.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveData()
        }
        action.image = UIImage(systemName: "trash.circle")
        //action.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    @objc func addNewTeam() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TeamDetail") as? TeamDetailViewController {
            vc.teamsVCDelagate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving team: \(error)")
        }
    }
    
    func loadTeams() {
        
        let request : NSFetchRequest<Team> = Team.fetchRequest()
        do {
            teams = try context.fetch(request)
        } catch {
            print("Error loading teams: \(error)")
        }
    }


}

