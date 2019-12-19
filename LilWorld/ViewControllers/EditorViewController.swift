//
//  EditorViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 28/08/15.
//  Copyright (c) 2015 Adno. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord
import MZFormSheetPresentationController
import DACircularProgress
import ImageIO
import AVFoundation


class EditorViewController: UIViewController {

    var startImage: UIImage? = nil
	var startStickers: [UIImageView]? = []
    var currentBigImage: UIImage? = nil
    var operatingImage: UIImage? = nil
    var imageChanged = false
    var onTopState = false
    
    var eraserMode = false
    var lastPoint = CGPoint.zero
    var red: CGFloat = 1.0
    var green: CGFloat = 1.0
    var blue: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    var swiped = false
	
    //MARK: - Views
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topControlsView: UIView!
    @IBOutlet weak var arrowDownCloseButton: UIButton!
    @IBOutlet weak var topMenuButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var eraserWidthSlider: UISlider!
    @IBOutlet weak var eraserSizeIndicator: UIView!
    @IBOutlet weak var eraserStepBackButton: UIButton!
    
    var watermark: UIButton?
    var currentSelectedImageView: SelectableImageView? = nil
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var cropTitleLabel: UILabel!
    @IBOutlet weak var rotateTitleLabel: UILabel!
    @IBOutlet weak var filtersSlider: UISlider!
    @IBOutlet weak var editObjectTitle: UILabel!
    @IBOutlet weak var rotatingImageView: UIImageView!
    @IBOutlet weak var rotationSlider: RotationSlider!
    @IBOutlet weak var objectOpacitySlider: UISlider!
    @IBOutlet weak var objectBrightnessSlider: UISlider!
    
    //MARK: - Containers
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var containerForEditToolsCollectionView: UIView!
    @IBOutlet weak var containerViewForSecondLevelCollectionView: UIView!
    @IBOutlet weak var containerForFiltersView: UIView!
    @IBOutlet weak var containerForRotationViews: UIView!
    @IBOutlet weak var containerForRotateTools: UIView!
    @IBOutlet weak var containerForCropViews: UIView!
    @IBOutlet weak var containerForCropTools: UIView!
    @IBOutlet weak var containerForEditObject: UIView!
    
    //MARK: - CollectionViews
    @IBOutlet weak var firstLevelCollectionView: UICollectionView!
    @IBOutlet weak var secondLevelCollectionView: UICollectionView!
    @IBOutlet weak var thirdLevelCollectionView: UICollectionView!
    @IBOutlet weak var editToolsCollectionView: UICollectionView!
    @IBOutlet weak var cropToolsCollectionView: UICollectionView!
    
    //MARK: - Constraints
    @IBOutlet weak var firstLevelCollectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewForSecondLevelCollectionViewBottomConstraint: NSLayoutConstraint!
    weak var thirdLevelCollectionViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: - Selection indices
    var firstLevelSelectedIndex = -1
    var secondLevelSelectedIndex = -1
    
    //MARK: - FetchedResultsControllers
    fileprivate var _firstLevelFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    fileprivate var _secondLevelFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    fileprivate var _thirdLevelFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    //MARK: - Rotation
    @IBOutlet weak var blackoutWithHoleForRotation: BlackoutWithHole!
    fileprivate var currentBigImageRotationAngle: Double = 0
    
    //MARK: - Crop
    @IBOutlet weak var blackoutWithHoleForCrop: BlackoutWithHole!
    @IBOutlet weak var croppingImageView: UIImageView!
    fileprivate var currentCropMode: CropMode = .free
    
    //MARK: - Filters
    fileprivate let colorFilter: CIFilter = CIFilter(name: "CIColorControls")!
    fileprivate let brightnessFilter: CIFilter = CIFilter(name: "CIExposureAdjust")!
    fileprivate let context: CIContext = CIContext.lw_context(options: nil)
    fileprivate var currentFilter: Filter?
    fileprivate var lastSavedFilterValue: Float?
    fileprivate var originalOrientation: UIImageOrientation = .up
    fileprivate var originalScale: CGFloat = 1.0
    fileprivate var currentSliderValue: Float = 0
    
    fileprivate var currentStickerIndex: Int? = nil
    fileprivate var currentStickers: Array<StickerInfo> = []
    fileprivate var currentObjectInitialAlpha: CGFloat? = nil
    fileprivate var currentObjectInitialBrightness: Float? = nil
    fileprivate var currentObjectInitialImage: UIImage? = nil
    fileprivate weak var currentTextEditImage: TextImageView?
    fileprivate var erasingImageStepBackImage: CIImage? = nil
    fileprivate var eraserTouchesEnded: Bool = true
	
	fileprivate var maxFrames = 30
	fileprivate var fps = 6
	fileprivate var isVideo = false
	fileprivate var progressView: DACircularProgressView!
	fileprivate var maxAnimations = 5
	var timer: Timer?
	
    class StickerInfo {
        var imageView: UIImageView
        var alpha: CGFloat
        var brightnessFilter: CIFilter! = nil
        var context: CIContext! = nil
        
        init(imageView: UIImageView, alpha: CGFloat, needFilters: Bool = true) {
            self.imageView = imageView
            self.alpha = alpha
            if needFilters {
                brightnessFilter = CIFilter(name: "CIExposureAdjust")!
                brightnessFilter.setValue(CIImage(image: imageView.image!), forKey: kCIInputImageKey)
                context = CIContext.lw_context(options: nil)
            }
        }
		
		init(imageView: UIImageView, alpha: CGFloat) {
			self.imageView = imageView
			self.alpha = alpha
			brightnessFilter = CIFilter(name: "CIExposureAdjust")!
			brightnessFilter.setValue(CIImage(), forKey: kCIInputImageKey)
			context = CIContext.lw_context(options: nil)
		}
    }
	
    fileprivate struct Constants {
        static let initialImageWidth = CGFloat(150)
        static let objectActionButtonsSize = 40.0
        static let firstLevelCollectionViewCellTitleAttributes = [
            NSFontAttributeName : UIFont(name: "Circe-Regular", size: 12)!,
            NSKernAttributeName: GlobalConstants.kMainFontKern
        ]
        static let lettersSectionId = 2
    }
    
    var firstLevelFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _firstLevelFetchedResultsController == nil {
            _firstLevelFetchedResultsController = Section.mr_fetchAllGrouped(by: "section_id", with: NSPredicate(format:"parent_id = 0"), sortedBy: "position", ascending: true)
        }
        return _firstLevelFetchedResultsController!
    }
    
    var secondLevelFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _secondLevelFetchedResultsController == nil {
            let parent_id = firstLevelSelectedIndex >= 0 ? (firstLevelFetchedResultsController.fetchedObjects![firstLevelSelectedIndex] as! Section).section_id : -1
            _secondLevelFetchedResultsController = Section.mr_fetchAllGrouped(by: "section_id", with: NSPredicate(format:"parent_id = \(parent_id)"), sortedBy: "position", ascending: true)
        }
        return _secondLevelFetchedResultsController!
    }
    
    var thirdLevelFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _thirdLevelFetchedResultsController == nil {
            let parent_id = secondLevelSelectedIndex >= 0 ? (secondLevelFetchedResultsController.fetchedObjects![secondLevelSelectedIndex + (firstLevelSelectedIndex == Constants.lettersSectionId ? -1 : 0)] as! Section).section_id : -1
            _thirdLevelFetchedResultsController = Sticker.mr_fetchAllGrouped(by: "sticker_id", with: NSPredicate(format:"section_id = \(parent_id)"), sortedBy: "position", ascending: true)
        }
        return _thirdLevelFetchedResultsController!
    }
	
}

//MARK: - Lifecycle

extension EditorViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if !currentStickers.isEmpty {
			for el in currentStickers {
				addImageOnEditorView(getImageForSticker(el))
			}
		}
        
        if let startImage = startImage {
            let startImageIgnoringOrientation = startImage.normalizedImage()
            let smallImage = getReducedSizeImageWithImage(startImageIgnoringOrientation)
            operatingImage = smallImage
            imageView.image = smallImage
            colorFilter.setValue(CIImage(image: smallImage), forKey: kCIInputImageKey)
            currentBigImage = startImageIgnoringOrientation
            originalOrientation = smallImage.imageOrientation
            originalScale = smallImage.scale
        }
        
        let tapOnContainerImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnContainerImage(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(tapOnContainerImageRecognizer)
        
        if !StoreHelper.fullVersionPurchased && StoreHelper.sharedInstance.getPurchasedProductsIds().count == 0 {
            addWatermark()
        }
        
        filtersSlider.setThumbImage(UIImage(named: "filters_slider_thumb"), for: .normal)
        filtersSlider.setMinimumTrackImage(UIImage(named: "filter_slider_active_line"), for: .normal)
        filtersSlider.setMaximumTrackImage(UIImage(named: "filter_slider_active_line"), for: .normal)

        rotationSlider.setup()
        rotationSlider.delegate = self
        
        objectOpacitySlider.setThumbImage(UIImage(named: "pointer_medium"), for: .normal)
        objectBrightnessSlider.setThumbImage(UIImage(named: "pointer_medium"), for: .normal)
        
        eraserWidthSlider.setThumbImage(UIImage(), for: .normal)
        eraserWidthSlider.setMinimumTrackImage(UIImage(named: "eraser_slider_line_normal"), for: .normal)
        eraserWidthSlider.setMaximumTrackImage(UIImage(named: "eraser_slider_line_normal"), for: .normal)
        eraserWidthSlider.setMinimumTrackImage(UIImage(named: "eraser_slider_line_selected"), for: .selected)
        eraserWidthSlider.setMaximumTrackImage(UIImage(named: "eraser_slider_line_selected"), for: .selected)
        
        eraserSizeIndicator.backgroundColor = UIColor.clear
        eraserSizeIndicator.layer.borderColor = UIColor.white.cgColor
        eraserSizeIndicator.layer.borderWidth = 1
		
		if (startStickers != nil) && !(startStickers?.isEmpty)! {
			addStartStickers(imageViews: startStickers!)
			hideEditObject()
		}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(EditorViewController.saveEditorVCState), userInfo: nil, repeats: true)
		
		self.progressView = DACircularProgressView(frame: CGRectMake(center: self.view.center, size: CGSize.init(width: 40, height: 40)))
		self.progressView.trackTintColor = UIColor.clear
        
        mainContainer.sendToBack()
        
        hideRotation()
        hideCrop()
        containerForFiltersView.sendToBack()
        
        updateViewWithCurrentPurchases()
        if editButton.isSelected {
            containerForEditToolsCollectionView.bringToFront()
        }
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		timer?.invalidate()
		saveEditorVCState()
	}
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupMainImageView()
    }
}

