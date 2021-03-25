//
//  ViewController.swift
//  ContactsAnimation
//
//  Created by Vishal on 14/10/18.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var initialViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var initialViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var initialsTopConstraint: NSLayoutConstraint!
    @IBOutlet var countryTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsTableView: UITableView!
    
    let topConstraintMinValue: CGFloat = UIApplication.shared.statusBarFrame.height + 2
    var minimumHeaderHeight: CGFloat = 156
    var maximumHeaderHeight: CGFloat = 256
    var maximumInitialsHeight: CGFloat = 80
    var minimumInitialsHeight: CGFloat =  40
    var initialMaxTopConstraint: CGFloat = 36
    let animationDuration: TimeInterval = 0.009
    var previousScrollOffset: CGFloat = 0
    var countryName = ""
    let minNameFontValue: CGFloat = 18
    let minCountryFontValue: CGFloat = 3
    var maxNameFontValue: CGFloat = 28
    var maxCountryFontValue: CGFloat = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeRequiredValues()
        updateUserAvatar()
        // adjusting the behaviour to handle the insets as tableview is to be added beneath status bar
        if #available(iOS 11.0, *) {
            detailsTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        // setting contentInset to manage initial point of scrolling
        detailsTableView.contentInset = UIEdgeInsets(top: maximumHeaderHeight, left: 0, bottom: 0, right: 0)
        detailsTableView.scrollIndicatorInsets = detailsTableView.contentInset
        setUpNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeRequiredValues() {
        // updating the values set during view initialization, would be required later.
        if countryName.isEmpty {
            countryLabel.text = ""
            countryTopConstraint.constant = 0
        } else {
            countryLabel.text = countryName
        }
        // setting topConstraintMinValue to status bar height of different devices, different for iphones prior to iphone x.
        minimumHeaderHeight += topConstraintMinValue
        maximumHeaderHeight += topConstraintMinValue
        initialMaxTopConstraint += topConstraintMinValue
        //setting the point value and other defined in storyboard as this will be required later to calculate the delta values in calculation later.
        maxCountryFontValue = countryLabel.font.pointSize
        maxNameFontValue = nameLabel.font.pointSize
        maximumInitialsHeight = userImageView.frame.size.height
        headerHeightConstraint.constant = maximumHeaderHeight
    }
    
    // avatar image, setting hardcoded intitials for now change for Image or Exact initials
    func updateUserAvatar() {
        let image = UIImage()
        let newImageWithOverlay = UIImage.createImageWithLabelOverlay(label: "JA", imageSize: userImageView.frame.size, image: image)
        userImageView.image = newImageWithOverlay
    }
    
    // setting up the navigation bar background image to blank to give it a feel similar to animation required where image goes in to navigation bar on scrolling
    func setUpNavigation() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Contact", style: .plain, target: self, action: nil)
    }

}

