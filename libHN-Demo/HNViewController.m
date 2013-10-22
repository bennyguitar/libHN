//
//  HNViewController.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNViewController.h"
#import "libHN.h"

@interface HNViewController ()

@end

@implementation HNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Test Login
    //[[HNManager sharedManager] logout];
    [self loginTest];
    
    //[self performSelector:@selector(getPostsTest) withObject:nil afterDelay:6];
    
    // Test Getting Posts
    //[self getPostsTest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginTest {
    // If no user is logged in, log in
    if (![[HNManager sharedManager] userIsLoggedIn]) {
        [[HNManager sharedManager] loginWithUsername:@"user" password:@"pass" completion:^(HNUser *user) {
            if (user) {
                [self getPostsTest];
            }
        }];
    }
}

- (void)getPostsTest {
    [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeTop completion:^(NSArray *posts) {
        if (posts) {
            // Test Getting Comments
            //[self getCommentsTest:posts[0]];
            [[HNManager sharedManager] replyToPostOrComment:posts[0] withText:@"Test" completion:^(BOOL success) {
                NSLog(@"%d", success);
            }];
        }
    }];
}

- (void)getCommentsTest:(HNPost *)post {
    [[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
        if (comments) {
            [[HNManager sharedManager] replyToPostOrComment:comments[0] withText:@"Test" completion:^(BOOL success) {
                NSLog(@"%d", success);
            }];
        }
    }];
}

- (void)submitStoryTest {
    [[HNManager sharedManager] submitPostWithTitle:@"Testing from App" link:nil text:@"TEST. Please let me know that this shit actually works." completion:^(BOOL success) {
        NSLog(@"Success: %d", success);
    }];
}

@end