//MARK: - Private

extension EditorViewController {
	
	fileprivate func addStartStickers(imageViews: [UIImageView]) {
		for iv in imageViews{
				if (iv.animationImages != nil) {
					UIImage.animatedImage(with: iv.animationImages!,
				                      duration: Double(iv.animationImages!.count / fps))
				
					addImageOnEditorView(iv.image!, center: iv.center, transforme: iv.transform)
					maxAnimations -= 1
				} else {
					if (iv.image?.images != nil){
						UIImage.animatedImage(with: (iv.image?.images)!,
					                      duration: Double((iv.image?.images?.count)! / fps))
						addImageOnEditorView(iv.image!, center: iv.center, transforme: iv.transform)
						maxAnimations -= 1
					} else {
						addImageOnEditorView(iv.image!, center: iv.center, transforme: iv.transform)
					}
				}
		}
	}
	
	func saveEditorVCState() {
		
		var imageViewSubHash = [Int]()
		var trueArray = [StickerInfo]()
		for views in self.imageView.subviews {
			imageViewSubHash.append(views.hashValue)
			for el in self.currentStickers {
				if el.imageView.hashValue == views.hashValue {
					trueArray.append(el)
				}
			}
		}
		self.currentStickers = trueArray
		
		UserDefaults.standard.removeObject(forKey: "background")
		UserDefaults.standard.removeObject(forKey: "stickers")
		UserDefaults.standard.removeObject(forKey: "stickerImagesData")
		UserDefaults.standard.synchronize()
		
		UserDefaults.standard.set(UIImageJPEGRepresentation(self.currentBigImage!, 1), forKey: "background")
		
		var stickers = [UIImageView]()
		var stickerImagesData = [Data]()
		for n in self.currentStickers {
			stickers.append(n.imageView)
			if ((n.imageView.image?.images) == nil) {
				stickerImagesData.append(UIImagePNGRepresentation(n.imageView.image!)!)
			}
		}
		UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: stickers), forKey: "stickers")
		UserDefaults.standard.set(stickerImagesData, forKey: "stickerImagesData")
		UserDefaults.standard.synchronize()
	}
	
	func removeEditorVCState() {
		UserDefaults.standard.removeObject(forKey: "background")
		UserDefaults.standard.removeObject(forKey: "stickers")
		UserDefaults.standard.removeObject(forKey: "stickerImagesData")
		UserDefaults.standard.synchronize()
	}
	
    fileprivate func addWatermark() {
        let watermarkImage = UIImage(named: "watermark_normal")!
        watermark = Watermark(type: UIButtonType.custom)
        watermark?.addTarget(self, action: #selector(watermarkPressed), for: .touchUpInside)
        imageView.addSubview(watermark!)
        watermark?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        updateWatermarkFrame()
        watermark?.frame = CGRect(x: imageView.frame.width - watermark!.frame.width - 12, y: imageView.frame.height - watermark!.frame.height - 6, width: watermarkImage.size.width, height: watermarkImage.size.height)
    }
    
	@discardableResult fileprivate func addImageOnEditorView(_ image: UIImage, text: Bool = false, textParams: TextParams? = nil, center: CGPoint? = nil, transforme: CGAffineTransform? = nil) -> SelectableImageView {
        imageChanged = true
		
        deselectCurrentSelectedImage()
        
        let newImageView = text ? TextImageView(image: image, textParams: textParams!) : StickerImageView(image: image)
        newImageView.autoresizingMask = UIViewAutoresizing()
        self.imageView.addSubview(newImageView)
        let initialImageHeight = initialHeightForSize(image.size)
        let initialImageWidth = Constants.initialImageWidth
        if let center = center {
            newImageView.frame = CGRectMake(center: center, size: CGSize(width: initialImageWidth, height: initialImageHeight))
			if let transforme = transforme {
				newImageView.transform = transforme
			}
        } else {
            var initialX = (self.imageView.frame.size.width - initialImageWidth) * 0.5 + initialImageWidth * (CGFloat.random() - 1) / 2
            var initialY = (self.imageView.frame.size.height - initialImageHeight) * 0.5 + initialImageHeight * (CGFloat.random() - 1) / 2
            initialX = max(min(initialX, self.imageView.frame.size.width - initialImageWidth), 0)
            initialY = max(min(initialY, self.imageView.frame.size.height - initialImageHeight), 0)
            newImageView.frame = CGRect(x: initialX, y: initialY, width: initialImageWidth, height: initialImageHeight)
        }
        
        newImageView.addGestureRecognizers(self)
        if let watermark = self.watermark {
            watermark.superview?.bringSubview(toFront: watermark)
        }
        
        let newSticker = StickerInfo(imageView: newImageView, alpha: 1.0, needFilters: newImageView is StickerImageView)
        currentStickers.append(newSticker)
        
        selectImageView(newImageView)
        
        return newImageView
    }

    fileprivate func getImageToShare() -> UIImage {
        
        guard let currentBigImage = currentBigImage else {
            return UIImage()
        }
        
        let filteredBigImage = getFilteredImageFromImage(currentBigImage)
        let scale = currentBigImage.size.width / imageView.frame.width
        let contextSize = filteredBigImage.size
        UIGraphicsBeginImageContextWithOptions(contextSize, imageView.isOpaque, 1.0)
        filteredBigImage.draw(in: CGRect(x: 0, y: 0, width: filteredBigImage.size.width, height: filteredBigImage.size.height))
		
        for selectableImageView in imageView.subviews {
            if let indexOfSticker = currentStickers.index(where: { (sticker) -> Bool in
                sticker.imageView == selectableImageView
            }) {
                let sticker = currentStickers[indexOfSticker]
                if let stickerSuperview = sticker.imageView.superview,
                    var stickerImage = sticker.imageView.image {
                    if let textImageView = sticker.imageView as? TextImageView,
                        let textParams = textImageView.textParams {
                        let text: NSString = textParams.text as NSString
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        let attributes = [
                            NSFontAttributeName: UIFont(name: textParams.fontName, size: text.length > 50 ? 200 : 300)!,
                            NSForegroundColorAttributeName: textParams.textColor,
                            NSParagraphStyleAttributeName: paragraphStyle
                        ]
                        let size = (textParams.text as NSString).size(attributes: attributes)
                        let textImage =  UIImage.imageWithString(textParams.text as NSString, attributes: attributes, size: size)
                        stickerImage = textImage
                    }
                    let relativeCenter = CGPoint(x: sticker.imageView.center.x / stickerSuperview.frame.width, y: sticker.imageView.center.y / stickerSuperview.frame.height)
                    
                    var transformRotationInRadians = -atan2f(Float(sticker.imageView.transform.b), Float(sticker.imageView.transform.a))
                    if stickerImage.imageOrientation != .up {
                        transformRotationInRadians *= -1
                    }
                    let rotatedImage = stickerImage.imageRotatedByRadians(-CGFloat(transformRotationInRadians))
//                    rotatedImage = UIImage(CGImage: rotatedImage.CGImage!, scale: rotatedImage.scale, orientation: stickerImage.imageOrientation)
                    let stickerSize = CGSize(width: sticker.imageView.frame.width * scale, height: sticker.imageView.frame.height * scale)
                    let stickerFullRect = CGRect(x: contextSize.width * relativeCenter.x - stickerSize.width * 0.5, y: contextSize.height * relativeCenter.y - stickerSize.height * 0.5, width: stickerSize.width, height: stickerSize.height)
                    
                    rotatedImage.draw(in: stickerFullRect)
                }
            }
        }
        
        if watermark != nil {
            let watermarkImage = UIImage(named: "watermark_full_size")!
            let imageWidth = contextSize.width * 0.25
            let watermarkImageSize = CGSize(width: imageWidth, height: imageWidth * watermarkImage.size.height / watermarkImage.size.width)
            
            watermarkImage.draw(in: CGRect(x: contextSize.width - watermarkImageSize.width, y: contextSize.height - watermarkImageSize.height, width: watermarkImageSize.width, height: watermarkImageSize.height))
        }
        
        let imageToShare = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return imageToShare
    }
	
	fileprivate func imagesInIVs(iv: UIImageView) -> Int {
		var count = 0
			if (iv.animationImages != nil) {
				if (count < (iv.animationImages?.count)!){
					count = (iv.animationImages?.count)!
				}
			} else {
				if (count < (iv.image?.images?.count)!) {
					count = (iv.image?.images?.count)!
				}
			}
		return count
	}
	
	fileprivate func increaseImageCountInIV(iv: UIImageView) -> UIImage {
		var newArr = [UIImage]()
		var count2 = 0
		if (iv.animationImages != nil) {
			let count = iv.animationImages?.count
			for _ in 1...maxFrames {
				newArr.append((iv.animationImages?[count2])!)
				count2 += 1
				if count2 == count {
					count2 = 0
				}
			}
		} else {
			for _ in 1...maxFrames {
				if (iv.image?.images != nil){
					let count = iv.image?.images?.count
					newArr.append((iv.image?.images?[count2])!)
					count2 += 1
					if count2 == count {
						count2 = 0
					}
				} else {
					newArr.append(iv.image!)
				}
			}
		}
		iv.image = UIImage.animatedImage(with: newArr, duration: Double(newArr.count / fps))
		return iv.image!
	}
	
	fileprivate func combineOneCadr(bottomImage: UIImage, images: [UIImage], rectes: [CGRect], transform: [Float]) -> UIImage {
		var newImage = UIImage()
		let newSize = bottomImage.size
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
		autoreleasepool {
		bottomImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
		for n in 0...images.count-1{
				var trans = transform[n]
				if images[n].imageOrientation != .up {
					trans *= -1
				}
				images[n].imageRotatedByRadians(-CGFloat(trans)).draw(in: rectes[n])
		}
		
		if watermark != nil {
			let watermarkImage = UIImage(named: "watermark_full_size")!
			let imageWidth = newSize.width * 0.25
			let watermarkImageSize = CGSize(width: imageWidth, height: imageWidth * watermarkImage.size.height / watermarkImage.size.width)
			
			watermarkImage.draw(in: CGRect(x: newSize.width - watermarkImageSize.width, y: newSize.height - watermarkImageSize.height, width: watermarkImageSize.width, height: watermarkImageSize.height))
		}
		}

		newImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	
	fileprivate func resizeStickerToRealSize(frame: CGRect, backgroundImage: UIImage) -> CGRect {
		
			let y = backgroundImage.size.height * (frame.origin.y / imageView.frame.height)
			let x = backgroundImage.size.width * (frame.origin.x / imageView.frame.width)
			let h = backgroundImage.size.height * (frame.size.height / imageView.frame.size.height)
			let w = backgroundImage.size.width * (frame.size.width / imageView.frame.size.width)
			
			let newFrame = CGRect.init(origin: CGPoint.init(x: x, y: y), size: CGSize.init(width: w, height: h))
		
		return newFrame
	}
	
	//background image compression
	func resizeImage(image: UIImage) -> UIImage {
		var actualHeight: Float = Float(image.size.height)
		var actualWidth: Float = Float(image.size.width)
		let maxHeight: Float = 1600
		let maxWidth: Float = 1600
		var imgRatio: Float = actualWidth / actualHeight
		let maxRatio: Float = maxWidth / maxHeight
		let compressionQuality: Float = 1.0
		//100 percent compression
		
		if actualHeight > maxHeight || actualWidth > maxWidth {
			if imgRatio < maxRatio {
				//adjust width according to maxHeight
				imgRatio = maxHeight / actualHeight
				actualWidth = imgRatio * actualWidth
				actualHeight = maxHeight
			}
			else if imgRatio > maxRatio {
				//adjust height according to maxWidth
				imgRatio = maxWidth / actualWidth
				actualHeight = imgRatio * actualHeight
				actualWidth = maxWidth
			}
			else {
				actualHeight = maxHeight
				actualWidth = maxWidth
			}
		}
		
		let rect = CGRect.init(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
		UIGraphicsBeginImageContext(rect.size)
		image.draw(in: rect)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		let imageData = UIImageJPEGRepresentation(img!,CGFloat(compressionQuality))
		UIGraphicsEndImageContext()
		return UIImage(data: imageData!)!
	}
	
	fileprivate func createVideo(arrayOfStickers: [UIImageView], outputSize: CGSize, progress: @escaping ((Progress) -> Void)) {
		var tempArray = [UIImage]()
		var arrStickersCadrs = [UIImage]()
		var arrOfRect = [CGRect]()
		var transformRotationInRadians = [Float]()
		
		let fileManager = FileManager.default
		let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
		guard let documentDirectory: URL = urls.first else {
			fatalError("documentDir Error")
		}
		
		let videoOutputURL = documentDirectory.appendingPathComponent("AssembledVideo.mov")
		
		if FileManager.default.fileExists(atPath: videoOutputURL.path) {
			do {
				try FileManager.default.removeItem(atPath: videoOutputURL.path)
			}catch{
				fatalError("Unable to delete file: \(error) : \(#function).")
			}
		}
		
		guard let videoWriter = try? AVAssetWriter(outputURL: videoOutputURL, fileType: AVFileTypeQuickTimeMovie) else{
			fatalError("AVAssetWriter error")
		}
		
		let outputSettings = [
			AVVideoCodecKey  : AVVideoCodecH264,
			AVVideoWidthKey  : NSNumber(value: Float(outputSize.width) as Float),
			AVVideoHeightKey : NSNumber(value: Float(outputSize.height) as Float),
			] as [String : Any]
		
		guard videoWriter.canApply(outputSettings: outputSettings, forMediaType: AVMediaTypeVideo) else {
			fatalError("Negative : Can't apply the Output settings...")
		}
		
		let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
		
		let sourcePixelBufferAttributesDictionary = [
			kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB as UInt32),
			kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width) as Float),
			kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height) as Float),
			]
		
		let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
			assetWriterInput: videoWriterInput,
			sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary
		)
		
		assert(videoWriter.canAdd(videoWriterInput))
		videoWriter.add(videoWriterInput)
		
		if videoWriter.startWriting() {
			videoWriter.startSession(atSourceTime: kCMTimeZero)
			assert(pixelBufferAdaptor.pixelBufferPool != nil)
			
			let media_queue = DispatchQueue(label: "mediaInputQueue", attributes: [])
			
			videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { () -> Void in
				let fps: Int32 = 6
				let frameDuration = CMTimeMake(1, fps)
				let currentProgress = Progress(totalUnitCount: Int64(self.maxFrames))
				
				var frameCount: Int64 = 0
				let bottomImage = self.resizeImage(image: self.currentBigImage!)
				
				for iv in arrayOfStickers{
					if iv.image?.images == nil {
						let img = iv.image
						tempArray.append(self.increaseImageCountInIV(iv: iv))
						iv.image = img
					} else {
						tempArray.append(self.increaseImageCountInIV(iv: iv))
					}
					arrOfRect.append(self.resizeStickerToRealSize(frame: iv.frame, backgroundImage: bottomImage))
					transformRotationInRadians.append(-atan2f(Float(iv.transform.b), Float(iv.transform.a)))
				}
				
				for n in 0...self.maxFrames-1 {
					
					//loop for add every image of stickers
						for ivA in tempArray{
							arrStickersCadrs.append((ivA.images?[n])!)
						}
						//combine full cadr
					let img = self.combineOneCadr(bottomImage: bottomImage,images: arrStickersCadrs, rectes: arrOfRect, transform: transformRotationInRadians)
						arrStickersCadrs = []
					
					if (videoWriterInput.isReadyForMoreMediaData) {
						let lastFrameTime = CMTimeMake(frameCount, fps)
						let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
						
						
						if !self.appendPixelBufferForImageAtURL(img, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
							
							break
						}
						
						frameCount += 1
						currentProgress.completedUnitCount = frameCount
						progress(currentProgress)
					}
				}
				
				videoWriterInput.markAsFinished()
				videoWriter.finishWriting { () -> Void in
					print("SUCCESS: \(videoOutputURL)")
					DispatchQueue.main.async{
						self.progressView.isHidden = true
						self.performSegue(withIdentifier: "ShareImageVCShowSegue", sender: videoOutputURL)
					}
				}
			})
			
		}
	}
	
	open func appendPixelBufferForImageAtURL(_ photoImage: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
		var appendSucceeded = true
		
		autoreleasepool {
			
			var pixelBuffer: CVPixelBuffer? = nil
			let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferAdaptor.pixelBufferPool!, &pixelBuffer)
			
			if let pixelBuffer = pixelBuffer, status == 0 {
				let managedPixelBuffer = pixelBuffer
				
				fillPixelBufferFromImage(photoImage, pixelBuffer: managedPixelBuffer, contentMode: UIViewContentMode.scaleAspectFit, outputSize: self.resizeImage(image: self.currentBigImage!).size)
				
				appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
				
			} else {
				NSLog("error: Failed to allocate pixel buffer from pool")
			}
		}
		
		return appendSucceeded
	}
	
	func fillPixelBufferFromImage(_ image: UIImage, pixelBuffer: CVPixelBuffer, contentMode:UIViewContentMode, outputSize: CGSize){
		
		CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
		
		let data = CVPixelBufferGetBaseAddress(pixelBuffer)
		let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
		let context = CGContext(data: data, width: Int(outputSize.width), height: Int(outputSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
		
		context?.clear(CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
		
		let horizontalRatio = outputSize.width / image.size.width
		let verticalRatio = outputSize.height / image.size.height
		var ratio: CGFloat = 1
		
		switch(contentMode) {
		case .scaleAspectFill:
			ratio = max(horizontalRatio, verticalRatio)
		case .scaleAspectFit:
			ratio = min(horizontalRatio, verticalRatio)
		default:
			ratio = min(horizontalRatio, verticalRatio)
		}
		
		let newSize:CGSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
		
		let x = newSize.width < outputSize.width ? (outputSize.width - newSize.width) / 2 : 0
		let y = newSize.height < outputSize.height ? (outputSize.height - newSize.height) / 2 : 0
		
		context?.draw(image.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
		
		CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
	}
	
    fileprivate func deselectCurrentSelectedImage() {
        if let selectedImageView = currentSelectedImageView {
            selectedImageView.deselect()
            currentSelectedImageView = nil
            currentObjectInitialAlpha = nil
            currentObjectInitialImage = nil
            currentObjectInitialBrightness = nil
        }
    }
    
    fileprivate func setImageWithFilterValue(_ value: Float) {
        guard let currentFilter = currentFilter else {
            return
        }
        switch currentFilter {
        case .brightness:
            brightnessFilter.setValue(value, forKey: "inputEV")
        case .contrast:
            colorFilter.setValue(value, forKey: "inputContrast")
        case .saturation:
            colorFilter.setValue(value, forKey: "inputSaturation")
        default:
            break
        }
        
        imageView?.image = getCurrentFilteredImage()
    }
    
    fileprivate func getImageForSticker(_ sticker: StickerInfo) -> UIImage {
        let outputImage = sticker.brightnessFilter.outputImage
        let afterBrightnessCGImage = sticker.context.createCGImage(outputImage!, from: sticker.brightnessFilter.outputImage!.extent)!
        let afterBrightnessImage = UIImage(cgImage: afterBrightnessCGImage, scale: 1.0, orientation: .up)
        return afterBrightnessImage.imageWithAlpha(sticker.alpha)
    }
    
    fileprivate func getCurrentFilteredImage() -> UIImage {
        brightnessFilter.setValue(colorFilter.outputImage!, forKey: "inputImage")
        let afterGammaImage = context.createCGImage(brightnessFilter.outputImage!, from: brightnessFilter.outputImage!.extent)!
        return UIImage(cgImage: afterGammaImage, scale: originalScale, orientation: originalOrientation)
    }
    
    fileprivate func getFilteredImageFromImage(_ image: UIImage) -> UIImage {
        let localColorFilter = colorFilter.copy() as! CIFilter
        let localBrightnessFilter = brightnessFilter.copy() as! CIFilter
        let localContext = CIContext.lw_context(options: nil)
        localColorFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let colorFilterImage = localColorFilter.outputImage!
        localBrightnessFilter.setValue(colorFilterImage, forKey: kCIInputImageKey)
        let cgImage = localContext?.createCGImage(localBrightnessFilter.outputImage!, from: localBrightnessFilter.outputImage!.extent)!
        return UIImage(cgImage: cgImage!, scale: originalScale, orientation: originalOrientation)
    }
    
    fileprivate func hideRotation() {
        containerForRotateTools.sendToBack()
        containerForRotationViews.sendToBack()
        containerForRotationViews.isHidden = true
    }
    
    fileprivate func hideCrop() {
        containerForCropTools.sendToBack()
        containerForCropViews.sendToBack()
        containerForCropViews.isHidden = true
    }

    fileprivate func getReducedSizeImageWithImage(_ image: UIImage) -> UIImage {
        return image.imageScaledToWidth(Float(ScreenSize.SCREEN_WIDTH_IN_PIXELS))
    }
    
    fileprivate func updateWatermarkFrame() {
        if let watermark = watermark,
            let superview = watermark.superview {
            watermark.frame = CGRect(x: superview.frame.width - watermark.frame.width - 12, y: superview.frame.height - watermark.frame.height - 6, width: watermark.frame.width, height: watermark.frame.height)
        }
    }
    
    fileprivate func setupMainImageView() {
        imageView.fitInSuperview()
        updateWatermarkFrame()
    }
    
    fileprivate func initialHeightForSize(_ size: CGSize) -> CGFloat {
        return Constants.initialImageWidth * size.height / size.width
    }
    
    fileprivate func initialRadiusForSize(_ size: CGSize) -> CGFloat {
        return sqrt(pow(Constants.initialImageWidth, 2) + pow(initialHeightForSize(size), 2)) / 2
    }
    
    fileprivate func hideEditObject() {
        containerForEditObject.sendToBack()
        containerForEditObject.isHidden = true
//        eraserMode = false
//        setupWithEraserMode(eraserMode)
    }
    
    fileprivate  func removeImageViewFromCurrentStickers(_ imageView: UIImageView) {
        if let index = currentStickers.index(where: { (sticker) -> Bool in sticker.imageView == imageView}) {
            currentStickers.remove(at: index)
        }
    }
    
    fileprivate func updateViewWithCurrentPurchases() {
        if StoreHelper.fullVersionPurchased || StoreHelper.sharedInstance.getPurchasedProductsIds().count > 0 {
            if watermark != nil {
                watermark?.removeFromSuperview()
                watermark = nil
            }
        }
        if onTopState {
            if _thirdLevelFetchedResultsController != nil {
                _thirdLevelFetchedResultsController = nil
                thirdLevelCollectionView.reloadData()
            }
        }
    }
}

//MARK: - Actions

extension EditorViewController {
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
		
        if imageChanged || ((startStickers != nil) && !(startStickers?.isEmpty)!) {
            let alertController = UIAlertController(title: localized("Alerts_startOverTitle"), message: localized("Alerts_startOverMessage"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: localized("Alerts_startOverNo"), style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: localized("Alerts_startOverYes"), style: .destructive, handler: { (action) in
				self.removeEditorVCState()
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
        
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func arrowDownButtonPressed(_ sender: UIButton) {
        animateToBottom()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
		
		saveEditorVCState()
		timer?.invalidate()
        if onTopState {
            animateToBottom()
        } else {
            self.coverWithForegroundViewWithColor(UIColor(red: 0.58, green: 0.68, blue: 0.9, alpha: 0.5), andSpinner: true)
			self.view.addSubview(self.progressView)
            hideEditObject()
            eraserMode = false
            setupWithEraserMode(eraserMode)
            deselectCurrentSelectedImage()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
				if self.currentStickers.count != 0  {
					var stickersInCadrs = [UIImageView]()
					for el in 0..<self.currentStickers.count {
						stickersInCadrs.append(self.currentStickers[el].imageView)
					}
					for el in stickersInCadrs {
						if ((el.animationImages != nil) || (el.image?.images != nil)) {
							self.isVideo = true
						}
					}
					if (self.isVideo) {
						self.isVideo = false
						print("Creating video !!!")
						self.createVideo(arrayOfStickers: stickersInCadrs, outputSize: self.resizeImage(image: self.currentBigImage!).size, progress: { (progress) -> Void in
							      DispatchQueue.main.async{
							        self.progressView.setProgress(CGFloat(Float(progress.fractionCompleted)), animated: true)
							      }
							})
					} else {
						let imageToShare = self.getImageToShare()
						DispatchQueue.main.async(execute: {
							self.performSegue(withIdentifier: "ShareImageVCShowSegue", sender: imageToShare)
						});
					}
				} else {
					let imageToShare = self.getImageToShare()
					DispatchQueue.main.async(execute: {
						self.performSegue(withIdentifier: "ShareImageVCShowSegue", sender: imageToShare)
					});
				}
			});
        }
    }
    
    @IBAction func topMenuButtonPressed(_ sender: UIButton) {
        doneButtonPressed(sender)
    }
    
    func watermarkPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let fullVersionVC = storyboard.instantiateViewController(withIdentifier: "FullVersionViewController") as! FullVersionViewController
       
        let presentationController = MZFormSheetPresentationViewController(contentViewController: fullVersionVC)
        presentationController.presentationController?.contentViewSize = CGSize(width: self.view.frame.width - 24, height: 180)
        presentationController.allowDismissByPanningPresentedView = true
        presentationController.contentViewCornerRadius = 2
        presentationController.presentationController?.shouldDismissOnBackgroundViewTap = true
        presentationController.presentationController?.shouldCenterVertically = true
        presentationController.willDismissContentViewControllerHandler = { vc in
            self.updateViewWithCurrentPurchases()
        }
        self.present(presentationController, animated: true, completion: nil)
    }
    
    func deleteButtonPressed(_ button: UIButton) {
        
        if let currentSelectedImageView = currentSelectedImageView {
            removeImageViewFromCurrentStickers(currentSelectedImageView)
        }
        hideEditObject()
        eraserMode = false
        setupWithEraserMode(eraserMode)

        currentSelectedImageView?.removeFromSuperview()
        currentSelectedImageView?.deselect()
        currentSelectedImageView = nil
		maxAnimations += 1
    }
    
    func copyButtonPressed(_ button: UIButton) {
        if let currentSelectedImageView = currentSelectedImageView,
           let image = currentSelectedImageView.image {
            var newCenter = currentSelectedImageView.center
            newCenter.x -= 30
            newCenter.y += 30
            if let textImageView = currentSelectedImageView as? TextImageView {
				
                let imageView = addImageOnEditorView(image, text: true, textParams: textImageView.textParams, center: newCenter)
                imageView.transform = currentSelectedImageView.transform
                imageView.updateActionButtonsFrames()
            } else if currentSelectedImageView is StickerImageView {
                eraserMode = false
                setupWithEraserMode(false)
				
				if (currentSelectedImageView.animationImages != nil) {
					if maxAnimations <= 0 {
						limitAnimation()
						return
					} else {
						UIImage.animatedImage(with: currentSelectedImageView.animationImages!,
					                      duration: Double(currentSelectedImageView.animationImages!.count / fps))
					
						let imageView = addImageOnEditorView(image, center: newCenter)
						imageView.transform = currentSelectedImageView.transform
						imageView.updateActionButtonsFrames()
						maxAnimations -= 1
					}
				} else {
					if (currentSelectedImageView.image?.images != nil){
						if maxAnimations <= 0 {
							limitAnimation()
							return
						} else {
							UIImage.animatedImage(with: (currentSelectedImageView.image?.images)!,
						                      duration: Double((currentSelectedImageView.image?.images?.count)! / fps))
							let imageView = addImageOnEditorView(image, center: newCenter)
							imageView.transform = currentSelectedImageView.transform
							imageView.updateActionButtonsFrames()
							maxAnimations -= 1
						}
					} else {
						let imageView = addImageOnEditorView(image, center: newCenter)
						imageView.transform = currentSelectedImageView.transform
						imageView.updateActionButtonsFrames()
					}
				}
				
				
            }
            
        }
    }
    
    func mirrorButtonPressed(_ button: UIButton) {
        guard let currentSelectedImageView = currentSelectedImageView else {
                return
        }
		if currentStickers[currentStickerIndex!].imageView.image?.images != nil {
			
			var rev = [UIImage]()
			for im in (currentStickers[currentStickerIndex!].imageView.image?.images!)! {
				let newImage = im.imageFlippedHorizontally()
				rev.append(newImage)
			}
			currentSelectedImageView.image = UIImage.animatedImage(with: rev, duration: Double(rev.count / fps))
		} else {
			if (currentStickers[currentStickerIndex!].imageView.animationImages != nil) {
				var rev = [UIImage]()
				for im in currentStickers[currentStickerIndex!].imageView.animationImages! {
					let newImage = im.imageFlippedHorizontally()
					rev.append(newImage)
				}
				
				currentSelectedImageView.image = UIImage.animatedImage(with: rev, duration: Double(rev.count / fps))
			} else {
				let oldImage = currentStickers[currentStickerIndex!].brightnessFilter!.value(forKey: kCIInputImageKey) as? CIImage
				let newImage = UIImage(ciImage: oldImage!).imageFlippedHorizontally()
				let newCIImage = CIImage(image: newImage)
				currentStickers[currentStickerIndex!].brightnessFilter!.setValue(newCIImage, forKey: kCIInputImageKey)
        
				currentSelectedImageView.image = getImageForSticker(currentStickers[currentStickerIndex!])
			}
		}
    }
	
	fileprivate func limitAnimation() {
		let alertController = UIAlertController(title: localized("Alerts_maxAnimationsTitle"), message: localized("Alerts_maxAnimationsMessage"), preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title:
			"Ok", style: .cancel, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
    func textEditButtonPressed(_ button: UIButton) {
        guard let currentSelectedTextImageView = currentSelectedImageView as? TextImageView else {
            return
        }
        currentTextEditImage = currentSelectedTextImageView
        showTextEdit()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        sender.isSelected = true
        
        containerForEditToolsCollectionView.bringToFront()
        editToolsCollectionView.reloadData()
        
        animateToBottom()
        
        firstLevelSelectedIndex = -1
        _firstLevelFetchedResultsController = nil
        firstLevelCollectionView.reloadData()
        
        secondLevelSelectedIndex = -1
        _secondLevelFetchedResultsController = nil
        secondLevelCollectionView.reloadData()
        
        _thirdLevelFetchedResultsController = nil
        thirdLevelCollectionView.reloadData()
        thirdLevelCollectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func filterSliderValueChanged(_ sender: UISlider) {
        guard let currentFilter = currentFilter else {
            return
        }
        let sliderValue = sender.value
        let step = currentFilter.getSliderStep()

        let newSteppedValue = roundf(sliderValue / step);
        let oldSteppedValue = roundf(currentSliderValue / step);
        
        if (newSteppedValue != oldSteppedValue) {
            currentSliderValue = sliderValue
            self.setImageWithFilterValue(sender.value)
        }
    }
 
    @IBAction func rotate90DegreesButtonPressed(_ sender: UIButton) {
        currentBigImageRotationAngle += .pi / 2
        if (currentBigImageRotationAngle >= .pi * 2) {
            currentBigImageRotationAngle -= .pi * 2
        }
        rotationSlider.setValue(0, animated: false)
        rotateImage90Degrees()
    }
	
    @IBAction func doneRotationButtonPressed(_ sender: UIButton) {
        if (currentBigImageRotationAngle != 0) {
            currentBigImage = currentBigImage!.imageRotatedByDegrees(CGFloat(180 / .pi * currentBigImageRotationAngle))
        }
        let croppedNoFilterImage = currentBigImage!.croppedWithTransform(rotatingImageView.transform)
        currentBigImage = croppedNoFilterImage
        let smallImage = getReducedSizeImageWithImage(currentBigImage!)
        
        colorFilter.setValue(CIImage(image: smallImage), forKey: kCIInputImageKey)
        imageView.image = getCurrentFilteredImage()
        setupMainImageView()
        
        hideRotation()
    }
    
    @IBAction func closeRotationButtonPressed(_ sender: UIButton) {
        hideRotation()
    }
    
    @IBAction func doneFilterButtonPressed(_ sender: UIButton) {
        currentFilter = nil
        lastSavedFilterValue = nil
        containerForFiltersView.sendToBack()
    }
    
    @IBAction func closeFilterButtonPressed(_ sender: UIButton) {
        setImageWithFilterValue(lastSavedFilterValue!)
        filtersSlider.value = lastSavedFilterValue!
        filtersSlider.layoutIfNeeded()
        currentFilter = nil
        containerForFiltersView.sendToBack()
    }
    
    @IBAction func doneCropButtonPressed(_ sender: UIButton) {
        let relativeCropRect = CGRect(x: blackoutWithHoleForCrop.holeFrame.origin.x / blackoutWithHoleForCrop.frame.width, y: blackoutWithHoleForCrop.holeFrame.origin.y / blackoutWithHoleForCrop.frame.height, width: blackoutWithHoleForCrop.holeFrame.width / blackoutWithHoleForCrop.frame.width, height: blackoutWithHoleForCrop.holeFrame.height / blackoutWithHoleForCrop.frame.height)
        let croppedNoFilterImage = currentBigImage!.croppedWithRelativeRect(relativeCropRect)
        currentBigImage = croppedNoFilterImage
        let smallImage = getReducedSizeImageWithImage(currentBigImage!)
        
        colorFilter.setValue(CIImage(image: smallImage), forKey: kCIInputImageKey)
        let stickersCenters = currentStickers.map { (stickerInfo) -> (image: UIImageView, center: CGPoint) in
            return (stickerInfo.imageView, CGPoint(x: stickerInfo.imageView.center.x / stickerInfo.imageView.superview!.frame.width, y: stickerInfo.imageView.center.y / stickerInfo.imageView.superview!.frame.height))
        }
        imageView.image = getCurrentFilteredImage()
        setupMainImageView()
        
        for stickerCenter in stickersCenters {
            if let superview = stickerCenter.image.superview {
                let newCenter = CGPoint(x: stickerCenter.center.x * superview.frame.width, y: stickerCenter.center.y * superview.frame.height)
                stickerCenter.image.center = newCenter
            }
        }
        hideCrop()
    }
    
    @IBAction func closeCropButtonPressed(_ sender: UIButton) {
        hideCrop()
    }
    
    @IBAction func closeEditObjectButtonPressed(_ sender: UIButton) {
		if ((currentSelectedImageView?.image!.images == nil) && (currentSelectedImageView?.animationImages == nil)) {
			hideEditObject()
			eraserMode = false
			setupWithEraserMode(eraserMode)

			if let currentSelectedImageView = currentSelectedImageView,
			let currentObjectInitialAlpha = currentObjectInitialAlpha,
			let currentObjectInitialBrightness = currentObjectInitialBrightness,
			let currentObjectInitialImage = currentObjectInitialImage {
				currentStickers[currentStickerIndex!].brightnessFilter.setValue(CIImage(image: currentObjectInitialImage), forKey: kCIInputImageKey)
				currentStickers[currentStickerIndex!].alpha = currentObjectInitialAlpha
				currentStickers[currentStickerIndex!].brightnessFilter.setValue(currentObjectInitialBrightness, forKey: "inputEV")
				currentSelectedImageView.image = getImageForSticker(currentStickers[currentStickerIndex!])
			}
			eraserMode = false
		}
//        setupWithEraserMode(false)
        deselectCurrentSelectedImage()
    }
    
    @IBAction func doneEditObjectButtonPressed(_ sender: UIButton) {
        hideEditObject()
        eraserMode = false
        setupWithEraserMode(false)
        deselectCurrentSelectedImage()
    }
    
    @IBAction func objectOpacitySliderValueChanged(_ sender: UISlider) {
        if let currentSelectedImageView = currentSelectedImageView {
            currentStickers[currentStickerIndex!].alpha = 1 - CGFloat(sender.value)
            currentSelectedImageView.image = getImageForSticker(currentStickers[currentStickerIndex!])
        }
    }
    
    @IBAction func objectBrightnessSliderValueChanged(_ sender: UISlider) {
        if let currentSelectedImageView = currentSelectedImageView {
            currentStickers[currentStickerIndex!].brightnessFilter.setValue(sender.value, forKey: "inputEV")
            currentSelectedImageView.image = getImageForSticker(currentStickers[currentStickerIndex!])
        }
    }
    
    @IBAction func eraserWidthSliderValueChanged(_ sender: UISlider) {
        updateEraserSizeIndicator()
    }
    
    func addTextButtonPressed() {
        if onTopState {
            animateToBottom()
        }
        currentTextEditImage = nil
        showTextEdit()
    }
    
    fileprivate func setupWithEraserMode(_ eraserMode: Bool) {
        guard let erasingImageView = currentSelectedImageView else { return }
        eraserButton.isSelected = eraserMode
        eraserWidthSlider.isSelected = eraserMode
        if eraserMode {
            updateEraserSizeIndicator()
        } else {
            eraserTouchesEnded = true
            eraserStepBackButton.isEnabled = false
        }
        eraserSizeIndicator.isHidden = !eraserMode
        if eraserMode {
            eraserWidthSlider.setThumbImage(UIImage(named: "pointer_medium"), for: .normal)
            eraserWidthSlider.setMinimumTrackImage(UIImage(named: "eraser_slider_line_selected"), for: .normal)
            eraserWidthSlider.setMaximumTrackImage(UIImage(named: "eraser_slider_line_selected"), for: .normal)
        } else {
            eraserWidthSlider.setThumbImage(UIImage(), for: .normal)
            eraserWidthSlider.setMinimumTrackImage(UIImage(named: "eraser_slider_line_normal"), for: .normal)
            eraserWidthSlider.setMaximumTrackImage(UIImage(named: "eraser_slider_line_normal"), for: .normal)
        }
        eraserWidthSlider.isUserInteractionEnabled = eraserMode
        erasingImageView.isUserInteractionEnabled = !eraserMode
    }
    
    fileprivate func updateEraserSizeIndicator() {
        let sliderWidth = eraserWidthSlider.frame.width
        let sliderLeft = eraserWidthSlider.frame.minX
        let sliderThumbWidth = UIImage(named: "pointer_medium")!.size.width
        let relativeValue = (eraserWidthSlider.value - eraserWidthSlider.minimumValue) / (eraserWidthSlider.maximumValue - eraserWidthSlider.minimumValue)
        let thumbCenter = sliderLeft + (sliderWidth - sliderThumbWidth) * CGFloat(relativeValue) + sliderThumbWidth * 0.5
        
        let eraserIndicatorSize = CGSize(width: CGFloat(eraserWidthSlider.value), height: CGFloat(eraserWidthSlider.value))
        let eraserIndicatorBottom: CGFloat = 0
        let eraserIndicatorLeft = thumbCenter - (eraserIndicatorSize.width / CGFloat(2.0))
        
        eraserSizeIndicator.frame = CGRect(x: eraserIndicatorLeft, y: eraserIndicatorBottom - eraserIndicatorSize.height, width: eraserIndicatorSize.width, height: eraserIndicatorSize.height)
        eraserSizeIndicator.layer.cornerRadius = eraserIndicatorSize.width * 0.5
    }
    
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        eraserMode = !eraserMode
        setupWithEraserMode(eraserMode)
    }
    
    @IBAction func eraserStepBackButtonPressed(_ sender: UIButton) {
        if !eraserMode {
            return
        }
        eraserStepBackButton.isEnabled = false
        guard let erasingImageStepBackImage = erasingImageStepBackImage,
              let erasingImageView = currentSelectedImageView else {
            return
        }
        currentStickers[currentStickerIndex!].brightnessFilter!.setValue(erasingImageStepBackImage, forKey: kCIInputImageKey)
        erasingImageView.image = getImageForSticker(currentStickers[currentStickerIndex!])
        erasingImageView.alpha = opacity
        
        self.erasingImageStepBackImage = nil
        eraserTouchesEnded = true
        
    }
    
    func centerOffset(_ point: CGPoint) -> CGPoint {
        guard let erasingImageView = currentSelectedImageView else { return CGPoint.zero }
        return CGPoint(x: point.x - erasingImageView.frame.size.width * 0.5, y: point.y - erasingImageView.frame.size.height * 0.5)
    }
    
    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
        guard let erasingImageView = currentSelectedImageView else { return CGPoint.zero }
        return CGPoint(x: point.x + erasingImageView.frame.size.width * 0.5, y: point.y + erasingImageView.frame.size.height * 0.5)
    }

    
    func convertPoint(_ point: CGPoint) -> CGPoint {
        guard let erasingImageView = currentSelectedImageView else { return CGPoint.zero }
        let multiplier = erasingImageView.image!.size.width / erasingImageView.bounds.size.width
        let convertedPoint = CGPoint(x:multiplier * point.x, y:multiplier * point.y)
        return convertedPoint
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        guard let erasingImageView = currentSelectedImageView else { return }
        var brushWidth = CGFloat(eraserWidthSlider.value)
        let transform = erasingImageView.transform
        let transformScale = sqrt(transform.a * transform.a + transform.c * transform.c)
        let brushScale = (erasingImageView.image!.size.width / erasingImageView.bounds.width) / transformScale
        brushWidth *= brushScale
        // 1
        let oldImage = UIImage(ciImage:(currentStickers[currentStickerIndex!].brightnessFilter!.value(forKey: kCIInputImageKey) as? CIImage)!)
        
        
        UIGraphicsBeginImageContext(oldImage.size)
        let context = UIGraphicsGetCurrentContext()
        
        oldImage.draw(in: CGRect(x: 0, y: 0, width: erasingImageView.image!.size.width, height: erasingImageView.image!.size.height))
        
        // 2
        context?.move(to: convertPoint(fromPoint))
        context?.addLine(to: convertPoint(toPoint))
        
        // 3
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(.clear)
        
        // 4
        context?.strokePath()
        
        // 5
        let newCIImage = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!)
        currentStickers[currentStickerIndex!].brightnessFilter!.setValue(newCIImage, forKey: kCIInputImageKey)
        
        erasingImageView.image = getImageForSticker(currentStickers[currentStickerIndex!])
        erasingImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !eraserMode {
            return
        }
        guard let erasingImageView = currentSelectedImageView else { return }
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: erasingImageView)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !eraserMode {
            return
        }
        if eraserTouchesEnded {
            erasingImageStepBackImage = currentStickers[currentStickerIndex!].brightnessFilter!.value(forKey: kCIInputImageKey) as? CIImage
            eraserStepBackButton.isEnabled = erasingImageStepBackImage != nil
            eraserTouchesEnded = false
        }
        guard let erasingImageView = currentSelectedImageView else { return }
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: erasingImageView)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !eraserMode {
            return
        }
        eraserTouchesEnded = true
        guard currentSelectedImageView != nil else { return }
        if !swiped {
            // draw a single point
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        eraserStepBackButton.isEnabled = erasingImageStepBackImage != nil
    }
    
}

//MARK: - CollectionViews DataSource

extension EditorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstLevelCollectionView {
            return firstLevelFetchedResultsController.fetchedObjects!.count
        }
        if collectionView == secondLevelCollectionView {
            return secondLevelFetchedResultsController.fetchedObjects!.count + (firstLevelSelectedIndex == Constants.lettersSectionId ? 1 : 0)
        }
        if collectionView == thirdLevelCollectionView {
            return thirdLevelFetchedResultsController.fetchedObjects!.count
        }

        if collectionView == editToolsCollectionView {
            let filtersCount = Filter.filters.count
            return filtersCount
        }
        if collectionView == cropToolsCollectionView {
            let cropModesCount = CropMode.modes.count
            return cropModesCount
        }
        return 0
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == firstLevelCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstLevelCollectionViewCell", for: indexPath) as? FirstLevelCollectionViewCell {
                if let object = firstLevelFetchedResultsController.fetchedObjects?[indexPath.row] as? Section {
                    cell.titleLabel.attributedText = NSAttributedString(string: object.title.uppercased(), attributes: Constants.firstLevelCollectionViewCellTitleAttributes)
                    setupFirstLevelCell(cell, selected: indexPath.row == firstLevelSelectedIndex)
                }
                return cell
            }
        }
        if collectionView == secondLevelCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLevelCollectionViewCell", for: indexPath) as? SecondLevelCollectionViewCell {
                var indexInFetchedObjects = indexPath.row
                let titleFont = UIFont(name: "Circe-Regular", size: 9)!
                let attributes = [
                    NSFontAttributeName : titleFont
                ]
                cell.clipsToBounds = false;
                if firstLevelSelectedIndex == Constants.lettersSectionId {
                    if indexPath.row == 0 {
                        cell.titleLabel.attributedText = NSAttributedString(string: localized("EditorVC_ownTextButtonTitle"), attributes: attributes)
                        cell.clipsToBounds = false;
                        cell.imageView.image = UIImage(named: "add_text_button")
                        setupSecondLevelCell(cell, selected: false)
                        return cell
                    } else {
                        indexInFetchedObjects -= 1
                    }
                }
                
                if let object = secondLevelFetchedResultsController.fetchedObjects?[indexInFetchedObjects] as? Section {
                    cell.titleLabel.attributedText = NSAttributedString(string: object.title.uppercased(), attributes: attributes)
                    if let imageLink = object.imageURL {
                        cell.imageView.imageLink = imageLink
						
						if cell.imageView.imageLink?.lowercased().range(of: ".gif") != nil {
							var arrStringWithoutExtention = cell.imageView.imageLink!.components(separatedBy: ".gif")
							cell.imageView.loadGif(name: arrStringWithoutExtention[0])
						}
                    }
                    setupSecondLevelCell(cell, selected: indexPath.row == secondLevelSelectedIndex)
                }
                return cell
            }
        }
        if collectionView == thirdLevelCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThirdLevelCollectionViewCell", for: indexPath) as? ThirdLevelCollectionViewCell {
                if let object = thirdLevelFetchedResultsController.fetchedObjects?[indexPath.row] as? Sticker {
                    if let imageLink = object.image_url {
                        cell.imageView.imageLink = imageLink
						
						if cell.imageView.imageLink?.lowercased().range(of: ".gif") != nil {
							var arrStringWithoutExtention = cell.imageView.imageLink!.components(separatedBy: ".gif")
							cell.imageView.loadGif(name: arrStringWithoutExtention[0])
						}
                    }
                    cell.productId = nil
                    if indexPath.row > 2  && !StoreHelper.fullVersionPurchased {
                        cell.imageView.alpha = 0.3
                        cell.available = false
                        if let product_id = object.product_id {
                            cell.available = StoreHelper.sharedInstance.getPurchasedProductsIds().contains(product_id)
                            cell.imageView.alpha = cell.available ? 1 : 0.3
                            cell.productId = product_id
                        } else {
                            cell.imageView.alpha = 1
                            cell.available = true
                        }
                    } else {
                        cell.imageView.alpha = 1
                        cell.available = true
                    }
                    
                    setupFourthLevelCell(cell, selected: true)
                }
                return cell
            }
        }
        if collectionView == editToolsCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolsCollectionViewCell", for: indexPath) as? EditToolsCollectionViewCell {
                cell.editToolIcon.image = UIImage(named: Filter.filters[indexPath.row].getImageNameNormal())
                return cell
            }
        }
        if collectionView == cropToolsCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CropToolsCollectionViewCell", for: indexPath) as? CropToolsCollectionViewCell {
                cell.title.text = CropMode.modes[indexPath.row].getTitle()
                cell.cropModeButton.setImage(UIImage(named:CropMode.modes[indexPath.row].getImageNameNormal()), for: UIControlState())
                cell.cropModeButton.setImage(UIImage(named:CropMode.modes[indexPath.row].getImageNameSelected()), for: .selected)
                cell.isSelected = currentCropMode == CropMode.modes[indexPath.row]
                setupCropModeCell(cell, selected: cell.isSelected)
                cell.cropModeButton.isUserInteractionEnabled = false
                return cell
            }
        }
        return UICollectionViewCell()
    }
}

