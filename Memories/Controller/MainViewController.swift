//
//  ViewController.swift
//  Memories
//
//  Created by Tarek Hatata on 9/19/19.
//  Copyright © 2019 Tarek Hatata. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD
import Photos

public struct NavBarDims {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

public var dims: NavBarDims? = nil

class MainViewController: UIViewController {
    private let imagePicker = UIImagePickerController()
    private var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
    private var cameraPermissionGranted = false
    private var photoLibraryPermissionGranted = false
    private var image: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        dims = getNavBarDims()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMoment" {
            let viewController = segue.destination as? ViewMomentViewController
            viewController?.image = image
        }
    }
    
    @IBAction func addMoment(_ sender: Any) {
        // configure image picker
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // show alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.sourceType = .camera
            if self.cameraPermissionGranted {
                self.promptUIImagePicker()
            } else {
                self.checkCameraPermission()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.sourceType = .photoLibrary
            if self.photoLibraryPermissionGranted {
                self.promptUIImagePicker()
            } else {
                self.checkPhotoLibraryPermission()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorizationStatus {
            case .authorized:
                self.cameraPermissionGranted = true
                self.promptUIImagePicker()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { response in
                    if response {
                        DispatchQueue.main.async {
                            self.cameraPermissionGranted = true
                            self.promptUIImagePicker()
                        }
                    } else {
                        self.showError(errorTitle: "Camera Access", errorMessage: "Access denied.")
                    }
                })
            case .restricted:
                // no camera access
                self.showError(errorTitle: "Camera Access", errorMessage: "Camera not available.")
            case .denied:
                self.showError(errorTitle: "Camera Access", errorMessage: "Access denied.")
            @unknown default:
                self.showError(errorTitle: "Camera Access", errorMessage: "Unknown error.")
        }
    }
    
    func checkPhotoLibraryPermission() {
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoLibraryAuthorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ response in
                if response == .authorized {
                    DispatchQueue.main.async {
                        self.photoLibraryPermissionGranted = true
                        self.promptUIImagePicker()
                    }
                } else {
                    self.showError(errorTitle: "Photo Library Access", errorMessage: "Access denied.")
                }
            })
        case .restricted:
            // no photo library access
            self.showError(errorTitle: "Photo Library Access", errorMessage: "Camera not available.")
        case .denied:
            self.showError(errorTitle: "Photo Library Access", errorMessage: "Access denied.")
        case .authorized:
            self.photoLibraryPermissionGranted = true
            self.promptUIImagePicker()
        @unknown default:
            self.showError(errorTitle: "Photo Library Access", errorMessage: "Unknown error.")
        }
    }
    
    private func promptUIImagePicker() {
        imagePicker.sourceType = sourceType
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.showError(errorTitle: "Invalid Access", errorMessage: "Source type unavailable: \(sourceType)")
        }
    }
    
    private func showError(errorTitle : String, errorMessage : String) {
        // show an error message in an asynchronous task
        DispatchQueue.main.async {
            let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func getNavBarDims() -> NavBarDims {
        let navController = navigationController!
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width
        let bannerY = bannerHeight / 2 - image.size.width
        
        return NavBarDims(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
    }
}

extension MainViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var error = false
        if let image = info[.editedImage] as? UIImage {
            self.image = image
        } else if let image = info[.originalImage] as? UIImage {
            self.image = image
        } else {
            self.showError(errorTitle: "Image Error", errorMessage: "Error saving image.")
            error = true
        }
        
        picker.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                if !error {
                    self.performSegue(withIdentifier: "addMoment", sender: self)
                }
            }
        })
    }
}
