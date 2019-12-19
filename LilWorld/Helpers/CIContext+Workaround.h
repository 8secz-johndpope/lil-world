//
//  CIContext+CIContext_Workaround.h
//  LilWorld
//
//  Created by Aleksandr Novikov on 27.09.16.
//  Copyright © 2016 Adno. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIContext (Workaround) //iOS 8 crash workaround

+ (CIContext *)LW_contextWithOptions:(NSDictionary<NSString *, id> *)options;

@end