//MARK: - Setup of cells

extension EditorViewController {
    
    fileprivate func setupFirstLevelCell(_ cell:FirstLevelCollectionViewCell, selected:Bool) {
        cell.titleLabel.textColor = selected ? UIColor.white : UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    }
    
    fileprivate func setupSecondLevelCell(_ cell:SecondLevelCollectionViewCell, selected:Bool) {
        cell.titleLabel.textColor = selected ? UIColor.white : UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        cell.backgroundColor =  UIColor(red: 0.176, green: 0.176, blue: 0.176, alpha: 1)
    }
    
    fileprivate func setupFourthLevelCell(_ cell:ThirdLevelCollectionViewCell, selected:Bool) {
    }
    
    fileprivate func setupCropModeCell(_ cell:CropToolsCollectionViewCell, selected:Bool) {
        cell.cropModeButton.isSelected = selected
        cell.title.textColor = selected ? UIColor.white : UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.0)
    }
    
}

//MARK: - Animations

extension EditorViewController {
    
    func animateToTop() {
        
        if onTopState {
            return
        }
        topMenuButton.isEnabled = true;
        arrowDownCloseButton.isHidden = false
        topControlsView.backgroundColor = UIColor(red: 0.35, green: 0.39, blue: 0.45, alpha: 1.0)
        
        containerViewForSecondLevelCollectionView.superview?.removeConstraint(containerViewForSecondLevelCollectionViewBottomConstraint)
        containerViewForSecondLevelCollectionView.addConstraint(NSLayoutConstraint(item: containerViewForSecondLevelCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: secondLevelCollectionView.frame.size.height))
        
        thirdLevelCollectionViewBottomConstraint = NSLayoutConstraint(item: thirdLevelCollectionView, attribute: .bottom, relatedBy: .equal, toItem: thirdLevelCollectionView.superview, attribute: .bottom, multiplier: 1.0, constant: 0)
        thirdLevelCollectionView.superview!.addConstraint(thirdLevelCollectionViewBottomConstraint)

        firstLevelCollectionView.superview!.removeConstraint(firstLevelCollectionViewTopConstraint)
        firstLevelCollectionViewTopConstraint = NSLayoutConstraint(item: firstLevelCollectionView, attribute: .top, relatedBy: .equal, toItem: topControlsView, attribute: .bottom, multiplier: 1.0, constant: 0)
        firstLevelCollectionView.superview!.addConstraint(firstLevelCollectionViewTopConstraint)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) 
        onTopState = true
       
    }
    
    func animateToBottom() {
        
        if !onTopState {
            return
        }
        topMenuButton.isEnabled = false;
        arrowDownCloseButton.isHidden = true
        topControlsView.backgroundColor = UIColor.clear
        
        containerViewForSecondLevelCollectionViewBottomConstraint = NSLayoutConstraint(item: containerViewForSecondLevelCollectionView, attribute: .bottom, relatedBy: .equal, toItem: containerViewForSecondLevelCollectionView.superview, attribute: .bottom, multiplier: 1.0, constant: 0)
        containerViewForSecondLevelCollectionView.superview?.addConstraint(containerViewForSecondLevelCollectionViewBottomConstraint)
        
        thirdLevelCollectionView.superview?.removeConstraint(thirdLevelCollectionViewBottomConstraint)
        
        firstLevelCollectionView.superview!.removeConstraint(firstLevelCollectionViewTopConstraint)
        firstLevelCollectionViewTopConstraint = NSLayoutConstraint(item: firstLevelCollectionView, attribute: .top, relatedBy: .equal, toItem: mainContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        firstLevelCollectionView.superview!.addConstraint(firstLevelCollectionViewTopConstraint)

        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) 
        onTopState = false
    }
    
    func showFiltersViewWithFilter(_ filter: Filter) {
        containerForFiltersView.bringToFront()
        filterTitleLabel.text = filter.getTitle().uppercased()
        var value: AnyObject? = nil
        switch filter {
        case .brightness:
            value = brightnessFilter.value(forKey: "inputEV") as AnyObject?
            AnalyticsEngine.trackEvent(AnalyticsEditActionEvent(action: .brighness))
        case .contrast:
            value = colorFilter.value(forKey: "inputContrast") as AnyObject?
            AnalyticsEngine.trackEvent(AnalyticsEditActionEvent(action: .contrast))
        case .saturation:
            value = colorFilter.value(forKey: "inputSaturation") as AnyObject?
            AnalyticsEngine.trackEvent(AnalyticsEditActionEvent(action: .saturation))
        default:
            break
        }
        let sliderRange = filter.getSliderValues()
        filtersSlider.minimumValue = sliderRange.minValue
        filtersSlider.maximumValue = sliderRange.maxValue
        if let floatValue = value as? Float {
            filtersSlider.value = floatValue
            currentSliderValue = floatValue
            lastSavedFilterValue = floatValue
            filtersSlider.layoutIfNeeded()
        }
    }
    
    fileprivate func showRotationTools() {
        AnalyticsEngine.trackEvent(AnalyticsEditActionEvent(action: .rotate))
        containerForRotateTools.bringToFront()
        containerForRotationViews.isHidden = false
        containerForRotationViews.bringToFront()
        deselectCurrentSelectedImage()
        
        rotatingImageView.transform = CGAffineTransform.identity
        rotationSlider.setValue(0, animated: false)
        currentBigImageRotationAngle = 0
        
        if let currentBigImage = currentBigImage {
            rotatingImageView.image = getFilteredImageFromImage(currentBigImage)
            rotatingImageView.fitInSuperview()
            blackoutWithHoleForRotation.holeFrame = rotatingImageView.frame
            blackoutWithHoleForRotation.setNeedsDisplay()
        }
    }
    
    fileprivate func showCropTools() {
        AnalyticsEngine.trackEvent(AnalyticsEditActionEvent(action: .crop))
        containerForCropTools.bringToFront()
        containerForCropViews.isHidden = false
        containerForCropViews.bringToFront()
        
        deselectCurrentSelectedImage()
        
        if let currentBigImage = currentBigImage {
            croppingImageView.image = getFilteredImageFromImage(currentBigImage)
            croppingImageView.fitInSuperview()
            blackoutWithHoleForCrop.frame = croppingImageView.frame
            currentCropMode = .free
            cropToolsCollectionView.reloadData()
            setupCropBlackoutWithCropMode(currentCropMode)
        }
        
    }
    
    fileprivate func showEditObject() {
        eraserMode = false
        setupWithEraserMode(false)
        containerForEditObject.bringToFront()
        containerForEditObject.isHidden = false
    }
    
    fileprivate func showTextEdit() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let textEditVC = storyboard.instantiateViewController(withIdentifier: "TextEditViewController") as! TextEditViewController
        textEditVC.textParams = currentTextEditImage?.textParams
        textEditVC.delegate = self
        let presentationController = MZFormSheetPresentationViewController(contentViewController: textEditVC)
        presentationController.presentationController?.contentViewSize = self.view.frame.size
        presentationController.presentationController?.shouldCenterVertically = true
        self.present(presentationController, animated: true, completion: nil)
    }
    
    fileprivate func rotateImage90Degrees() {
        let rotatedImage = rotatingImageView.image?.imageRotatedByDegrees(90)
        rotatingImageView.image = rotatedImage
        rotatingImageView.transform = CGAffineTransform.identity
        rotatingImageView.fitInSuperview()
        blackoutWithHoleForRotation.holeFrame = rotatingImageView.frame
        blackoutWithHoleForRotation.setNeedsDisplay()
    }
    
    fileprivate func setupCropBlackoutWithCropMode(_ cropMode: CropMode) {
        switch currentCropMode {
        case .free:
            blackoutWithHoleForCrop.holeFrame = CGRect(x: blackoutWithHoleForCrop.frame.width * 0.25, y: blackoutWithHoleForCrop.frame.height * 0.25, width: blackoutWithHoleForCrop.frame.width * 0.5, height: blackoutWithHoleForCrop.frame.height * 0.5)
            blackoutWithHoleForCrop.keepRatio = false
        case .oneToOne:
            blackoutWithHoleForCrop.holeFrame = blackoutWithHoleForCrop.frame.getRectInsideWithRatio(1)
            blackoutWithHoleForCrop.keepRatio = true
        case .fourToThree:
            blackoutWithHoleForCrop.holeFrame = blackoutWithHoleForCrop.frame.getRectInsideWithRatio(4 / 3)
            blackoutWithHoleForCrop.keepRatio = true
        case .threeToFour:
            blackoutWithHoleForCrop.holeFrame = blackoutWithHoleForCrop.frame.getRectInsideWithRatio(3 / 4)
            blackoutWithHoleForCrop.keepRatio = true
        case .twoToThree:
            blackoutWithHoleForCrop.holeFrame = blackoutWithHoleForCrop.frame.getRectInsideWithRatio(2 / 3)
            blackoutWithHoleForCrop.keepRatio = true
        }
        blackoutWithHoleForCrop.setNeedsDisplay()
    }
    
}

