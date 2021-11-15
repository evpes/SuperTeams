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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var teamsVCDelagate: TeamsTableViewController?
    var team: Team?
    var heroes: [Heroe] = []
    
    var tableView: UITableView!
    var teamLabel: UILabel!
    var teamNameTextField: UITextField!
    var yourTeamLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTeam))
                
        teamLabel = UILabel()
        teamLabel.text = "Team name:"
        teamLabel.textColor = UIColor.label
        view.addSubview(teamLabel)
        teamLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view).offset(20)
        }
        
        teamNameTextField = UITextField()
        view.addSubview(teamNameTextField)
        teamNameTextField.placeholder = "Enter name of your team"
        teamNameTextField.snp.makeConstraints { make in
            make.top.equalTo(teamLabel).offset(30)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(20)
        }
        
        yourTeamLabel = UILabel()
        view.addSubview(yourTeamLabel)
        yourTeamLabel.text = "Your team"
        yourTeamLabel.textAlignment = .center
        yourTeamLabel.snp.makeConstraints { make in
            make.top.equalTo(teamNameTextField).offset(40)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Heroe")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(yourTeamLabel).offset(30)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        if let team = team {
            print(team)
            print(team.name!)
            teamNameTextField.text = team.name!
            heroes = team.heroes?.allObjects as! [Heroe]
        } else {
            team = Team(context: context)
        }
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
                content.secondaryText = "Leader"
            }
            
        } else {
            content.text = "+ add new hero"
            content.textProperties.color = UIColor.label.withAlphaComponent(0.5)
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Heroe") as! HeroeViewController
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
        guard let teamName = teamNameTextField.text else { return }
        if teamName.count == 0 {
            showError(err: TeamError.emptyName)
            return
        } else if heroes.count < 3 {
            showError(err: TeamError.tooSmall)
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
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
}

enum TeamError {
    case tooSmall
    case emptyName
}
