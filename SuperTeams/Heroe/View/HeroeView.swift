//
//  HeroeView.swift
//  SuperTeams
//
//  Created by evpes on 22.11.2021.
//

import UIKit

class HeroeView: UIView {

    var avatar: UIImageView!
    var nameLabel: UILabel!
    var nameTextField: UITextField!
    var catchPhraseLabel: UILabel!
    var catchPhraseTextField: UITextField!
    var avatarButton: UIButton!
    var leaderSegmentedControl: UISegmentedControl!
    var equipLabel: UILabel!
    var heroEquipLabel: UILabel!
    var randomGenerateButton: UIButton!
    var activityController: UIActivityIndicatorView!
    
    var equipButtons: [UIButton] = []
    
    //var delegate: HeroeViewController
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            createSubviews()
        print("init")
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            createSubviews()
            print("init2")
        }
    

    
        func createSubviews() {
            print("createSubviews")
            
            self.backgroundColor = UIColor.systemBackground
            
            avatar = UIImageView()
            avatar.layer.cornerRadius = 50
            avatar.layer.borderWidth = 3
            avatar.layer.borderColor = UIColor.label.withAlphaComponent(0.5).cgColor
            self.addSubview(avatar)
            avatar.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide)
                make.width.lessThanOrEqualTo(120)
                make.height.lessThanOrEqualTo(120)
                make.centerX.equalTo(self)
            }
            avatar.contentMode = .scaleAspectFill
            avatar.clipsToBounds = true
            
            avatarButton = UIButton()
 
            avatarButton.layer.cornerRadius = 50
            self.addSubview(avatarButton)
            avatarButton.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide)
                make.width.greaterThanOrEqualTo(100)
                make.height.greaterThanOrEqualTo(100)
                make.centerX.equalTo(self)
            }
            
            nameLabel = UILabel()
            nameLabel.text = "Name:"
            self.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(avatar).offset(150)
                make.left.equalTo(self).offset(20)
            }
            
            nameTextField = UITextField()
            //nameTextField.delegate = self
            nameTextField.placeholder = "Heroe name"
            self.addSubview(nameTextField)
            nameTextField.snp.makeConstraints { make in
                make.top.equalTo(nameLabel).offset(30)
                make.left.equalTo(self).offset(20)
            }
            
            catchPhraseLabel = UILabel()
            catchPhraseLabel.text = "Catch phrase:"
            self.addSubview(catchPhraseLabel)
            catchPhraseLabel.snp.makeConstraints { make in
                make.top.equalTo(nameTextField).offset(30)
                make.left.equalTo(self).offset(20)
            }
            
            catchPhraseTextField = UITextField()
            //catchPhraseTextField.delegate = self
            catchPhraseTextField.placeholder = "Enter catch phrase for this heroe"
            self.addSubview(catchPhraseTextField)
            catchPhraseTextField.snp.makeConstraints { make in
                make.top.equalTo(catchPhraseLabel).offset(30)
                make.left.equalTo(self).offset(20)
            }
            
            let items = ["Regular", "Leader"]
            leaderSegmentedControl = UISegmentedControl(items: items)

            leaderSegmentedControl.selectedSegmentIndex = 0
            self.addSubview(leaderSegmentedControl)
            leaderSegmentedControl.snp.makeConstraints { make in
                make.top.equalTo(catchPhraseTextField).offset(30)
                make.left.equalTo(self).offset(20)
            }
            
            equipLabel = UILabel()
            equipLabel.text = "Heroe equip:"
            self.addSubview(equipLabel)
            equipLabel.snp.makeConstraints { make in
                make.top.equalTo(leaderSegmentedControl).offset(40)
                make.left.equalTo(self).offset(20)
            }
            
            heroEquipLabel = UILabel()
            self.addSubview(heroEquipLabel)
            heroEquipLabel.snp.makeConstraints { make in
                make.top.equalTo(equipLabel).offset(30)
                make.left.equalTo(self).offset(20)
            }
            
            activityController = UIActivityIndicatorView()
            activityController.color = UIColor.label
            self.addSubview(activityController)
            activityController.snp.makeConstraints { make in
                make.center.equalTo(avatar)
            }
            
            

            
            randomGenerateButton = UIButton()
            
            randomGenerateButton.layer.cornerRadius = 10
            randomGenerateButton.titleLabel?.textColor = .black
            randomGenerateButton.setTitle("Random generate heroe", for: .normal)
            randomGenerateButton.backgroundColor = UIColor.label
            self.addSubview(randomGenerateButton)
            randomGenerateButton.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-30)
                make.width.greaterThanOrEqualTo(220)
                make.height.greaterThanOrEqualTo(60)
                make.centerX.equalTo(self)
            }
            
        }

}
