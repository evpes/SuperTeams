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
                
        for i in 0...2 {
            
            //let heroe = Heroe(context: "12")
            
            //let heroe = Heroe(name: "Keka\(i)", info: "Bla bla \(i)")
            //heroes.append(heroe)
        }
        

        
        
        teamLabel = UILabel()
        teamLabel.text = "Team name"
        view.addSubview(teamLabel)
        teamLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(60)
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
            content.textProperties.color = UIColor.black
        } else {
            content.text = "+ add new hero"
            content.textProperties.color = UIColor.black.withAlphaComponent(0.5)
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
        } else {
            //find a hero
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "") { action, view, handler in
            guard let team = self.team else { return }
            self.context.delete(self.heroes[indexPath.row])
            self.heroes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveData()
        }
        action.image = UIImage(systemName: "trash.circle")
        //action.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
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
        
        //let newTeam = Team(context: context)
        
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
          team = try context.existingObject(with: objectId) as! Team
            heroes = team?.heroes?.allObjects as! [Heroe]
            print(team?.heroes)
        } catch {
            print("Error loading team: \(error)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
