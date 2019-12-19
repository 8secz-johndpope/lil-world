//
//  FeedViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 16/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SWRevealViewController

class FeedViewController: UIViewController {

    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postsTableView: UITableView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var repeatLoadingButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var posts: [SocialPost] = []
    fileprivate var currentPage = 0
    fileprivate var loading = false
    
    fileprivate struct Constants {
        static let placeholderImage = UIImage.imageWithColor(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            sideMenuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        }
        
        titleLabel.attributedText = NSAttributedString(string: localized("Feed_title"), attributes: GlobalConstants.kTitleAttributes)
        
        postsTableView.estimatedRowHeight = 1000.0
        postsTableView.rowHeight = UITableViewAutomaticDimension
        postsTableView.tableFooterView = UIView(frame: CGRect.zero)
        postsTableView.isHidden = true
        errorLabel.isHidden = true
        repeatLoadingButton.isHidden = true
        activityIndicator.startAnimating()
        loadNextPostsIfNeeded()
    }
    
    fileprivate func loadNextPostsIfNeeded() {
        if loading {
            return
        }
        loading = true
        currentPage += 1
        Alamofire.request(LilWorldAPIRouter.socialPosts(currentPage)).responseJSON { (response) -> Void in
            self.activityIndicator.isHidden = true
            if (response.result.isSuccess) {
                self.postsTableView.isHidden = false
                if let responseValue = response.result.value as? [String : Any] {
                    if let socialPosts = responseValue["social_posts"] as? [[String : Any]] {
                        for socialPost in socialPosts {
                            if let imageDict = socialPost["image"] as? Dictionary<String, AnyObject>,
                                let width = imageDict["width"] as? CGFloat,
                                let height = imageDict["height"] as? CGFloat {
                                    let newPost = SocialPost()
                                    newPost.image_url = imageDict["uri"] as? String
                                newPost.size = CGSize(width: width, height: height)
                                    newPost.timestamp = socialPost["timestamp"] as? Int
                                    newPost.username = socialPost["username"] as? String
                                    self.posts.append(newPost)
                            }
                        }
                        if socialPosts.count > 0 {
                            self.postsTableView.reloadData()
                        }
                    }
                }
            } else {
                if self.currentPage == 1 {
                    self.errorLabel.isHidden = false
                    self.repeatLoadingButton.isHidden = false
                }
                self.currentPage -= 1
            }
            self.loading = false
        }
    }
    
    func usernameButtonPressed(_ sender: UIButton) {
        guard var username = sender.currentTitle else {
            return
        }
        if username.hasPrefix("@") {
            username = username.replacingOccurrences(of: "@", with: "")
        }
        if let url = URL(string: "https://www.instagram.com/\(username)") {
            self.showModalWebBrowserWithURL(url)
        }
    }
    
    @IBAction func repeatLoadingButtonPressed(_ sender: UIButton) {
        self.errorLabel.isHidden = true
        self.repeatLoadingButton.isHidden = true
        self.activityIndicator.isHidden = false
        loadNextPostsIfNeeded()
    }
    
}

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SocialPostTableViewCell", for: indexPath) as? SocialPostTableViewCell {
            
            let post = posts[indexPath.row]
            cell.usernameButton.setTitle(post.username, for: UIControlState())
            cell.usernameButton.setTitle(post.username, for: .highlighted)
            cell.usernameButton.addTarget(self, action: #selector(usernameButtonPressed(_:)), for: .touchUpInside)
            if let imageWidth = post.size?.width,
                let imageHeight = post.size?.height {
                    let imageAspectRatio = imageWidth / imageHeight
                    cell.postImageHeightConstraint.constant = postsTableView.frame.width / imageAspectRatio
            }
            cell.postImage.sd_setImage(with: URL(string: post.image_url!)!, placeholderImage: Constants.placeholderImage)
            if indexPath.row == posts.count - 1 {
                loadNextPostsIfNeeded()
            }
            return cell
        }
        return UITableViewCell()
    }
}
