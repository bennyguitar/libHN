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
    PostFilterTypeJobs,
    PostFilterTypeBest
};


#pragma mark - Blocks
typedef void (^GetPostsCompletion) (NSArray *posts);
typedef void (^GetCommentsCompletion) (NSArray *comments);
typedef void (^BooleanSuccessBlock) (BOOL success);


#pragma mark - HNWebService
@interface HNWebService : NSObject

// Properties
@property (nonatomic, retain) NSOperationQueue *HNQueue;

// Methods
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion;
- (void)loadPostsWithFNID:(NSString *)fnid completion:(GetPostsCompletion)completion;

@end


#pragma mark - HNOperation
@interface HNOperation : NSOperation

// Properties
@property (nonatomic, retain) NSString *urlPath;
@property (nonatomic, retain) NSData *bodyData;
@property (nonatomic, retain) NSData *responseData;

// Set Path
-(void)setUrlPath:(NSString *)path data:(NSData *)data completion:(void (^)(void))block;

// Web Request Builders
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url;
+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData;

@end
