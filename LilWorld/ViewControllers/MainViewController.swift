//
//  MainViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 24/08/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import SWRevealViewController

class MainViewController: UIViewController {

    lazy var imagePicker = UIImagePickerController()
    
    var loadedImage: UIImage? = nil
    
    @IBOutlet weak var captureLabel: UILabel!
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var sideMenuButton: UIButton!
}

//MARK: - Lifecycle

extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        let bigButtonsAttributes = [
            NSFontAttributeName : UIFont(name: "Circe-Regular", size: 12)!,
            NSKernAttributeName: GlobalConstants.kMainFontKern
        ]
        captureLabel.attributedText = NSAttributedString(string: localized("Main_CAPTURE"), attributes: bigButtonsAttributes)
        galleryLabel.attributedText = NSAttributedString(string: localized("Main_GALLERY"), attributes: bigButtonsAttributes)
        
        if let revealController = revealViewController() {
            revealController.delegate = self
            revealController.tapGestureRecognizer()
            revealController.panGestureRecognizer()
            sideMenuButton.addTarget(revealController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        }
        
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
		
		if (UserDefaults.standard.object(forKey: "stickers") != nil) && (UserDefaults.standard.object(forKey: "background") != nil) && (UserDefaults.standard.object(forKey: "stickerImagesData") != nil) {
			
			let alertController = UIAlertController(title: localized("Alerts_loadLastSessionTitle"), message: localized("Alerts_loadLastSessionMessage"), preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title:
				"Cancel", style: .cancel, handler: { (action) in
					self.dismiss(animated: true, completion: nil)
					let editorVC = EditorViewController()
					editorVC.removeEditorVCState()
			}))
			alertController.addAction(UIAlertAction(title: "Load!", style: .default, handler: { (action) in
				let arr = [UserDefaults.standard.object(forKey: "background") as! Data, UserDefaults.standard.object(forKey: "stickers") as! Data, UserDefaults.standard.object(forKey: "stickerImagesData") as! [Data]] as [Any]
				self.performSegue(withIdentifier: "ImageLoadedSegue", sender: arr)
			}))
			present(alertController, animated: true, completion: nil)
			
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hintMenuIfNeeded()
        self.revealViewController().panGestureRecognizer().isEnabled = true
        
        KulaAppirater.sharedInstance.showAlertIfNeeded()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        let key = "userHadSeenContestPopup01"
//        
//        if !UserDefaults.standard.bool(forKey: key) {
//            performSegue(withIdentifier: "contestPopup", sender: self)
//            UserDefaults.standard.set(true, forKey: key)
//            UserDefaults.standard.synchronize()
//        }
//    }
}

//MARK: - Actions

extension MainViewController {

    @IBAction func openFromLibraryTapped(_ sender: UIButton) {
        AnalyticsEngine.trackEvent(CommonAnalyticsEvent(event: .PhotoGallery, parameter: nil))
        
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .authorized {
            self.openImagePickerWithSourceType(.photoLibrary, allowsEditing: false)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
            switch authorizationStatus {
            case .authorized:
                DispatchQueue.main.async(execute: {
                    self.openImagePickerWithSourceType(.photoLibrary, allowsEditing: false)
                    })
            default:
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: localized("Alerts_noAccessPhotoLibraryTitle"), message: localized("Alerts_noAccessPhotoLibraryMessage"), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: localized("Alerts_noAccessPhotoLibraryNo"), style: UIAlertActionStyle.default, handler: nil))
                    alert.addAction(UIAlertAction(title: localized("Alerts_noAccessPhotoLibraryYes"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func openFromMakingPhoto(_ sender: UIButton) {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            openImagePickerWithSourceType(.camera, allowsEditing: false)
        AnalyticsEngine.trackEvent(CommonAnalyticsEvent(event: .PhotoCamera, parameter: nil))
        }
        else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if granted {
                        self.openImagePickerWithSourceType(.camera, allowsEditing: false)
                    }
                    else {
                        let alert = UIAlertController(title: localized("Alerts_noAccessCameraTitle"), message: localized("Alerts_noAccessCameraMessage"), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: localized("Alerts_noAccessCameraNo"), style: UIAlertActionStyle.default, handler: nil))
                        alert.addAction(UIAlertAction(title: localized("Alerts_noAccessCameraYes"), style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                        }))
                        self.present(alert, animated: true, completion: nil)                    }
                })
            });
        }
        
    }
    
    @IBAction func topContainerButtonHighlighted(_ sender: UIButton) {
        captureButton.isHighlighted = true
    }
    
    @IBAction func topContainerButtonUnhighlighted(_ sender: UIButton) {
        captureButton.isHighlighted = false
    }
    
    @IBAction func topContainerButtonUnhighlightedOutside(_ sender: UIButton) {
        captureButton.isHighlighted = false
    }
    
    @IBAction func bottomContainerButtonHighlighted(_ sender: UIButton) {
        galleryButton.isHighlighted = true
    }
    
    @IBAction func bottomContainerButtonUnhighlighted(_ sender: UIButton) {
        galleryButton.isHighlighted = false
    }
    
    @IBAction func bottomContainerButtonUnhighlightedOutside(_ sender: UIButton) {
        galleryButton.isHighlighted = false
    }
}

