//
//  HeroeViewController.swift
//  SuperTeams
//
//  Created by evpes on 13.11.2021.
//

import UIKit

class HeroeViewController: UIViewController {
    
    var heroeView = HeroeView()
    
    var teamDetailVCDelagate: TeamDetailViewController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var heroeManager = HeroeManager()
    
    var team: Team!
    var isEdit: Bool = true
    var currentHeroe: Heroe?
    var heroeImagePath: String?
    var heroeEquip: String?
    
    let availableEquip = ["🔫","🪃","🥋","🗡","📙","💊","🔨","🔦"]
    
    let catchPhrases = ["I am your father","Hasta la vista, baby","I love the smell of napalm in the morning","Yippee ki yay, motherfucker","Release the Kraken!","I'll be back","THIS IS SPARTA!","Houston, we have a problem.",
                        "Suit up!","Oh my God, they killed Kenny","Bazinga!","I know kung fu.","You shall not pass!","How you doin?","A martini…shaken, not stirred.","To infinity…and beyond!","There can be only one."]
    
    override func loadView() {
        view = heroeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        
        heroeManager.delegate = self
        
        heroeView.avatarButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        
        heroeView.leaderSegmentedControl.addTarget(self, action: #selector(changeLeader), for: .valueChanged)
        if let heroe = currentHeroe {
            if heroe.isLeader {
                heroeView.leaderSegmentedControl.selectedSegmentIndex = 1
            }
        }
        
        heroeView.randomGenerateButton.addTarget(self, action: #selector(randomButtonPressed), for: .touchUpInside)
        
        for (index,item) in availableEquip.enumerated() {
            let equipButton = UIButton()
            equipButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            equipButton.setTitle(item, for: .normal)
            equipButton.tag = index
            equipButton.addTarget(self, action: #selector(equipButtonTapped), for: .touchUpInside)
            equipButton.layer.borderColor = UIColor.clear.cgColor
            equipButton.layer.cornerRadius = 5
            equipButton.layer.borderWidth = 2
            heroeView.addSubview(equipButton)
            heroeView.equipButtons.append(equipButton)
            equipButton.snp.makeConstraints { make in
                if index == 0 {
                    make.left.equalTo(heroeView).offset(30)
                } else {
                    make.left.equalTo(heroeView.equipButtons[index-1]).offset(40)
                }
                make.width.lessThanOrEqualTo(35)
                make.height.lessThanOrEqualTo(35)
                make.top.equalTo(heroeView.heroEquipLabel).offset(30)
            }
        }
        
        if isEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHeroe))
        } else {
            for button in heroeView.equipButtons {
                button.isHidden = true
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(switchToEditMode))
            heroeView.nameTextField.isUserInteractionEnabled = false
            heroeView.avatarButton.isUserInteractionEnabled = false
            heroeView.catchPhraseTextField.isUserInteractionEnabled = false
            heroeView.randomGenerateButton.isHidden = true
            heroeView.leaderSegmentedControl.isUserInteractionEnabled = false
        }
        
        if let heroe = currentHeroe {
            heroeEquip = heroe.equip
            heroeView.heroEquipLabel.text = heroeEquip
            heroeImagePath = heroe.imagePath
            if let  heroeEquipArr = heroeEquip?.components(separatedBy: ",") {
                for equipBtn in heroeView.equipButtons {
                    if heroeEquipArr.contains(equipBtn.titleLabel!.text!) {
                        equipBtn.isSelected = true
                        equipBtn.layer.borderColor = UIColor.green.cgColor
                    }
                }
            }
            
            heroeView.nameTextField.text = heroe.name
            heroeView.catchPhraseTextField.text = heroe.catchPhrase
            if let path = heroe.imagePath {
                heroeView.avatar.image = UIImage(contentsOfFile: path)
            }
        }
        
    }
    
