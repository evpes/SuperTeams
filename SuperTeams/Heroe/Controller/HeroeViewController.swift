//
//  HeroeViewController.swift
//  SuperTeams
//
//  Created by evpes on 13.11.2021.
//

import UIKit

class HeroeViewController: UIViewController {
    
    var teamDetailVCDelagate: TeamDetailViewController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var heroeManager = HeroeManager()
    
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
    
    var equipButtons: [UIButton] = []
    
    var team: Team!
    var isEdit: Bool = true
    var currentHeroe: Heroe?
    var heroeImagePath: String?
    var heroeEquip: String?
    
    let availableEquip = ["🔫","🪃","🥋","🗡","📙","💊","🔨","🔦"]
    
    let catchPhrases = ["I am your father","Hasta la vista, baby","I love the smell of napalm in the morning","Yippee ki yay, motherfucker","Release the Kraken!","I'll be back","THIS IS SPARTA!","Houston, we have a problem.",
                        "Suit up!","Oh my God, they killed Kenny","Bazinga!","I know kung fu.","You shall not pass!","How you doin?","A martini…shaken, not stirred.","To infinity…and beyond!","There can be only one."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroeManager.delegate = self
        
        avatar = UIImageView()
        avatar.layer.cornerRadius = 50
        avatar.layer.borderWidth = 3
        avatar.layer.borderColor = UIColor.label.withAlphaComponent(0.5).cgColor
        view.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.lessThanOrEqualTo(120)
            make.height.lessThanOrEqualTo(120)
            make.centerX.equalTo(view)
        }
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        
        avatarButton = UIButton()
        avatarButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        avatarButton.layer.cornerRadius = 50
        view.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.greaterThanOrEqualTo(100)
            make.height.greaterThanOrEqualTo(100)
            make.centerX.equalTo(view)
        }
        
        nameLabel = UILabel()
        nameLabel.text = "Name:"
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar).offset(150)
            make.left.equalTo(view).offset(20)
        }
        
        nameTextField = UITextField()
        nameTextField.placeholder = "Heroe name"
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel).offset(30)
            make.left.equalTo(view).offset(20)
        }
        
        catchPhraseLabel = UILabel()
        catchPhraseLabel.text = "Catch phrase:"
        view.addSubview(catchPhraseLabel)
        catchPhraseLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField).offset(30)
            make.left.equalTo(view).offset(20)
        }
        
        catchPhraseTextField = UITextField()
        catchPhraseTextField.placeholder = "Enter catch phrase for this heroe"
        view.addSubview(catchPhraseTextField)
        catchPhraseTextField.snp.makeConstraints { make in
            make.top.equalTo(catchPhraseLabel).offset(30)
            make.left.equalTo(view).offset(20)
        }
        
        let items = ["Regular", "Leader"]
        leaderSegmentedControl = UISegmentedControl(items: items)
        leaderSegmentedControl.addTarget(self, action: #selector(changeLeader), for: .valueChanged)
        if let heroe = currentHeroe {
            if heroe.isLeader {
                leaderSegmentedControl.selectedSegmentIndex = 1
            }
        }
        leaderSegmentedControl.selectedSegmentIndex = 0
        view.addSubview(leaderSegmentedControl)
        leaderSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(catchPhraseTextField).offset(30)
            make.left.equalTo(view).offset(20)
        }
        
        equipLabel = UILabel()
        equipLabel.text = "Heroe equip:"
        view.addSubview(equipLabel)
        equipLabel.snp.makeConstraints { make in
            make.top.equalTo(leaderSegmentedControl).offset(40)
            make.left.equalTo(view).offset(20)
        }
        
        heroEquipLabel = UILabel()
        view.addSubview(heroEquipLabel)
        heroEquipLabel.snp.makeConstraints { make in
            make.top.equalTo(equipLabel).offset(30)
            make.left.equalTo(view).offset(20)
        }
        
        for (index,item) in availableEquip.enumerated() {
            let equipButton = UIButton()
            equipButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            equipButton.setTitle(item, for: .normal)
            equipButton.tag = index
            equipButton.addTarget(self, action: #selector(equipButtonTapped), for: .touchUpInside)
            equipButton.layer.borderColor = UIColor.clear.cgColor
            equipButton.layer.cornerRadius = 5
            equipButton.layer.borderWidth = 2
            view.addSubview(equipButton)
            equipButtons.append(equipButton)
            equipButton.snp.makeConstraints { make in
                if index == 0 {
                    make.left.equalTo(view).offset(30)
                } else {
                    make.left.equalTo(equipButtons[index-1]).offset(40)
                }
                make.width.lessThanOrEqualTo(35)
                make.height.lessThanOrEqualTo(35)
                make.top.equalTo(heroEquipLabel).offset(30)
            }
        }
        
        randomGenerateButton = UIButton()
        randomGenerateButton.addTarget(self, action: #selector(randomButtonPressed), for: .touchUpInside)
        randomGenerateButton.layer.cornerRadius = 10
        randomGenerateButton.titleLabel?.textColor = .black
        randomGenerateButton.setTitle("Random generate heroe", for: .normal)
        randomGenerateButton.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        view.addSubview(randomGenerateButton)
        randomGenerateButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.width.greaterThanOrEqualTo(220)
            make.height.greaterThanOrEqualTo(60)
            make.centerX.equalTo(view)
        }
        
        if isEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHeroe))
        } else {
            for button in equipButtons {
                button.isHidden = true
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(switchToEditMode))
            nameTextField.isUserInteractionEnabled = false
            avatarButton.isUserInteractionEnabled = false
            catchPhraseTextField.isUserInteractionEnabled = false
            randomGenerateButton.isHidden = true
            leaderSegmentedControl.isUserInteractionEnabled = false
        }
        
        if let heroe = currentHeroe {
            heroeEquip = heroe.equip
            heroEquipLabel.text = heroeEquip
            heroeImagePath = heroe.imagePath
            if let  heroeEquipArr = heroeEquip?.components(separatedBy: ",") {
                for equipBtn in equipButtons {
                    if heroeEquipArr.contains(equipBtn.titleLabel!.text!) {
                        equipBtn.isSelected = true
                        equipBtn.layer.borderColor = UIColor.green.cgColor
                    }
                }
            }
            
            nameTextField.text = heroe.name
            catchPhraseTextField.text = heroe.catchPhrase
            if let path = heroe.imagePath {
                avatar.image = UIImage(contentsOfFile: path)
            }
        }
        
    }
    
    @objc func saveHeroe() {
        
        guard let heroeName = nameTextField.text else { return }
        
        if heroeName.count == 0 {
            showError(err: HeroeError.emptyName)
            return
        } else if heroeImagePath == nil {
            showError(err: HeroeError.emptyAvatar)
            return
        } else if catchPhraseTextField.text?.count == 0 {
            showError(err: HeroeError.emtyCatchPhrase)
            return
        }
        
        if leaderSegmentedControl.selectedSegmentIndex == 1 {
            for heroe in team.heroes?.allObjects as! [Heroe] {
                heroe.isLeader = false
            }
        }
        
        if let heroe = currentHeroe {
            heroe.name = heroeName
            heroe.imagePath = heroeImagePath
            heroe.catchPhrase = catchPhraseTextField.text
            heroe.isLeader = leaderSegmentedControl.selectedSegmentIndex == 0 ? false : true
            heroe.equip = heroeEquip
        } else {
            let newHeroe = Heroe(context: context)
            newHeroe.name = heroeName
            newHeroe.parentCategory = team
            newHeroe.imagePath = heroeImagePath
            newHeroe.catchPhrase = catchPhraseTextField.text
            newHeroe.isLeader = leaderSegmentedControl.selectedSegmentIndex == 0 ? false : true
            newHeroe.equip = heroeEquip
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving heroe: \(error)")
        }
        
        teamDetailVCDelagate?.loadTeam()
        teamDetailVCDelagate?.tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func switchToEditMode() {
        for button in equipButtons {
            button.isHidden = false
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHeroe))
        nameTextField.isUserInteractionEnabled = true
        avatarButton.isUserInteractionEnabled = true
        catchPhraseTextField.isUserInteractionEnabled = true
        randomGenerateButton.isHidden = false
        leaderSegmentedControl.isUserInteractionEnabled = true
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc func randomButtonPressed() {
        catchPhraseTextField.text = catchPhrases[Int.random(in: 0..<catchPhrases.count)]
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
            heroEquipLabel.text = heroeEquip
            
        case false:
            sender.isSelected = true
            sender.layer.borderColor = UIColor.green.cgColor
            
            var equipArr = heroeEquip?.components(separatedBy: ",") ?? []
            equipArr.append(sender.titleLabel!.text!)
            
            heroeEquip = equipArr.joined(separator: ",")
            heroEquipLabel.text = heroeEquip
            
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
        avatar.image = UIImage(contentsOfFile: imagePath.path)
        
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
            self.nameTextField.text = heroe.name
        }
    }
    
    func failWithError(error: Error) {
        DispatchQueue.main.async {
            self.showError(err: HeroeError.networkError)
        }
    }
    
    func updateHeroeImage(imageData: Data) {
        DispatchQueue.main.async {
            self.avatar.image = UIImage(data: imageData)
            self.saveImage()
        }
        
    }
    
    func saveImage() {
        guard let imageName = nameTextField.text else { return }
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = avatar.image?.jpegData(compressionQuality: 1) {
            try? jpegData.write(to: imagePath)
        }
        
        heroeImagePath = imagePath.path
    }
    
    
}

enum HeroeError {
    case emptyName
    case emtyCatchPhrase
    case emptyAvatar
    case networkError
}
