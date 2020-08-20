//
//  PhotosViewController+Extention.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 20/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import UIKit

var aView : UIView?
extension PhotosViewController{
    
    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let activiteyIndc = UIActivityIndicatorView(style: .whiteLarge)
        activiteyIndc.center = aView!.center
        activiteyIndc.startAnimating()
        
        aView?.addSubview(activiteyIndc)
        self.view.addSubview(aView!)
        
    }
    
    class func removeSpinner() {
        aView?.removeFromSuperview()
        aView = nil
        
    }
    
    
}
