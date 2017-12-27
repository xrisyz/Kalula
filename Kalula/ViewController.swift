//
//  ViewController.swift
//  Kalula
//
//  Created by Christopher Brandon Karani on 19/12/2017.
//  Copyright © 2017 Christopher Brandon Karani. All rights reserved.
//

import UIKit
import Sukari
import SnapKit
import Firebase

class ViewController: UIViewController {
    
    var stackView: UIStackView!
    
    let imagePickerButton = UIButton(type: .system).this {
        $0.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        $0.addTarget(self, action: #selector(handleImagePicker), for: .touchUpInside)
    }
    
    let emailTextField = UITextField().this {
        $0.placeholder = "Email"
        $0.borderStyle = .roundedRect
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(white: 0, alpha: 0.03)
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.addTarget(self, action: #selector(handleTextFieldEditingChanged), for: .editingChanged)
    }
    
    let usernameTextField = UITextField().this {
        $0.placeholder = "Username"
        $0.borderStyle = .roundedRect
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(white: 0, alpha: 0.03)
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.addTarget(self, action: #selector(handleTextFieldEditingChanged), for: .editingChanged)
    }
    
    let passwordTextField = UITextField().this {
        $0.placeholder = "Password"
        $0.borderStyle = .roundedRect
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(white: 0, alpha: 0.03)
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.isSecureTextEntry = true
        $0.addTarget(self, action: #selector(handleTextFieldEditingChanged), for: .editingChanged)
    }
    
    lazy var signInButton = UIButton(type: .system).this {
        $0.setTitle("Sign In", for: .normal)
        $0.backgroundColor = UIColor.rgb(red: 149, green: 205, blue: 244)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = false
        $0.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    @objc fileprivate func handleSignUp() {
        let email = emailTextField.text.unwrap()
        let password = passwordTextField.text.unwrap()
        let userName = usernameTextField.text.unwrap()
        authorizeUser(withEmail: email, password: password, userName: userName)
    }
    
    fileprivate func authorizeUser(withEmail email: String, password: String, userName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let selectedImage = self.imagePickerButton.imageView?.image else {
                preconditionFailure("Selected Image Error")
            }
            
            let data = UIImageJPEGRepresentation(selectedImage, 0.3).unwrap(debug: "Data Error")
            
            let fileName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_Images").child("\(fileName).jpg")
            storageRef.putData(data, metadata: nil, completion: { (metaData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let profileImageUrl = metaData?.downloadURL() {
                    
                    let userCredentials = ["username": userName,
                                           "profileImageUrl": profileImageUrl.absoluteString]
                    
                    let uid = user.unwrap().uid
                    let ref = Database.database().reference().child("users")
                    
                    let values = [uid: userCredentials]
                    ref.updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        print("Succesfully added user to DB")
                    })
                }
                
            })
        }
    }
    
    
    @objc fileprivate func handleImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    

    
    @objc fileprivate func handleTextFieldEditingChanged() {
        var isFormValid : Bool = false
        let email = emailTextField.text.unwrap()
        let username = usernameTextField.text.unwrap()
        let password = passwordTextField.text.unwrap()
        
        if !(email.isEmpty) && password.count >= 6 && !(username.isEmpty) {
            isFormValid = true
        }
        switch isFormValid {
        case true:
            signInButton.isUserInteractionEnabled = true
            signInButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        case false:
            signInButton.isUserInteractionEnabled = false
            signInButton.backgroundColor = UIColor.rgb(red: 149, green: 205, blue: 244)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupUIComponents()
    }
}

//MARK: - UI Functionality
extension ViewController {
    fileprivate func setupUIComponents() {
        setupInputComponents()
        setupImagePickerButton()
    }
    
    fileprivate func setupInputComponents() {
        stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signInButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
    }
    
    fileprivate func setupViewController() {
        view.backgroundColor = .white
    }
    
    fileprivate func setupImagePickerButton() {
        view.addSubview(imagePickerButton)
        view.addSubview(stackView)
        
        imagePickerButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(140)
            $0.height.equalTo(140)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(imagePickerButton.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().inset(40)
            $0.height.equalTo(220)
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancle")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imagePickerButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        imagePickerButton.layer.masksToBounds = true
        imagePickerButton.layer.cornerRadius = imagePickerButton.frame.width/2
        imagePickerButton.layer.borderWidth = 4
        imagePickerButton.layer.borderColor = UIColor.black.cgColor
    
        dismiss(animated: true, completion: nil)
    }
}

