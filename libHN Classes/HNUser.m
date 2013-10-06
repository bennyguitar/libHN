//
//  HNUser.m
//  libHN-Demo
//
//  Created by Ben Gordon on 10/6/13.
//  Copyright (c) 2013 subvertapps. All rights reserved.
//

#import "HNUser.h"

@implementation HNUser

#pragma mark - New User from an HTML response
+(HNUser *)userFromHTML:(NSString *)html {
    // Make a new user
    HNUser *newUser = [[HNUser alloc] init];
    
    // Scan HTML into strings
    NSString *trash=@"", *age=@"", *karma=@"", *about=@"";
    NSScanner *scanner = [NSScanner scannerWithString:html];
    [scanner scanUpToString:@"created:" intoString:&trash];
    [scanner scanString:@"created:</td><td>" intoString:&trash];
    [scanner scanUpToString:@" " intoString:&age];
    [scanner scanUpToString:@"karma:" intoString:&trash];
    [scanner scanString:@"karma:</td><td>" intoString:&trash];
    [scanner scanUpToString:@"</td>" intoString:&karma];
    [scanner scanUpToString:@"name=\"about\"" intoString:&trash];
    [scanner scanString:@"name=\"about\">" intoString:&trash];
    [scanner scanUpToString:@"</textarea>" intoString:&about];
    
    // Bad response
    if (age.length == 0) {
        return nil;
    }
    if (karma.length == 0) {
        return nil;
    }
    
    // Set properties
    newUser.Age = [age intValue];
    newUser.Karma = [karma intValue];
    newUser.AboutInfo = about;
    
    return newUser;
}


@end