//MARK: - Image picker delegate

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            loadedImage = image
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "ImageLoadedSegue", sender: self)
            }
        }
    }
}

//MARK: - Private

extension MainViewController {
  
    fileprivate func hintMenuIfNeeded() {
        if !UserDefaults.standard.bool(forKey: "Hint.Menu") {
            hintMenu()
            UserDefaults.standard.set(true, forKey: "Hint.Menu")
        }
    }
    
    fileprivate func hintMenu() {
        self.view.isUserInteractionEnabled = false
        let oldRevealWidth = self.revealViewController().rearViewRevealWidth
        self.revealViewController().rearViewRevealWidth = 200
        delay(0.5) { 
            self.revealViewController().revealToggle(animated: true)
            delay(1) {
                self.revealViewController().revealToggle(animated: true)
                self.view.isUserInteractionEnabled = true
                self.revealViewController().rearViewRevealWidth = oldRevealWidth
            }
        }
    }
    
    fileprivate func openImagePickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType, allowsEditing:Bool) {
        guard self.navigationController?.presentedViewController == nil else {
            return
        }
        imagePicker.allowsEditing = allowsEditing
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - Navigation

extension MainViewController {
    
    @IBAction func contestInfo(_ segue: UIStoryboardSegue) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { () -> Void in
            self.performSegue(withIdentifier: "contestInfo", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageLoadedSegue" {
			if sender is [Any] {
				if let editorViewController = segue.destination as?  EditorViewController {
					let arr = try sender as! [Any]
					editorViewController.startImage = UIImage(data: arr[0] as! Data)

					let stickers = NSKeyedUnarchiver.unarchiveObject(with: try arr[1] as! Data) as! Array<UIImageView>
					let stickerImagesData = try arr[2] as! [Data]
					var stickerImages = [UIImage]()
					for el in stickerImagesData {
						stickerImages.append(UIImage(data: el)!)
					}
					var count = 0
						for n in 0..<stickers.count {
								if count < stickers.count {
									if stickers[n].image?.images == nil {
											stickers[n].image = stickerImages[count]
											count += 1
									}
							}
						}
					editorViewController.startStickers = stickers
				}
			} else {
				if let editorViewController = segue.destination as?  EditorViewController {
					self.revealViewController().panGestureRecognizer().isEnabled = false
					editorViewController.startImage = loadedImage!
				}
			}
        }
    }
}

//MARK: - SWRevealViewControllerDelegate

extension MainViewController: SWRevealViewControllerDelegate {
    
    func revealControllerPanGestureBegan(_ revealController: SWRevealViewController!) {
        galleryButton.isHighlighted = false
        captureButton.isHighlighted = false
    }
    
    func revealController(_ revealController: SWRevealViewController!, animateTo position: FrontViewPosition) {
        if position == .left {
            self.view.isUserInteractionEnabled = true
        } else {
            self.view.isUserInteractionEnabled = false
        }
    }
}
