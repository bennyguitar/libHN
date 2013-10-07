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
#import "HNUser.h"

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
typedef void (^LoginCompletion) (HNUser *user, NSHTTPCookie *cookie);
typedef void (^BooleanSuccessBlock) (BOOL success);


#pragma mark - HNWebService
@interface HNWebService : NSObject

// Properties
@property (nonatomic, retain) NSOperationQueue *HNQueue;

// Methods
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion;
- (void)loadPostsWithFNID:(NSString *)fnid completion:(GetPostsCompletion)completion;
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion;
- (void)loginWithUsername:(NSString *)user pass:(NSString *)pass completion:(LoginCompletion)completion;
- (void)validateAndSetSessionWithCookie:(NSHTTPCookie *)cookie completion:(LoginCompletion)completion;

@end


#pragma mark - HNOperation
@interface HNOperation : NSOperation

// Properties
@property (nonatomic, retain) NSURLRequest *urlRequest;
@property (nonatomic, retain) NSData *bodyData;
@property (nonatomic, retain) NSData *responseData;

// Set Path
-(void)setUrlPath:(NSString *)path data:(NSData *)data cookie:(NSHTTPCookie *)cookie completion:(void (^)(void))block;

// Web Request Builders
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url cookie:(NSHTTPCookie *)cookie;
+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData cookie:(NSHTTPCookie *)cookie;

@end
