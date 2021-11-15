//
//  ViewController.swift
//  SuperTeams
//
//  Created by evpes on 11.11.2021.
//

import UIKit
import CoreData

class TeamsTableViewController: UITableViewController  {
    
    var teams: [Team] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTeams()
        
        let addNewTeamBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTeam))
        let deleteAllBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAllTeams))
        navigationItem.rightBarButtonItems = [deleteAllBarButtonItem, addNewTeamBarButtonItem]
                
        navigationItem.title = "SuperTeams"
                
        let handler: (_ action: UIAction) -> () = { action in
          print(action.identifier)
          switch action.identifier.rawValue {
          case "a...z":
              self.teams = self.teams.sorted() { $1.name! > $0.name! }
          case "z...a":
              self.teams = self.teams.sorted() { $0.name! > $1.name! }
          default:
            break
          }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let actions = [
             UIAction(title: "a...z", identifier: UIAction.Identifier("a...z"), handler: handler),
             UIAction(title: "z...a", identifier: UIAction.Identifier("z...a"), handler: handler)
         ]
        
        let menu = UIMenu(title: "", options: .singleSelection, children: actions)
        
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = false
        searchBar.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "sort", menu: menu)
        
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
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Team", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let team = teams[indexPath.row]
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
            self.tableView.reloadData()
        }
        action.image = UIImage(systemName: "trash.circle")
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
        
    }
    
    @objc func addNewTeam() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TeamDetail") as? TeamDetailViewController {
            vc.teamsVCDelagate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func deleteAllTeams() {
        let ac = UIAlertController(title: "Delete all teams", message: "Are you sure you want to delete all teams ", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes, delete all teams", style: .default, handler: { [unowned self] _ in
            for team in self.teams {
                self.context.delete(team)
            }
            self.teams.removeAll()
            self.saveData()
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        
        

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

extension TeamsTableViewController: UISearchBarDelegate {

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        if searchText.isEmpty {
            loadTeams()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            let request : NSFetchRequest<Team> = Team.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS [cd] %@", argumentArray: [searchText])
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            do {
                teams = try context.fetch(request)
            } catch {
                print("Error fetching request: \(error)")
            }
            tableView.reloadData()
        }
    }
}

