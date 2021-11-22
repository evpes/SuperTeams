//
//  TeamDetailView.swift
//  SuperTeams
//
//  Created by evpes on 22.11.2021.
//

import UIKit

class TeamDetailView: UIView {

        var tableView: UITableView!
        var teamLabel: UILabel!
        var teamNameTextField: UITextField!
        var yourTeamLabel: UILabel!
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            createSubviews()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            createSubviews()
            
        }

        func createSubviews() {
            teamLabel = UILabel()
            teamLabel.text = "Team name:"
            teamLabel.textColor = UIColor.label
            self.addSubview(teamLabel)
            teamLabel.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide)
                make.left.equalTo(self).offset(20)
            }

            teamNameTextField = UITextField()
            self.addSubview(teamNameTextField)
            teamNameTextField.placeholder = "Enter name of your team"
            teamNameTextField.snp.makeConstraints { make in
                make.top.equalTo(teamLabel).offset(30)
                make.left.equalTo(self).offset(20)
                make.right.equalTo(self).offset(20)
            }

            yourTeamLabel = UILabel()
            self.addSubview(yourTeamLabel)
            yourTeamLabel.text = "Your team"
            yourTeamLabel.textAlignment = .center
            yourTeamLabel.snp.makeConstraints { make in
                make.top.equalTo(teamNameTextField).offset(40)
                make.left.equalTo(self)
                make.right.equalTo(self)
            }

            tableView = UITableView()
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Heroe")
            self.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(yourTeamLabel).offset(30)
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.bottom.equalTo(self)
            }
        }
}

