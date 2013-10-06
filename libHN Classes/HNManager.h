//
//  HNManager.h
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HNWebService.h"

@interface HNManager : NSObject

#pragma mark - Properties
@property (nonatomic, retain) HNWebService *Service;
@property (nonatomic, retain) NSString *postFNID;

#pragma mark - Singleton Manager
+ (HNManager *)sharedManager;

#pragma mark - WebService Methods
- (void)loginWithUsername:(NSString *)user password:(NSString *)pass completion:(BooleanSuccessBlock)completion;
- (void)logout;
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion;
- (void)loadPostsWithFNID:(NSString *)fnid completion:(GetPostsCompletion)completion;
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion;

@end
