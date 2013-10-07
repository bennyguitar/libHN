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
    [operation setUrlPath:urlPath data:nil cookie:nil completion:^{
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
    [self.HNQueue addOperation:operation];
}


#pragma mark - Load Posts with FNID
- (void)loadPostsWithFNID:(NSString *)fnid completion:(GetPostsCompletion)completion {
    // Create URL Path
    NSString *urlPath = [NSString stringWithFormat:@"%@x?%@", kBaseURLAddress, fnid];
    
    // Load the Posts
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:nil completion:^{
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
    [self.HNQueue addOperation:operation];
}


#pragma mark - Load Comments from Post
- (void)loadCommentsFromPost:(HNPost *)post completion:(GetCommentsCompletion)completion {
    // Create URL Path
    NSString *urlPath = [NSString stringWithFormat:@"%@item?id=%@", kBaseURLAddress, post.PostId];
    
    // Load the Comments
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:nil completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            NSArray *comments = [HNComment parsedCommentsFromHTML:html forPost:post];
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
    [self.HNQueue addOperation:operation];
}


#pragma mark - Login
- (void)loginWithUsername:(NSString *)user pass:(NSString *)pass completion:(LoginCompletion)completion {
    // Login is a three-part process
    // 1. go to https://news.ycombinator.com/newslogin?whence=%6e%65%77%73 and grab the fnid for the login submit button
    // 2. pass this info in to that url via a POST request
    // 3. build a User object by going to that specific URL as well
    
    
    // First things first, let's grab that FNID
    NSString *urlPath = [NSString stringWithFormat:@"%@newslogin?whence=news", kBaseURLAddress];
    
    // Build the operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:nil completion:^{
        if (blockOperation.responseData) {
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (html) {
                NSString *fnid = @"", *trash = @"";
                NSScanner *fnidScan = [NSScanner scannerWithString:html];
                [fnidScan scanUpToString:@"name=\"fnid\" value=\"" intoString:&trash];
                [fnidScan scanString:@"name=\"fnid\" value=\"" intoString:&trash];
                [fnidScan scanUpToString:@"\"" intoString:&fnid];
                
                if (fnid.length > 0) {
                    // We grabbed the fnid, now attempt part 2
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self part2LoginWithFNID:fnid user:user pass:pass completion:completion];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil);
                    });
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}

- (void)part2LoginWithFNID:(NSString *)fnid user:(NSString *)user pass:(NSString *)pass completion:(LoginCompletion)completion {
    // Now let's attempt to login
    NSString *urlPath = [NSString stringWithFormat:@"%@y", kBaseURLAddress];
    
    // Build the body data
    NSString *bodyString = [NSString stringWithFormat:@"fnid=%@&u=%@&p=%@",fnid,user,pass];
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:bodyData cookie:nil completion:^{
        if (blockOperation.responseData) {
            // Now attempt part 3
            NSString *responseString = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (responseString) {
                if ([responseString rangeOfString:@">Bad login.<"].location == NSNotFound) {
                    // Login Succeded, let's create a user
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getUser:user completion:completion];
                    });
                }
                else {
                    // Login failed
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
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}

- (void)getUser:(NSString *)user completion:(LoginCompletion)completion {
    // And finally we attempt to create the User
    // Build URL String
    NSString *urlPath = [NSString stringWithFormat:@"%@user?id=%@", kBaseURLAddress, user];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:nil completion:^{
        if (blockOperation.responseData) {
            // Now attempt part 3
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (html) {
                HNUser *user = [HNUser userFromHTML:html];
                if (user) {
                    // Finally return the user we've been looking for
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(user);
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
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}


- (void)validateAndSetSessionWithCookie:(NSHTTPCookie *)cookie completion:(LoginCompletion)completion {
    // And finally we attempt to create the User
    // Build URL String
    NSString *urlPath = [NSString stringWithFormat:@"%@", kBaseURLAddress];
    
    // Start the Operation
    HNOperation *operation = [[HNOperation alloc] init];
    __block HNOperation *blockOperation = operation;
    [operation setUrlPath:urlPath data:nil cookie:cookie completion:^{
        if (blockOperation.responseData) {
            // Now attempt part 3
            NSString *html = [[NSString alloc] initWithData:blockOperation.responseData encoding:NSUTF8StringEncoding];
            if (html) {
                if ([html rangeOfString:@"<a href=\"logout?whence=%6e%65%77%73\">"].location != NSNotFound) {
                    NSScanner *scanner = [[NSScanner alloc] initWithString:html];
                    NSString *trash = @"", *userString = @"";
                    [scanner scanUpToString:@"<a href=\"threads?id=" intoString:&trash];
                    [scanner scanString:@"<a href=\"threads?id=" intoString:&trash];
                    [scanner scanUpToString:@"\">" intoString:&userString];
                    [self getUser:userString completion:^(HNUser *user) {
                        if (user) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(user);
                            });
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(nil);
                            });
                        }
                    }];
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
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
    [self.HNQueue addOperation:operation];
}

@end






#pragma mark - HNOperation
@implementation HNOperation

#pragma mark - Set URL Path
-(void)setUrlPath:(NSString *)path data:(NSData *)data cookie:(NSHTTPCookie *)cookie completion:(void (^)(void))block {
    if (self.bodyData) {
        self.urlRequest = [HNOperation newJSONRequestWithURL:[NSURL URLWithString:path] bodyData:self.bodyData cookie:cookie];
    }
    else {
        self.urlRequest = [HNOperation newGetRequestForURL:[NSURL URLWithString:path] cookie:cookie];
    }
    
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
    // Execute
    NSError *error;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
    self.responseData = [NSURLConnection sendSynchronousRequest:self.urlRequest returningResponse:&response error:&error];
}


#pragma mark - URL Request Building
+(NSMutableURLRequest *)newGetRequestForURL:(NSURL *)url cookie:(NSHTTPCookie *)cookie {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [Request setHTTPMethod:@"GET"];
    
    if (cookie) {
        [Request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]]];
    }
    
    return Request;
}

+(NSMutableURLRequest *)newJSONRequestWithURL:(NSURL *)url bodyData:(NSData *)bodyData cookie:(NSHTTPCookie *)cookie {
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:url];
    [Request setHTTPMethod:@"POST"];
    [Request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [Request setHTTPBody:bodyData];
    [Request setHTTPShouldHandleCookies:YES];
    [Request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    if (cookie) {
        [Request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie]]];
    }
    
    return Request;
}

@end