    @objc func saveHeroe() {
        
        guard let heroeName = heroeView.nameTextField.text else { return }
        
        if heroeName.count == 0 {
            showError(err: HeroeError.emptyName)
            return
        } else if heroeImagePath == nil {
            showError(err: HeroeError.emptyAvatar)
            return
        } else if heroeView.catchPhraseTextField.text?.count == 0 {
            showError(err: HeroeError.emtyCatchPhrase)
            return
        }
        
        if heroeView.leaderSegmentedControl.selectedSegmentIndex == 1 {
            for heroe in team.heroes?.allObjects as! [Heroe] {
                heroe.isLeader = false
            }
        }
        
        if let heroe = currentHeroe {
            heroe.name = heroeName
            heroe.imagePath = heroeImagePath
            heroe.catchPhrase = heroeView.catchPhraseTextField.text
            heroe.isLeader = heroeView.leaderSegmentedControl.selectedSegmentIndex == 0 ? false : true
            heroe.equip = heroeEquip
        } else {
            let newHeroe = Heroe(context: context)
            newHeroe.name = heroeName
            newHeroe.parentCategory = team
            newHeroe.imagePath = heroeImagePath
            newHeroe.catchPhrase = heroeView.catchPhraseTextField.text
            newHeroe.isLeader = heroeView.leaderSegmentedControl.selectedSegmentIndex == 0 ? false : true
            newHeroe.equip = heroeEquip
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving heroe: \(error)")
        }
        
        teamDetailVCDelagate?.loadTeam()
        teamDetailVCDelagate?.detailView.tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func switchToEditMode() {
        for button in heroeView.equipButtons {
            button.isHidden = false
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHeroe))
        heroeView.nameTextField.isUserInteractionEnabled = true
        heroeView.avatarButton.isUserInteractionEnabled = true
        heroeView.catchPhraseTextField.isUserInteractionEnabled = true
        heroeView.randomGenerateButton.isHidden = false
        heroeView.leaderSegmentedControl.isUserInteractionEnabled = true
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func randomButtonPressed() {
        heroeView.catchPhraseTextField.text = catchPhrases[Int.random(in: 0..<catchPhrases.count)]
        heroeView.activityController.startAnimating()
        heroeManager.performRequest()
    }
    
    @objc func changeLeader(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
    }
    
    @objc func equipButtonTapped(sender: UIButton) {
        switch sender.isSelected {
        case true:
            sender.isSelected = false
            sender.layer.borderColor = UIColor.clear.cgColor
            
            var equipArr = heroeEquip?.components(separatedBy: ",") ?? []
            equipArr.remove(at: equipArr.firstIndex(of: sender.titleLabel!.text!)!)
            
            if equipArr.count > 0 {
                heroeEquip = equipArr.joined(separator: ",")
            } else {
                heroeEquip = nil
            }
            heroeView.heroEquipLabel.text = heroeEquip
            
        case false:
            sender.isSelected = true
            sender.layer.borderColor = UIColor.green.cgColor
            
            var equipArr = heroeEquip?.components(separatedBy: ",") ?? []
            equipArr.append(sender.titleLabel!.text!)
            
            heroeEquip = equipArr.joined(separator: ",")
            heroeView.heroEquipLabel.text = heroeEquip
            
        }
    }
    
    func showError(err: HeroeError) {
        var title = ""
        var message = ""
        
        switch err {
        case .emptyName:
            title = "Empty name"
            message = "Enter a name for your hero"
        case .emtyCatchPhrase:
            title = "Empty catch phrase"
            message = "Enter a catch phrase for your hero"
        case .emptyAvatar:
            title = "Empty avatar"
            message = "Select avatar for your hero"
        case .networkError:
            title = "Network error"
            message = "Some network error. Check Connection."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    
    
}

extension HeroeViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 1) {
            try? jpegData.write(to: imagePath)
        }
        
        heroeImagePath = imagePath.path
        heroeView.avatar.image = UIImage(contentsOfFile: imagePath.path)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension HeroeViewController: HeroeManagerDelegate {
    func updateHeroeName(heroe: HeroeData) {
        DispatchQueue.main.async {
            self.heroeView.nameTextField.text = heroe.name
        }
    }
    
    func failWithError(error: Error) {
        DispatchQueue.main.async {
            self.showError(err: HeroeError.networkError)
            self.heroeView.activityController.stopAnimating()
        }
    }
    
    func updateHeroeImage(imageData: Data) {
        DispatchQueue.main.async {
            self.heroeView.avatar.image = UIImage(data: imageData)
            self.saveImage()
            self.heroeView.activityController.stopAnimating()
        }
        
    }
    
    func saveImage() {
        guard let imageName = heroeView.nameTextField.text else { return }
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = heroeView.avatar.image?.jpegData(compressionQuality: 1) {
            try? jpegData.write(to: imagePath)
        }
        
        heroeImagePath = imagePath.path
    }
    
    
}

extension HeroeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

enum HeroeError {
    case emptyName
    case emtyCatchPhrase
    case emptyAvatar
    case networkError
}