//MARK: - Highlight/Select cell handlers

extension EditorViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView == firstLevelCollectionView {
            if indexPath.row == firstLevelSelectedIndex {
                return
            }
            if let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? FirstLevelCollectionViewCell {
                setupFirstLevelCell(cell, selected: true)
            }
        } else if collectionView == secondLevelCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? SecondLevelCollectionViewCell {
                setupSecondLevelCell(cell, selected: true)
            }
        } else if collectionView == thirdLevelCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? ThirdLevelCollectionViewCell {
                if cell.imageView.alpha == 0.3 {
                    cell.imageView.alpha = 0.6
                }
            }
        } else if collectionView == cropToolsCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? CropToolsCollectionViewCell {
                setupCropModeCell(cell, selected: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView == firstLevelCollectionView {
            if indexPath.row == firstLevelSelectedIndex {
                return
            }
            if let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? FirstLevelCollectionViewCell {
                if indexPath.row == secondLevelSelectedIndex {
                    return
                }
                setupFirstLevelCell(cell, selected: false)
            }
        } else if collectionView == secondLevelCollectionView {
            if indexPath.row == secondLevelSelectedIndex {
                return
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? SecondLevelCollectionViewCell{
                setupSecondLevelCell(cell, selected: false)
            }
        } else if collectionView == thirdLevelCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? ThirdLevelCollectionViewCell {
                if cell.imageView.alpha == 0.6 {
                    cell.imageView.alpha = 0.3
                }
            }
        } else if collectionView == cropToolsCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? CropToolsCollectionViewCell {
                setupCropModeCell(cell, selected: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if collectionView == editToolsCollectionView {
            currentFilter = Filter.filters[indexPath.row]
            switch currentFilter! {
            case .brightness,.contrast,.saturation:
                showFiltersViewWithFilter(currentFilter!)
            case .rotate:
                showRotationTools()
            case .crop:
                showCropTools()
            }
            return
        }
        
        if collectionView == cropToolsCollectionView {
            let currentCropMode = CropMode.modes[indexPath.row]
            if currentCropMode != self.currentCropMode {
                if let selectedCell = collectionView.cellForItem(at: indexPath) as? CropToolsCollectionViewCell {
                    setupCropModeCell(selectedCell, selected: true)
                }
                if let deselectedCell = collectionView.cellForItem(at: IndexPath(row: CropMode.modes.index(of: self.currentCropMode)!, section: indexPath.section)) as? CropToolsCollectionViewCell {
                    setupCropModeCell(deselectedCell, selected: false)
                }
                if let cell = collectionView.cellForItem(at: IndexPath(row: firstLevelSelectedIndex, section: indexPath.section)) as? FirstLevelCollectionViewCell {
                    setupFirstLevelCell(cell, selected: false)
                }
                self.currentCropMode = currentCropMode
                setupCropBlackoutWithCropMode(self.currentCropMode)
            }
            return
        }
        
        editButton.isSelected = false
        containerViewForSecondLevelCollectionView.superview?.bringSubview(toFront: containerViewForSecondLevelCollectionView)
        
        if collectionView == firstLevelCollectionView {
            if indexPath.row == firstLevelSelectedIndex {
                return
            }
            if (self.onTopState) {
                _thirdLevelFetchedResultsController = nil
                thirdLevelCollectionView.reloadData()
                thirdLevelCollectionView.setContentOffset(CGPoint.zero, animated: false)
            }
            
            if let cell = collectionView.cellForItem(at: IndexPath(row: firstLevelSelectedIndex, section: indexPath.section)) as? FirstLevelCollectionViewCell {
                setupFirstLevelCell(cell, selected: false)
            }
            firstLevelSelectedIndex = indexPath.row
            if let cell = collectionView.cellForItem(at: IndexPath(row: firstLevelSelectedIndex, section: indexPath.section)) as? FirstLevelCollectionViewCell {
                setupFirstLevelCell(cell, selected: true)
            }
            secondLevelSelectedIndex = firstLevelSelectedIndex == Constants.lettersSectionId ? 1 : 0
            _secondLevelFetchedResultsController = nil
            secondLevelCollectionView.reloadData()
        }
        if collectionView == secondLevelCollectionView {
            
            if !onTopState {
                animateToTop()
            }
            
            if (firstLevelSelectedIndex == Constants.lettersSectionId) {
                if indexPath.row == 0 {
                    addTextButtonPressed()
                    return
                }
            }
            
            _thirdLevelFetchedResultsController = nil
            thirdLevelCollectionView.reloadData()
            thirdLevelCollectionView.setContentOffset(CGPoint.zero, animated: false)

            if let cell = collectionView.cellForItem(at: IndexPath(row: secondLevelSelectedIndex, section: indexPath.section)) as? SecondLevelCollectionViewCell {
                setupSecondLevelCell(cell, selected: false)
            }
            secondLevelSelectedIndex = indexPath.row
            if let cell = collectionView.cellForItem(at: IndexPath(row: secondLevelSelectedIndex, section: indexPath.section)) as? SecondLevelCollectionViewCell {
                setupSecondLevelCell(cell, selected: true)
            }
            
        }
        if collectionView == thirdLevelCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? ThirdLevelCollectionViewCell {
                if cell.available {
                    if let image = cell.imageView.image {
						
						if (cell.imageView.animationImages != nil) {
							if maxAnimations <= 0 {
								limitAnimation()
								return
							} else {
								addImageOnEditorView(image)
								maxAnimations -= 1
							}
						} else {
							if (cell.imageView.image?.images != nil){
								if maxAnimations <= 0 {
									limitAnimation()
									return
								} else {
									addImageOnEditorView(image)
									maxAnimations -= 1
								}
							} else {
								addImageOnEditorView(image)
							}
						}
						
                        if onTopState {
                            animateToBottom()
                        }
                    }
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let bannerVC = storyboard.instantiateViewController(withIdentifier: "BannerViewController") as! BannerViewController

                    bannerVC.setObject = secondLevelFetchedResultsController.fetchedObjects![secondLevelSelectedIndex - (firstLevelSelectedIndex == Constants.lettersSectionId ? 1 : 0)] as? Section

                    let presentationController = MZFormSheetPresentationViewController(contentViewController: bannerVC)
                    presentationController.presentationController?.contentViewSize = CGSize(width: self.view.frame.width - 24, height: 296)
                    presentationController.allowDismissByPanningPresentedView = true
                    presentationController.contentViewCornerRadius = 2
                    presentationController.presentationController?.shouldDismissOnBackgroundViewTap = true
                    presentationController.presentationController?.shouldCenterVertically = true
                    presentationController.willDismissContentViewControllerHandler = { vc in
                        self.updateViewWithCurrentPurchases()
                    }
                    self.present(presentationController, animated: true, completion: nil)
                    SwiftyStoreKit.retrieveProductInfo((bannerVC.setObject?.product_id)!, completion: { (result) -> () in
                        if case .success(let product) = result {
                            bannerVC.product = product
                        }
                    })
                }
            }
        }
    }
}

//MARK: - Gesture handlers

extension EditorViewController {
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let currentSelectedImageView = currentSelectedImageView else {
            return
        }
        if currentSelectedImageView != recognizer.view {
            return
        }
        let translation = recognizer.translation(in: self.imageView)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                y:view.center.y + translation.y)
            currentSelectedImageView.updateActionButtonsFrames()
        }
        recognizer.setTranslation(CGPoint.zero, in: self.imageView)
    }
    
    func handleSizeImagePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.imageView)
        guard let currentSelectedImageView = currentSelectedImageView else {
            return
        }
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                y:view.center.y + translation.y)
            
            let yDiff = -(view.center.y - currentSelectedImageView.center.y)
            let xDiff = view.center.x - currentSelectedImageView.center.x
            let angle = atan2(yDiff, xDiff)
            let angleWithDelta = angle + CGFloat(atan2f(Float(currentSelectedImageView.image!.size.height), Float(currentSelectedImageView.image!.size.width)))
            let point1 = view.center
            let point2 = currentSelectedImageView.center
            let xDist = (point2.x - point1.x)
            let yDist = (point2.y - point1.y)
            let distance = sqrt((xDist * xDist) + (yDist * yDist))
            let scale = distance / CGFloat(initialRadiusForSize(currentSelectedImageView.image!.size))

            var transform = CGAffineTransform.identity
            transform = CGAffineTransform(scaleX: scale, y: scale)
            transform = transform.rotated(by: -angleWithDelta)
            currentSelectedImageView.transform = transform
            currentSelectedImageView.layer.borderWidth = 1.0 / scale
            currentSelectedImageView.updateActionButtonsFrames()
        }
        recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        
    }
    
    func handleTapOnContainerImage(_ recognizer : UITapGestureRecognizer) {
        if eraserMode {
            if let currentErasingImageView = currentSelectedImageView {
                let view = recognizer.view
                let loc = recognizer.location(in: view)
                
                if currentErasingImageView.frame.contains(loc) {
                    return
                }
            }
        }
        hideEditObject()
        eraserMode = false
        setupWithEraserMode(eraserMode)
        deselectCurrentSelectedImage()
    }
    
    func handleDoubleTap(_ recognizer : UITapGestureRecognizer) {
        
        if let view = recognizer.view as? TextImageView {
            if view != currentSelectedImageView {
                selectImageView(view)
            }
            currentTextEditImage = view
            showTextEdit()
        }
    }
    
    func handleSingleTap(_ recognizer : UITapGestureRecognizer) {
        if let currentSelectedImageView = currentSelectedImageView, currentSelectedImageView == recognizer.view {
            return;
        }
        if let previousSelectedImageView = currentSelectedImageView, previousSelectedImageView != recognizer.view {
            eraserMode = false
            setupWithEraserMode(false)
            deselectCurrentSelectedImage()
        }
        selectImageView(recognizer.view as? SelectableImageView)
    }
    
    func selectImageView(_ imageView: SelectableImageView?) {
        currentSelectedImageView = imageView
		if ((currentSelectedImageView?.image) != nil) {
			if ((currentSelectedImageView?.image!.images != nil)) {
				eraserButton.isEnabled = false
				objectOpacitySlider.isEnabled = false
				objectBrightnessSlider.isEnabled = false
			} else {
				eraserButton.isEnabled = true
				objectOpacitySlider.isEnabled = true
				objectBrightnessSlider.isEnabled = true
			}
		} else {
			if (currentSelectedImageView?.animationImages != nil) {
				eraserButton.isEnabled = false
				objectOpacitySlider.isEnabled = false
				objectBrightnessSlider.isEnabled = false
			} else {
				eraserButton.isEnabled = true
				objectOpacitySlider.isEnabled = true
				objectBrightnessSlider.isEnabled = true
			}
		}
        guard let currentSelectedImageView = currentSelectedImageView else {
            return
        }
        currentStickerIndex = currentStickers.index(where: { (sticker) -> Bool in
            sticker.imageView == imageView
        })
        
        if !(currentSelectedImageView is TextImageView) {
			if (currentSelectedImageView.image!.images != nil) || (currentSelectedImageView.animationImages != nil) {
				hideEditObject()
			} else {
				showEditObject()
				let initialAlpha = currentStickers[currentStickerIndex!].alpha
				let initialBrightness = currentStickers[currentStickerIndex!].brightnessFilter.value(forKey: "inputEV") as! Float
				objectOpacitySlider.value = 1 - Float(initialAlpha)
				objectBrightnessSlider.value = initialBrightness
				currentObjectInitialAlpha = initialAlpha
				currentObjectInitialBrightness = initialBrightness
				let currentObjectCIImage = currentStickers[currentStickerIndex!].brightnessFilter.value(forKey: kCIInputImageKey) as! CIImage
				let ref = currentStickers[currentStickerIndex!].context.createCGImage((currentObjectCIImage), from: currentObjectCIImage.extent)
				currentObjectInitialImage = UIImage(cgImage: ref!)
			}
        } else {
            hideEditObject()
        }
 
        currentSelectedImageView.layer.borderColor = UIColor.lightGray.cgColor
        let scale = sqrt(currentSelectedImageView.transform.a * currentSelectedImageView.transform.a + currentSelectedImageView.transform.c * currentSelectedImageView.transform.c)
        currentSelectedImageView.layer.borderWidth = 1.0 / scale
        currentSelectedImageView.superview?.bringSubview(toFront: currentSelectedImageView)
        if let watermark = watermark {
            watermark.superview?.bringSubview(toFront: watermark)
        }
        
        currentSelectedImageView.selectWithSender(self)
    }
    
    func getCoordinatesOfSizeButtonForImageView(_ imageView: UIImageView) -> CGRect {
        return getCoordinatesOfActionButton(imageView, corner: .bottomRight)
    }
    
    func getCoordinatesOfCloseButtonForImageView(_ imageView: UIImageView) -> CGRect {
        return getCoordinatesOfActionButton(imageView, corner: .topLeft)
    }
    
    func getCoordinatesOfMirrorButtonForImageView(_ imageView: UIImageView) -> CGRect {
        return getCoordinatesOfActionButton(imageView, corner: .bottomLeft)
    }
    
    fileprivate func getCoordinatesOfActionButton(_ imageView: UIImageView, corner: Corner) -> CGRect {
        let center = imageView.cornerCenter(corner, initialRadius: initialRadiusForSize(imageView.image!.size))
        return CGRectMake(center: center, size: CGFloat(Constants.objectActionButtonsSize))
    }
}

