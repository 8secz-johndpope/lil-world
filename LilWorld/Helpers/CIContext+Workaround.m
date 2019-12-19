//
//  CIContext+CIContext_Workaround.m
//  LilWorld
//
//  Created by Aleksandr Novikov on 27.09.16.
//  Copyright © 2016 Adno. All rights reserved.
//

#import "CIContext+Workaround.h"

@implementation CIContext (Workaround)

+ (CIContext *)LW_contextWithOptions:(NSDictionary<NSString *, id> *)options {
    return [CIContext contextWithOptions:options];
}

@end
