//
//  APImageStore.h
//  ICE-IT
//
//  Created by Andi Palo on 19/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APImageStore : NSObject

+ (NSArray*) getCurrentStoredImages;
+ (UIImage *)imageWithImageName:(NSString *)image scaledToSize:(CGSize)newSize;


@end
