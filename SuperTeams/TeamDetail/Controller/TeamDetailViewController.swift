//
//  TeamDetailViewController.swift
//  SuperTeams
//
//  Created by evpes on 13.11.2021.
//

import UIKit
import SnapKit
import CoreData

class TeamDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var detailView = TeamDetailView()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var teamsVCDelagate: TeamsTableViewController?
    var team: Team?
    var heroes: [Heroe] = []
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTeam))
                
          detailView.teamNameTextField.delegate = self
          detailView.tableView.dataSource = self
          detailView.tableView.delegate = self

        if let team = team {
            print(team)
            print(team.name!)
            detailView.teamNameTextField.text = team.name!
            heroes = team.heroes?.allObjects as! [Heroe]
        } else {
            team = Team(context: context)
        }
        
        view.backgroundColor = UIColor.systemBackground
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        heroes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Heroe", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if indexPath.row < heroes.count {
            content.text = heroes[indexPath.row].name
            content.textProperties.color = UIColor.label
            if heroes[indexPath.row].isLeader {
                content.secondaryText = "⭐️ Leader"
            }
            
        } else {
            content.text = "+ add new hero"
            content.textProperties.color = UIColor.label.withAlphaComponent(0.5)
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = HeroeViewController()
        vc.team = team
        vc.teamDetailVCDelagate = self
        
        if indexPath.row < heroes.count {
            //open heroe details
            vc.isEdit = false
            vc.currentHeroe = heroes[indexPath.row]
        } else {
            //find a hero
            vc.isEdit = true
        }
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "") { action, view, handler in
            
            self.context.delete(self.heroes[indexPath.row])
            self.heroes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveData()
        }
        action.image = UIImage(systemName: "trash.circle")
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving team: \(error)")
        }
    }
    
    @objc func saveTeam() {
        guard let teamName = detailView.teamNameTextField.text else { return }
        let leader = heroes.filter { heroe in
            heroe.isLeader
        }
        if teamName.count == 0 {
            showError(err: TeamError.emptyName)
            return
        } else if heroes.count < 3 {
            showError(err: TeamError.tooSmall)
            return
        } else if leader.isEmpty {
            showError(err: TeamError.noLeader)
            return
        }
        
        team?.name = teamName
        
        do {
            try context.save()
        } catch {
            print("Error saving team: \(error)")
        }
        
        teamsVCDelagate?.loadTeams()
        teamsVCDelagate?.tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
    
    func loadTeam() {
        guard let objectId = team?.objectID else { print("return"); return }
        do {
            team = try context.existingObject(with: objectId) as? Team
            heroes = team?.heroes?.allObjects as! [Heroe]
        } catch {
            print("Error loading team: \(error)")
        }
    }
    
    func showError(err: TeamError) {
        var title = ""
        var message = ""
        
        switch err {
        case .tooSmall:
            title = "Small team"
            message = "Your team is too small, your team must have at least 3 members"
        case .emptyName:
            title = "Empty team name"
            message = "In order for the team to be created, you need to give it a name"
        case .noLeader:
            title = "No leader"
            message = "Your team needs a leader, you need to put the leader attribute on the hero page"
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
}

extension TeamDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

enum TeamError {
    case tooSmall
    case emptyName
    case noLeader
}