//MARK: - Cell sizes and insets

extension EditorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        if collectionView == firstLevelCollectionView  {
            if let object = firstLevelFetchedResultsController.fetchedObjects?[indexPath.row] as? Section {
                let titleWidth = ceil((object.title.uppercased() as NSString).size(attributes: Constants.firstLevelCollectionViewCellTitleAttributes).width)
                return CGSize(width: 32 + titleWidth, height: 30)
            }
            return CGSize(width: screenSize.width / 3, height: 30)
        }
        if collectionView == secondLevelCollectionView {
            return CGSize(width: 74, height: 74)
        }
        if collectionView == thirdLevelCollectionView {
            if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
                return CGSize(width: 85, height: 85)
            } else if DeviceType.IS_IPHONE_6 {
                return CGSize(width: 105, height: 105)
            } else {
                return CGSize(width: 118, height: 118)
            }
        }
        if collectionView == editToolsCollectionView {
            return CGSize(width: 45, height: 45)
        }
        if collectionView == cropToolsCollectionView {
            return CGSize(width: 55, height: 75)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == secondLevelCollectionView {
            return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
        if collectionView == editToolsCollectionView || collectionView == cropToolsCollectionView {
            if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
                   let dataSource = collectionView.dataSource { 
                let cellWidth = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(row: 0, section: 0)).width
                let cellInterSpacing = collectionViewFlowLayout.minimumInteritemSpacing
                let cellsCount = CGFloat(dataSource.collectionView(collectionView, numberOfItemsInSection: 0))
                let contentWidth = cellsCount * cellWidth + (cellsCount - 1) * cellInterSpacing
                let inset = (collectionView.bounds.size.width - contentWidth) * 0.5
                return UIEdgeInsetsMake(0, max(inset, 0.0), 0, 0)
            }
        }
        if collectionView == thirdLevelCollectionView {
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
        return UIEdgeInsets.zero
    }
}

//MARK: - RotationSlider delegate

extension EditorViewController: RotationSliderDelegate {
    
    func rotationSliderValueChanged(_ sender: UISlider) {
        rotatingImageView.transform = rotatingImageView.getRotationTransformСircumscribedWithAngle(sender.value)
    }
}

//MARK: - TextEditViewController delegate

extension EditorViewController: TextEditViewControllerDelegate {
    
    func textEditViewControllerDoneWithImage(_ image: UIImage, textParams: TextParams) {
        addImageOnEditorView(image, text: true, textParams: textParams, center: currentTextEditImage?.center)
        currentTextEditImage?.removeFromSuperview()
    }
}

//MARK: - Navigation

extension EditorViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShareImageVCShowSegue" {
			if sender is UIImage {
				if let shareImageVCShowSegue = segue.destination as? ShareViewController, let imageToShare = sender as? UIImage {
					shareImageVCShowSegue.imageForSharing = imageToShare
				}
				self.removeForegroundView()
			} else {
				if let shareVideoURLVCShowSegue = segue.destination as? ShareViewController, let videoURLToShare = sender as? URL {
					shareVideoURLVCShowSegue.videoURLForSharing = videoURLToShare
				}
				self.removeForegroundView()
			}
        }
    }
}
