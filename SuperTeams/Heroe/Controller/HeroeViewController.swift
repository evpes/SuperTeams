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
    
    var avatar: UIImageView!
    var nameLabel: UILabel!
    var nameTextField: UITextField!
    var team: Team!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHeroe))
        // Do any additional setup after loading the view.
        avatar = UIImageView()
        avatar.layer.cornerRadius = 50
        view.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.top.equalTo(view).offset(60)
            make.width.greaterThanOrEqualTo(100)
            make.height.greaterThanOrEqualTo(100)
            make.centerX.equalTo(view)
        }
        avatar.backgroundColor = UIColor.black
        
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
    }
    
    @objc func saveHeroe() {
        
        guard let heroeName = nameTextField.text else { return }
        
        let newHeroe = Heroe(context: context)
        newHeroe.name = heroeName
        newHeroe.parentCategory = team

        do {
            try context.save()
        } catch {
            print("Error saving heroe: \(error)")
        }

        teamDetailVCDelagate?.loadTeam()
        teamDetailVCDelagate?.tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
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
