//
//  ShareViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 17/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import Social
import Photos
import Accounts

class ShareViewController: UIViewController {

    var imageForSharing: UIImage? = nil
	var videoURLForSharing: URL? = nil
    var documentInteractionController = UIDocumentInteractionController()
    
    var gotoContestAfterSaving : Bool = false
	
	var saved: Bool = false
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var socialsTableView: UITableView!
    
    fileprivate enum SocialNetwork: Int {
        case instagram, facebook, twitter, tumblr, photos, other, kinderContest
        
        static let valuesForSharing = [instagram, facebook, twitter, tumblr, photos, other, kinderContest]
        
        func title() -> String {
            switch self {
            case .instagram:
                return "Instagram"
            case .facebook:
                return "Facebook"
            case .twitter:
                return "Twitter"
            case .other:
                return localized("Share_other")
            case .tumblr:
                return "Tumblr"
            case .photos:
                return localized("Share_saveOnPhoto")
            case .kinderContest:
                return localized("Share_kinderContest")
            }
        }
    }
}

//MARK: - Lifecycle

extension ShareViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newButtonTitleNormalAttributes = [
            NSFontAttributeName : UIFont(name: "Circe-Regular", size: 13)!,
            NSKernAttributeName: GlobalConstants.kMainFontKern,
            NSForegroundColorAttributeName:UIColor.white
        ]
        newButton.setAttributedTitle(NSAttributedString(string: localized("Share_newButtonTitle"), attributes: newButtonTitleNormalAttributes), for: UIControlState())
        
        socialsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        socialsTableView.layoutIfNeeded()
        resizeTableView()
    }
	
}


//MARK: - Actions

extension ShareViewController {
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
		saved = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func newButtonPressed(_ sender: UIButton) {
		saved = false
        let alertController = UIAlertController(title: localized("Alerts_startNewTitle"), message: localized("Alerts_startNewMessage"), preferredStyle: .alert)
        let startNewAction = UIAlertAction(title: localized("Alerts_startNewYes"), style: .destructive) { (action) -> Void in
            self.navigationController?.popToRootViewController(animated: true)
			let editorVC = EditorViewController()
			editorVC.removeEditorVCState()
        }
        let cancelAction = UIAlertAction(title: localized("Alerts_startNewNo"), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(startNewAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension ShareViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocialNetwork.valuesForSharing.count-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SocialNetworkCell") as? SocialNetworkTableViewCell
        let value = SocialNetwork.valuesForSharing[indexPath.row]
        cell?.socialNetworkNameLabel.text = value.title().uppercased()
        if value == .kinderContest {
            cell?.socialNetworkNameLabel.textColor = UIColor(red: 227/255, green: 72/255, blue: 31/255, alpha: 1)
        } else {
            cell?.socialNetworkNameLabel.textColor = UIColor.white
        }
        return cell!
    }
}

// MARK: - Table view delegate

extension ShareViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let analyticsShareType : AnalyticsShareType
        
        let socialNetwork = SocialNetwork.valuesForSharing[(indexPath as IndexPath).row]
        switch socialNetwork {
        case .instagram:
            shareToInstagram()
            analyticsShareType = .Instagram
        case .facebook:
            shareToFacebook()
            analyticsShareType = .FB
        case .twitter:
            shareToTwitter()
            analyticsShareType = .Twitter
        case .other:
            shareToOther()
            analyticsShareType = .Other
        case .tumblr:
            shareToTumblr()
            analyticsShareType = .Tumblr
        case .kinderContest:
            saveInPhotosAndGotoContest(true)
            analyticsShareType = .Contest
        case .photos:
            saveInPhotosAndGotoContest(false)
            analyticsShareType = .SaveToGallery
        }
        
        AnalyticsEngine.trackEvent(AnalyticsShareEvent(socialName: analyticsShareType))
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SocialNetworkTableViewCell {
            cell.socialNetworkNameLabel.alpha = 0.5;
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SocialNetworkTableViewCell {
            cell.socialNetworkNameLabel.alpha = 1;
        }
    }
}


//MARK: - Sharing

extension ShareViewController {
    
