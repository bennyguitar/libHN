//
//  HNWebService.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNWebService.h"
#import "HNManager.h"

#define kBaseURLAddress @"https://news.ycombinator.com/"
#define kMaxConcurrentConnections 15

#pragma mark - HNWebService
@implementation HNWebService

- (instancetype)init {
    if (self = [super init]) {
        self.HNQueue = [[NSOperationQueue alloc] init];
        [self.HNQueue setMaxConcurrentOperationCount:kMaxConcurrentConnections];
    }
    
    return self;
}


#pragma mark - Load Posts With Filter
- (void)loadPostsWithFilter:(PostFilterType)filter completion:(GetPostsCompletion)completion {
    // Set the Path
    NSString *pathAddition = @"";
    switch (filter) {
        case PostFilterTypeTop:
            pathAddition = @"";
            break;
        case PostFilterTypeAsk:
            pathAddition = @"ask";
            break;
        case PostFilterTypeBest:
            pathAddition = @"best";
            break;
        case PostFilterTypeJobs:
            pathAddition = @"jobs";
            break;
        case PostFilterTypeNew:
            pathAddition = @"newest";
            break;
        default:
            break;
    }
    NSString *urlPath = [NSString stringWithFormat:@"%@%@", kBaseURLAddress, pathAddition];
    
    // Load the Posts
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:Nil completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSString *fnid = @"";
            NSArray *posts = [HNPost parsedPostsFromHTML:html FNID:&fnid];
            if (posts) {
                [[HNManager sharedManager] setPostFNID:fnid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(posts);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
}


#pragma mark - Load Posts with FNID
- (void)loadPostsWithFNID:(NSString *)fnid completion:(GetPostsCompletion)completion {
    // Create URL Path
    NSString *urlPath = [NSString stringWithFormat:@"%@x?%@", kBaseURLAddress, fnid];
    
    // Load the Posts
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:Nil completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSString *fnid = @"";
            NSArray *posts = [HNPost parsedPostsFromHTML:html FNID:&fnid];
            if (posts) {
                [[HNManager sharedManager] setPostFNID:fnid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(posts);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
}


#pragma mark - Load Comments from Post
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion {
    // Create URL Path
    NSString *urlPath = [NSString stringWithFormat:@"%@item?id=%@", kBaseURLAddress, post.PostId];
    
    // Load the Posts
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:Nil completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSArray *comments = [HNComment parsedCommentsFromHTML:html];
            if (comments) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(comments);
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];

}

@end






#pragma mark - HNOperation
@implementation HNOperation

#pragma mark - Set URL Path
-(void)setUrlPath:(NSString *)path data:(NSData *)data completion:(void (^)(void))block {
    self.urlPath = path;
    [self setCompletionBlock:block];
    if (data) {
        self.bodyData = data;
    }
}


#pragma mark - Background
-(BOOL)isConcurrent {
    return YES;
}


#pragma mark - Main Run Loop
-(void)main {
    // Build Request
    NSMutableURLRequest *request;
    if (self.bodyData) {
        request = [HNOperation newJSONRequestWithURL:[NSURL URLWithString:self.urlPath] bodyData:self.bodyData];
    }
    else {
        request = [HNOperation newGetRequestForURL:[NSURL URLWithString:self.urlPath]];
    }
    
    // Execute
    NSError *error;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    self.responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}


#pragma mark - URL Request Building
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [Request setHTTPMethod:@"GET"];
    
    return Request;
}

+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData{
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [Request setHTTPBody:bodyData];
    [Request setHTTPShouldHandleCookies:YES];
    [Request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    return Request;
}

@end