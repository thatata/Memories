//
//  ViewMomentViewController.swift
//  Memories
//
//  Created by Tarek Hatata on 10/23/19.
//  Copyright © 2019 Tarek Hatata. All rights reserved.
//

import UIKit

class ViewMomentViewController: UIViewController {

    var image: UIImage?
    @IBOutlet weak var momentChosen: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        momentChosen.image = image!
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        titleTextField.layer.borderWidth = 0.5
        descriptionTextView.layer.borderWidth = 0.75
        titleTextField.layer.cornerRadius = 5.0
        descriptionTextView.layer.cornerRadius = 5.0
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
