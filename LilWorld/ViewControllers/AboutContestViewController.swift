//
//  AboutContestViewController.swift
//  LilWorld
//
//  Created by Aleksandr Novikov on 10.08.16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit

class AboutContestViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var urlToOpen : String? {
        didSet(oldValue) {
            loadRequest()
        }
    }
    
    var showCloseButton : Bool = false {
        didSet(oldValue) {
            if closeButton != nil {
                closeButton.isHidden = !showCloseButton
                menuButton.isHidden = showCloseButton
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.attributedText = NSAttributedString(string: localized("About_contest_title"), attributes: GlobalConstants.kTitleAttributes)
        
        closeButton.isHidden = !showCloseButton
        menuButton.isHidden = showCloseButton
        
        loadRequest()
        webView.delegate = self
    }
    
    func loadRequest() {
        guard webView != nil else {
            return
        }
        if let urlToOpen = urlToOpen, let url =  URL(string: urlToOpen) {
            webView.loadRequest(URLRequest(url: url))
        } else {
            webView.loadRequest(URLRequest(url: URL(string: "http://contest.lil.city")!))
        }
    }
    
    @IBAction func sideMenuButtonPressed(_ sender: AnyObject) {
        revealViewController().revealToggle(animated: true)
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

extension AboutContestViewController : UIWebViewDelegate {
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let alertController = UIAlertController(title: "Не удалось загрузить информацию о конкурсе", message: "Пожалуйста, проверьте Ваше подключение к интернету и попробуйте ещё раз", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:
            "Отменить", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Повторить попытку", style: .default, handler: { (action) in
            self.loadRequest()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.absoluteString == "https://new.vk.com/kinder" {
            showModalWebBrowserWithURL(request.url!)
            return false
        } else if request.url?.absoluteString == "https://ok.ru/kinder" {
            showModalWebBrowserWithURL(request.url!)
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
}
