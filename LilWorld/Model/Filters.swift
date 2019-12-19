//
//  Filters.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 08/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation

typealias SliderRange = (minValue: Float, maxValue:Float)

enum Filter {
    case brightness, contrast, saturation, crop, rotate
    
    static let filters = [crop, rotate, brightness, contrast, saturation]
}

extension Filter {
    
    func getTitle() -> String {
        switch self {
        case .brightness:
            return localized("Filters_brightness")
        case .contrast:
            return localized("Filters_contrast")
        case .saturation:
            return localized("Filters_saturation")
        case .crop:
            return "Crop"
        case .rotate:
            return "Rotate"
        }
    }
    
    func getImageNameNormal() -> String {
        switch self {
        case .brightness:
            return "brightness_button_normal"
        case .contrast:
            return "contrast_button_normal"
        case .saturation:
            return "saturation_button_normal"
        case .crop:
            return "crop_button_normal"
        case .rotate:
            return "rotate_button_normal"
        }
    }
    
    func getImageNameHighlighted() -> String {
        switch self {
        case .brightness:
            return "brightness_button_highlighted"
        case .contrast:
            return "contrast_button_highlighted"
        case .saturation:
            return "saturation_button_highlighted"
        case .crop:
            return "crop_button_highlighted"
        case .rotate:
            return "rotate_button_highlighted"
        }
    }
    
    func getSliderValues() -> SliderRange {
        switch self {
        case .brightness:
            return (-3, 3)
        case .contrast:
            return (0.7, 1.3)
        case .saturation:
            return (0, 2)
        default:
            return (0, 1)
        }
    }
    
    func getSliderStep() -> Float {
        switch self {
        case .brightness:
            return 0.02
        case .contrast:
            return 0.02
        case .saturation:
            return 0.05
        default:
            return 1
        }
    }
}
