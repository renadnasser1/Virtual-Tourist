//
//  ErrorHandller.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
import UIKit

class ErrorHandller: UIAlertController{
    
    class func showAlert(title:String?, message:String, viewController:UIViewController){
        DispatchQueue.main.async {
            
        let myAlert = UIAlertController(title: title ?? "", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myAlert.addAction(okAction)
        
        viewController.present(myAlert, animated: true, completion: nil)
             }
        
    }
}
