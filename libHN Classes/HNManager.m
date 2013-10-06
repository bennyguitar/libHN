//
//  HNManager.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNManager.h"

@implementation HNManager

// Build the static manager object
static HNManager * _sharedManager = nil;


#pragma mark - Set Up HNManager's Singleton
+ (HNManager *)sharedManager {
	@synchronized([HNManager class]) {
		if (!_sharedManager)
            _sharedManager  = [[HNManager alloc] init];
		return _sharedManager;
	}
	return nil;
}

+ (id)alloc {
	@synchronized([HNManager class]) {
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
	return nil;
}

- (instancetype)init {
	if (self = [super init]) {
        self.Service = [[HNWebService alloc] init];
	}
	return self;
}


#pragma mark - WebService Methods
- (void)loginWithUsername:(NSString *)user password:(NSString *)pass completion:(BooleanSuccessBlock)completion {
    
}

- (void)logout {
    
}

- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion {
    [self.Service loadPostsWithFilter:filter completion:completion];
}

- (void)loadPostsWithFNID:(NSString *)fnid completion:(GetPostsCompletion)completion {
    [self.Service loadPostsWithFNID:fnid completion:completion];
}

- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion {
    [self.Service loadCommentsFromPost:post completion:completion];
}



@end
