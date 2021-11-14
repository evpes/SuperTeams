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
    var randomGenerateButton: UIButton!
    var team: Team!
    var isEdit: Bool = true
    var currentHeroe: Heroe?
    var heroeImagePath: String?
    
    let catchPhrases = ["I am your father","Hasta la vista, baby","I love the smell of napalm in the morning","Yippee ki yay, motherfucker","Release the Kraken!","I'll be back","THIS IS SPARTA!","Houston, we have a problem.",
                        "Suit up!","Oh my God, they killed Kenny","Bazinga!","I know kung fu.","You shall not pass!","How you doin?","A martini…shaken, not stirred.","To infinity…and beyond!","There can be only one."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroeManager.delegate = self
        
        
        // Do any additional setup after loading the view.
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
        nameLabel.text = "Name"
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar).offset(120)
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
        catchPhraseLabel.text = "Catch phrase"
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
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(switchToEditMode))
            nameTextField.isUserInteractionEnabled = false
            avatarButton.isUserInteractionEnabled = false
            catchPhraseTextField.isUserInteractionEnabled = false
            randomGenerateButton.isHidden = true
        }
        
        if let heroe = currentHeroe {
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
        
        if let heroe = currentHeroe {
            heroe.name = heroeName
            heroe.imagePath = heroeImagePath
            heroe.catchPhrase = catchPhraseTextField.text
        } else {
            let newHeroe = Heroe(context: context)
            newHeroe.name = heroeName
            newHeroe.parentCategory = team
            newHeroe.imagePath = heroeImagePath
            newHeroe.catchPhrase = catchPhraseTextField.text
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHeroe))
        nameTextField.isUserInteractionEnabled = true
        avatarButton.isUserInteractionEnabled = true
        catchPhraseTextField.isUserInteractionEnabled = true
        randomGenerateButton.isHidden = false
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
        print(error)
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
