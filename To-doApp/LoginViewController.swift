//
//  LoginViewController.swift
//  To-doApp
//
//  Created by Bircan Sezgin on 10.06.2023.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //imageView.image = UIImage(named: "lock.icloud.fill")
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        faceOpen()
    }
    
    @IBAction func openClick(_ sender: Any) {
        faceOpen()
    }
    
    
    func faceOpen(){
        
        // bir objeden yetki almamiz gerek
        let authContext = LAContext()
        
        var error:NSError?
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Is it you?") { success, error in
                // Main thread on tarafa almak
                if success == true{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "todo", sender: nil)
                    }
                }else{
                    // Main thread on tarafa almak
                    DispatchQueue.main.async {
                        //self.singLabel.text = "Error"
                    }
                }
            }
        }
    }


}