// setup dummy cells
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = "Cell \(indexPath.row)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // calling this func to handle the frame updations
        updateFrames(scrollView, animationNeeded: false)
    }
    
    func updateFrames(_ scrollView: UIScrollView, animationNeeded : Bool) {
        // checking with the current offset depending on which headerHeightConstraint is being updated.
        let yOffset = scrollView.contentOffset.y
        if !animationNeeded {
            if yOffset < -maximumHeaderHeight {
                headerHeightConstraint.constant = maximumHeaderHeight
            } else if yOffset < -minimumHeaderHeight {
                headerHeightConstraint.constant = yOffset * -1
            } else {
                headerHeightConstraint.constant = minimumHeaderHeight
            }
        }
        // after updating headerHeight subviews needs to be resized accordingly
        updateOtherItems(animationNeeded: animationNeeded)
    }
    
    func updateOtherItems(animationNeeded: Bool) {
        // finding out the pending percentage of headerHeight to be changed, can be reduced or increased.
        let range = self.maximumHeaderHeight - self.minimumHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minimumHeaderHeight
        let percentage = openAmount / range
        let totalTopConstraintDistance = initialMaxTopConstraint - topConstraintMinValue
        // need to get the reverse value as height will be max when percentage will be 1, the constValue will be used to update the top constraint value
        let constValue = totalTopConstraintDistance*(1 - percentage)
        // setting the alpha of the label based on percentage as we need to set alpha for this label to 0 when view reduces to minimum
        self.countryLabel.alpha = percentage
        initialsTopConstraint.constant = initialMaxTopConstraint - constValue
        if constValue <= initialMaxTopConstraint && constValue >= 0 {
            // calculating the delta value for imageview height
            // initially the height is max on scrolling as we are finding he delta with 1 - percent, substracting the heightConstValue from max will provide the new value.
            let totalHeightMargin = maximumInitialsHeight - minimumInitialsHeight
            let heightConstValue = totalHeightMargin*(1 - percentage)
            initialViewHeightConstraint.constant = maximumInitialsHeight - heightConstValue
            initialViewWidthConstraint.constant = maximumInitialsHeight - heightConstValue
        }
        // animation is needed to smoothen the transition when scrolling ends
        if animationNeeded {
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
        handleImageViewCornerRadiusChange(animationNeeded: animationNeeded)
        updateNameLabel(animationNeeded: animationNeeded, percentage: percentage)
    }
    
    func handleImageViewCornerRadiusChange(animationNeeded: Bool) {
        // animating the cornerRadius, prior to iOS 10 this was not possible, to handle this if we are required to support < iOS 10 use the below addCornerRadiusAnimation in UIView Extension.
        if #available(iOS 10.0, *), animationNeeded {
            UIViewPropertyAnimator(duration: animationDuration, curve: .easeIn) {
                self.userImageView.layer.cornerRadius = self.initialViewWidthConstraint.constant/2
                }.startAnimation()
        } else {
            userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        }
    }
    
    func updateNameLabel(animationNeeded: Bool, percentage: CGFloat) {
        // calculating the delta value same as it was done for topConstraint.
        let nameFontDelta = (maxNameFontValue - minNameFontValue)*(1 - percentage)
        let countryFontDelta = (maxCountryFontValue - minCountryFontValue)*(1 - percentage)
        let tempAnimationDuration = animationNeeded ? animationDuration : 0.0
        nameLabel.animate(font: UIFont(name: nameLabel.font.fontName, size: maxNameFontValue - nameFontDelta)!, duration: tempAnimationDuration)
        countryLabel.animate(font: UIFont(name: countryLabel.font.fontName, size: maxCountryFontValue - countryFontDelta)!, duration: tempAnimationDuration)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleFinalSync()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // checking if this func is not called when scrollViewDidEndDecelerating will also get called
            handleFinalSync()
        }
    }
    
    func handleFinalSync() {
        // handling if on scrollingEnd header needs to be max or min
        let range = maximumHeaderHeight - minimumHeaderHeight
        let midPoint = minimumHeaderHeight + (range / 2)
        // height of header is more than the midpoint, so make the header height max now
        if headerHeightConstraint.constant > midPoint {
            headerHeightConstraint.constant = maximumHeaderHeight
            updateOtherItems(animationNeeded: true)
            // Stops native deceleration, we do not need to call scrollDidScroll here.
            animateTableOffset(yOffset: -maximumHeaderHeight)
        } else {
            headerHeightConstraint.constant = minimumHeaderHeight
            updateOtherItems(animationNeeded: true)
            if detailsTableView.contentOffset.y < -minimumHeaderHeight {
                // Stops native deceleration, we do not need to call scrollDidScroll here.
                animateTableOffset(yOffset: -minimumHeaderHeight)
            }
        }
    }
    
    func animateTableOffset(yOffset: CGFloat) {
        let point = CGPoint(x: 0, y: yOffset)
        UIView.animate(withDuration: animationDuration) {
            self.detailsTableView.setContentOffset(point, animated: false)
        }
    }
    
}

extension UILabel {
    func animate(font: UIFont, duration: TimeInterval) {
        let labelScale = self.font.pointSize / font.pointSize
        self.font = font
        let oldTransform = transform
        transform = transform.scaledBy(x: labelScale, y: labelScale)
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: duration) {
            self.transform = oldTransform
            self.layoutIfNeeded()
        }
    }
}

extension UIView
{
    func addCornerRadiusAnimation(from: CGFloat, to: CGFloat, duration: CFTimeInterval)
    {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        layer.add(animation, forKey: "cornerRadius")
        layer.cornerRadius = to
    }
}

extension UIImage {
    
    class func createImageWithLabelOverlay(label: String,imageSize: CGSize, image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height), false, 2.0)
        let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let currentImage = UIImageView.init(image: image)
        currentImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        let currentLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        currentLabel.font = UIFont(name: "Helvetica", size: 28)!
        currentLabel.textAlignment = .center
        currentLabel.text = label
        currentView.addSubview(currentImage)
        currentView.addSubview(currentLabel)
        currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
}
