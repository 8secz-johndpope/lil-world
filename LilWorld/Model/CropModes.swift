//
//  CropModes.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 15/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation

enum CropMode {
    case free, fourToThree, oneToOne, threeToFour, twoToThree
    
    static let modes = [free, fourToThree, oneToOne, threeToFour, twoToThree]
}

extension CropMode {
    
    func getImageNameNormal() -> String {
        switch self {
        case .free:
            return "crop_free_button_normal"
        case .fourToThree:
            return "crop_four_to_three_button_normal"
        case .oneToOne:
            return "crop_one_to_one_button_normal"
        case .threeToFour:
            return "crop_three_to_four_button_normal"
        case .twoToThree:
            return "crop_two_to_three_button_normal"
        }
    }
    
    func getImageNameSelected() -> String {
        switch self {
        case .free:
            return "crop_free_button_selected"
        case .fourToThree:
            return "crop_four_to_three_button_selected"
        case .oneToOne:
            return "crop_one_to_one_button_selected"
        case .threeToFour:
            return "crop_three_to_four_button_selected"
        case .twoToThree:
            return "crop_two_to_three_button_selected"
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .free:
            return "Free"
        case .fourToThree:
            return "4:3"
        case .oneToOne:
            return "1:1"
        case .threeToFour:
            return "3:4"
        case .twoToThree:
            return "2:3"
        }
    }
}
