//
//  UIImage+Additions.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 10/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    
    func imageScaledToWidth(_ width: Float) -> UIImage {
        let scaleFactor = width / Float(self.size.width)
        let height = Float(self.size.height) * scaleFactor
        
        return imageFromImage(self, andSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
    }
    
    func imageScaledWithCoefficient(_ coefficient: Float) -> UIImage {
        let width = self.size.width * CGFloat(coefficient)
        let height = self.size.height * CGFloat(coefficient)
        
        return imageFromImage(self, andSize: CGSize(width: width, height: height))
    }

    fileprivate func imageFromImage(_ image: UIImage, andSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size);
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    
    func normalizedImage() -> UIImage {
        if self.imageOrientation == .up {
            return self;
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage!
    }
    
    func imageRotatedByDegrees(_ angle: CGFloat) -> UIImage {
        return imageRotatedByRadians(CGFloat(Double.pi / 180) * angle)
    }
    
    func imageRotatedByRadians(_ angle: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        let transform = CGAffineTransform(rotationAngle: angle)
        rotatedViewBox.transform = transform
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, UIScreen.main.scale)
        let bitmap = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
        bitmap.rotate(by: angle)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height));
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func croppedWithTransform(_ transform: CGAffineTransform) -> UIImage {
        let scale = sqrt(transform.a * transform.a + transform.c * transform.c)
        return self.imageCroppedWithRotationByRadians(atan2(transform.b, transform.a), andScaled: scale)
    }
    
    fileprivate func imageCroppedWithRotationByRadians(_ angle: CGFloat, andScaled scale:CGFloat) -> UIImage {
        let rotatedImage = self.imageRotatedByRadians(angle).imageScaledWithCoefficient(Float(scale))
        UIGraphicsBeginImageContext(self.size);
        rotatedImage.draw(in: CGRect(x: 0.5 * (self.size.width - rotatedImage.size.width), y: 0.5 * (self.size.height - rotatedImage.size.height), width: rotatedImage.size.width, height: rotatedImage.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!
    }
    
    func croppedWithRelativeRect(_ relativeRect: CGRect) -> UIImage {
        let cropRect = CGRect(x: self.size.width * relativeRect.origin.x, y: self.size.height * relativeRect.origin.y, width: self.size.width * relativeRect.width, height: self.size.height * relativeRect.height)
        let imageRef = self.cgImage!.cropping(to: cropRect)!
        return UIImage(cgImage: imageRef)
    }
    
    class func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageWithAlpha(_ alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        
        let ctx = UIGraphicsGetCurrentContext()!
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -area.size.height)
        
        ctx.setBlendMode(.multiply)
        ctx.setAlpha(alpha)
        
        ctx.draw(self.cgImage!, in: area)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageFlippedHorizontally() -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
    
        context.translateBy(x: self.size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    
        let flipedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    
        return flipedImage
    }
    
    class func imageWithString(_ string: NSString, attributes: [String:AnyObject], size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        string.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
	
	// Returns a copy of this image that is cropped to the given bounds.
	// The bounds will be adjusted using CGRectIntegral.
	// This method ignores the image's imageOrientation setting.
	func croppedImage(_ bounds: CGRect) -> UIImage {
		let image = self.cgImage?.cropping(to: bounds)
		return UIImage(cgImage: image!)
	}
	
	func thumbnailImage(
		_ thumbnailSize: Int,
		transparentBorder borderSize:Int,
		cornerRadius:Int,
		interpolationQuality quality:CGInterpolationQuality
  ) -> UIImage {
		let resizedImage:UIImage = self.resizedImageWithContentMode(
			.scaleAspectFill,
			bounds: CGSize(width: CGFloat(thumbnailSize), height: CGFloat(thumbnailSize)),
			interpolationQuality: quality
		)
		let cropRect:CGRect = CGRect(
			x: round((resizedImage.size.width - CGFloat(thumbnailSize))/2),
			y: round((resizedImage.size.height - CGFloat(thumbnailSize))/2),
			width: CGFloat(thumbnailSize),
			height: CGFloat(thumbnailSize)
		)
		
		let croppedImage:UIImage = resizedImage.croppedImage(cropRect)
		return croppedImage
	}
	
	// Returns a rescaled copy of the image, taking into account its orientation
	// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
	func resizedImage(_ newSize:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
		var drawTransposed:Bool
		
		switch(self.imageOrientation) {
		case .left:
			fallthrough
		case .leftMirrored:
			fallthrough
		case .right:
			fallthrough
		case .rightMirrored:
			drawTransposed = true
			break
		default:
			drawTransposed = false
			break
		}
		
		return self.resizedImage(
			newSize,
			transform: self.transformForOrientation(newSize),
			drawTransposed: drawTransposed,
			interpolationQuality: quality
		)
	}
	
	func resizedImageWithContentMode(
		_ contentMode:UIViewContentMode,
		bounds:CGSize,
		interpolationQuality quality:CGInterpolationQuality
		) -> UIImage {
		let horizontalRatio:CGFloat = bounds.width / self.size.width
		let verticalRatio:CGFloat = bounds.height / self.size.height
		var ratio:CGFloat = 1
		
		switch(contentMode) {
		case .scaleAspectFill:
			ratio = max(horizontalRatio, verticalRatio)
			break
		case .scaleAspectFit:
			ratio = min(horizontalRatio, verticalRatio)
			break
		default:
			print("Unsupported content mode \(contentMode)")
		}
		
		let newSize:CGSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
		return self.resizedImage(newSize, interpolationQuality: quality)
	}
	
	func resizedImage(
		_ newSize:CGSize,
		transform:CGAffineTransform,
		drawTransposed transpose:Bool,
		interpolationQuality quality:CGInterpolationQuality
		) -> UIImage {
		let newRect:CGRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
		let transposedRect:CGRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
		let imageRef:CGImage = self.cgImage!
		
		// build a context that's the same dimensions as the new size
		let bitmap:CGContext = CGContext(
			data: nil,
			width: Int(newRect.size.width),
			height: Int(newRect.size.height),
			bitsPerComponent: imageRef.bitsPerComponent,
			bytesPerRow: 0,
			space: imageRef.colorSpace!,
			bitmapInfo: imageRef.bitmapInfo.rawValue
			)!
		
		// rotate and/or flip the image if required by its orientation
		bitmap.concatenate(transform)
		
		// set the quality level to use when rescaling
		bitmap.interpolationQuality = quality
		
		// draw into the context; this scales the image
		bitmap.draw(imageRef, in: transpose ? transposedRect : newRect)
		
		// get the resized image from the context and a UIImage
		let newImageRef = bitmap.makeImage()!
		let newImage:UIImage = UIImage(cgImage: newImageRef)
		
		return newImage
	}
	
	func transformForOrientation(_ newSize:CGSize) -> CGAffineTransform {
		var transform:CGAffineTransform = CGAffineTransform.identity
		switch (self.imageOrientation) {
		case .down:          // EXIF = 3
			fallthrough
		case .downMirrored:  // EXIF = 4
			transform = transform.translatedBy(x: newSize.width, y: newSize.height)
			transform = transform.rotated(by: CGFloat(Double.pi))
			break
		case .left:          // EXIF = 6
			fallthrough
		case .leftMirrored:  // EXIF = 5
			transform = transform.translatedBy(x: newSize.width, y: 0)
			transform = transform.rotated(by: CGFloat(Double.pi / 2))
			break
		case .right:         // EXIF = 8
			fallthrough
		case .rightMirrored: // EXIF = 7
			transform = transform.translatedBy(x: 0, y: newSize.height)
			transform = transform.rotated(by: -CGFloat(Double.pi / 2))
			break
		default:
			break
		}
		
		switch(self.imageOrientation) {
		case .upMirrored:    // EXIF = 2
			fallthrough
		case .downMirrored:  // EXIF = 4
			transform = transform.translatedBy(x: newSize.width, y: 0)
			transform = transform.scaledBy(x: -1, y: 1)
			break
		case .leftMirrored:  // EXIF = 5
			fallthrough
		case .rightMirrored: // EXIF = 7
			transform = transform.translatedBy(x: newSize.height, y: 0)
			transform = transform.scaledBy(x: -1, y: 1)
			break
		default:
			break
		}
		
		return transform
	}
	
	func imageScaledToFitToSize(_ size:CGSize) -> UIImage {
		let scaledRect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		self.draw(in: scaledRect)
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return scaledImage!
	}
	
	func resizeImage(targetSize: CGSize) -> UIImage {
		let size = self.size
		
		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height
		
		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		} else {
			newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
		}
		
		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