    fileprivate func shareToInstagram() {
        if(UIApplication.shared.canOpenURL(URL(string: "instagram://app")!)) {
			if let url = videoURLForSharing {
				if !saved {
				PHPhotoLibrary.shared().performChanges({
					_ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURLForSharing!)
				}, completionHandler: { (success, error) in
					if error == nil {
						self.saved = true
						let instagramString = "instagram://library?AssetPath=\(url)"
						let instagramURL = NSURL(string: instagramString)
						if UIApplication.shared.canOpenURL(instagramURL! as URL){
							UIApplication.shared.openURL(instagramURL! as URL)
						} else {
							print("Instagram app not installed.")
						}
					} else {
						let alert = UIAlertController(title: "Save error", message: error?.localizedDescription,	preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
						self.present(alert, animated: true, completion: nil)
					}
				})
				}
				
			} else {
				let savePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/Test.igo"
				try? UIImageJPEGRepresentation(imageForSharing!, 1)!.write(to: URL(fileURLWithPath: savePath), options: [.atomic])
				let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
				let igImageHookFile = URL(string: "file://\(savePath)")
				documentInteractionController = UIDocumentInteractionController(url: igImageHookFile!)
				documentInteractionController.uti = "com.instagram.exclusivegram"
				documentInteractionController.annotation = ["InstagramCaption": "hola"]
				documentInteractionController.presentOpenInMenu(from: rect, in: self.view, animated: true)
			}
        } else {
            let alert = UIAlertController(title: localized("Alerts_shareInstagramErrorTitle"), message: localized("Alerts_shareInstagramErrorMessage"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func shareToFacebook() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
			if let url = videoURLForSharing {
				//check if facebook app exists
				if (UIApplication.shared.canOpenURL(URL(string: "fb://feed")!)) {
					self.saveToGallery()
					UIApplication.shared.openURL(URL(string: "fb://messaging")!)
				} else {
					let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
					facebookSheet.setInitialText("")
					facebookSheet.add(url)
					self.present(facebookSheet, animated: true, completion: nil)
				}
			} else {
				let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
				facebookSheet.setInitialText("")
				facebookSheet.add(imageForSharing)
				self.present(facebookSheet, animated: true, completion: nil)
			}
        } else {
            let alert = UIAlertController(title: localized("Alerts_shareFacebookErrorTitle"), message: localized("Alerts_shareFacebookErrorMessage"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func shareToTwitter() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
			if (videoURLForSharing != nil) {
				
				if (UIApplication.shared.canOpenURL(URL(string: "twitter://post?x-source=[SourceAppName]")!)) {
					self.saveToGallery()
					UIApplication.shared.openURL(URL(string: "twitter://post?x-source=[SourceAppName]")!)
				} else {
					let alert = UIAlertController(title: "Share error to Twitter!", message: "Please, install Twitter application!", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			} else {
				let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
				twitterSheet.setInitialText("")
				twitterSheet.add(imageForSharing)
				self.present(twitterSheet, animated: true, completion: nil)
			}
        } else {
            let alert = UIAlertController(title: localized("Alerts_shareTwitterErrorTitle"), message: localized("Alerts_shareTwitterErrorMessage"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func shareToOther() {
        DispatchQueue.main.async { 
            let activityViewController = UIActivityViewController(activityItems: [self.imageForSharing!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    fileprivate func shareToTumblr() {
        if UIApplication.shared.canOpenURL(URL(string: "tumblr://")!) {
			if (videoURLForSharing != nil) {
				saveToGallery()
				UIApplication.shared.openURL(URL(string: "tumblr://x-callback-url/video?caption=LilWorld&tags=lilworld")!)
			} else {
				if let image = imageForSharing {
					UIPasteboard.general.image = image
					UIApplication.shared.openURL(URL(string: "tumblr://x-callback-url/photo?caption=LilWorld&tags=lilworld")!)
				}
			}
        } else {
            let alert = UIAlertController(title: localized("Alerts_shareTumblrErrorTitle"), message: localized("Alerts_shareTumblrErrorMessage"), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func saveInPhotosAndGotoContest(_ gotoContest: Bool) {
        gotoContestAfterSaving = gotoContest
		if (videoURLForSharing != nil) {
			self.saveToGallery()
			if self.gotoContestAfterSaving {
				self.performSegue(withIdentifier: "kinderContest", sender: self)
			}
			let alert = UIAlertController(title: "Successfully saved", message: "Video saved", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			
		} else {
			UIImageWriteToSavedPhotosAlbum(imageForSharing!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
		}
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        socialsTableView.reloadData()
        if error == nil {
            let alert = UIAlertController(title: localized("Alerts_shareSaveOnPhotoSuccessTitle"), message: localized("Alerts_shareSaveOnPhotoSuccessMessage"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if self.gotoContestAfterSaving {
                    self.performSegue(withIdentifier: "kinderContest", sender: self)
                }
            }))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Private

extension ShareViewController {
	
	fileprivate func saveToGallery() {
		if !saved {
			
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURLForSharing!)
			}, completionHandler: { (success, error) in
				if error == nil {
					self.saved = true
					if !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoURLForSharing!.relativePath) {
						UISaveVideoAtPathToSavedPhotosAlbum(self.videoURLForSharing!.relativePath, nil, nil, nil)
					}
				} else {
					let alert = UIAlertController(title: "Save error", message: error?.localizedDescription,	preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			})
		}
	}
	
    fileprivate func resizeTableView() {
        let effectiveHeight = CGFloat(SocialNetwork.valuesForSharing.count) * socialsTableView.rowHeight;
        let topTableViewOffset = (socialsTableView.frame.height - effectiveHeight) * 0.5
        socialsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: socialsTableView.frame.width, height: topTableViewOffset))
    }
}

