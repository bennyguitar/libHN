//
//  HNWebService.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNPost.h"
#import "HNComment.h"

#pragma mark - Enums
typedef NS_ENUM(NSInteger, PostFilterType) {
    PostFilterTypeTop,
    PostFilterTypeAsk,
    PostFilterTypeNew,
    PostFilterTypeBest
};


#pragma mark - Blocks
typedef void (^GetPostsCompletion) (NSArray *posts);
typedef void (^GetCommentsCompletion) (NSArray *comments);
typedef void (^BooleanSuccessBlock) (BOOL success);


#pragma mark - HNWebService
@interface HNWebService : NSObject

@property (nonatomic, retain) NSOperationQueue *HNQueue;

@end


#pragma mark - HNOperation
@interface HNOperation : NSOperation

@end
