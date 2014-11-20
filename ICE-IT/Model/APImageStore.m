//
//  APImageStore.m
//  ICE-IT
//
//  Created by Andi Palo on 19/11/14.
//  Copyright (c) 2014 Andi Palo. All rights reserved.
//

#import "APImageStore.h"

@implementation APImageStore

+ (NSArray*) getCurrentStoredImages{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:docPath error:&error];
    NSString *flag_match = @"flag@2x.png";
    NSString *city_match = @"img@2x.png";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF ENDSWITH[cd] %@) OR (SELF ENDSWITH[cd] %@)", flag_match,city_match];
    NSArray *results = [contents filteredArrayUsingPredicate:predicate];
    
    [result addObjectsFromArray:results];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    contents = [fileManager contentsOfDirectoryAtPath:[bundleURL path] error:&error];
    predicate = [NSPredicate predicateWithFormat:@"(SELF ENDSWITH[cd] %@ OR SELF ENDSWITH[cd] %@)", flag_match,city_match];
    results = [contents filteredArrayUsingPredicate:predicate];
    [result addObjectsFromArray:results];
    
    return result;
}

@end
