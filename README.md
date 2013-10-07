libHN
=====

The definitive Cocoa framework for adding HackerNews to your iOS/Mac app. This mini library includes features such as grabbing Posts (including filtering by Top, Ask, New, Jobs, Best), Comments, Logging in, and Submitting new posts/comments!

![Screenshot](https://raw.github.com/bennyguitar/libHN/master/Screenshots/screen1-01.png)

---------------------

## Table of Contents

* [Installing](#getting-started)
* [HNManager](#hn-manager)
* HN Web Calls
  * [Fetching Posts](#fetching-posts)
  * [Fetching Comments for a Post](#fetching-comments)
  * [Logging In/Out](#login-out)
  * [Submitting a Post](#submit)
  * [Reply to a Post/Comment](#reply)
  * [Voting on a Post/Comment](#voting)
  * [Fetching submissions for a Username](#get-submissions)
* [License](#license)

## <a id="getting-started"></a>Getting Started

Installing libHN is a breeze. First things first, add all of the classes in the top-level **libHN Classes** folder inside of this repository into your app. Done? Good. Now, just <code>#import "libHN.h"</code> in any of your controllers, classes, or views you plan on using libHN in. That's it. We're done here.

---------------------

## <a id="hn-manager"></a>HNManager

**HNManager** is going to be your go-to class for using libHN. Every action flows through there - all web calls, session generation, etc. It's your conduit to HackerNews functionality. HNManager is a Singleton class, and has a <code>defaultManager</code> initialization that you should use to make sure everything gets routed correctly through the Manager.

---------------------

## <a id="fetching-posts"></a>Fetching Posts

Because of the way HackerNews is set up, there are two methods for getting posts. The first one <code>loadPostsWithFilter:completion:</code>, is your beginning method to retrieving posts based on a filter. So if you go to the [HN homepage](https://news.ycombinator.com/) this is what you'd get if you call this method and use <code>PostFilterTypeTop</code> as the PostFilterType parameter.

If you notice on the homepage, at the very bottom, there's a "More" button. Click that then look at the URL Bar. Notice the funky string that looks like this: "fnid=kS3LAcKvtXPC85KnoQszPW" at the end of the URL? HackerNews works on assigning an fnid, or basically a SessionKey, to determine what page you are going to and the authenticity of its request/response. This is used for every action on the site except for getting the first 25 links of any post type. This is where the second method comes in, <code>loadPostsWithFNID:completion:</code>, which takes in an FNID string to determine what posts should come next.

**loadPostsWithFilter**

This method takes in a PostFilterType parameter and returns an NSArray of <code>HNPost</code> objects. The various PostFilterTypes, and the types of posts you receive are listed below:

* PostFilterTypeTop - [HomePage](https://news.ycombinator.com/)
* PostFilterTypeAsk - [Ask HN](https://news.ycombinator.com/ask)
* PostFilterTypeNew - [Newest Posts](https://news.ycombinator.com/newest)
* PostFilterTypeJobs - [HN Jobs](https://news.ycombinator.com/jobs)
* PostFilterTypeBest - [Highest Rated Posts Recently](https://news.ycombinator.com/best)

And here's how to use this:

```objc
[[HNManager sharedManager] loadPostsWithFilter:(PostFilterType)filter completion:(NSArray *posts){
  if (posts) {
    // Posts were successfuly retrieved
  }
  else {
    // No posts retrieved, handle the error
  }
}];
```

**loadPostsWithFNID**

Now that you've gotten the first set of posts, use this method to keep retrieving posts in that Filter. The FNID parameter is mostly taken care of with the <code>postFNID</code> property of the HNManager. If you wanted to do something custom, you could pass in a string of your choosing here, but I recommend sticking with the default postFNID property. Every time you load posts with any of these two methods, the postFNID parameter is updated on the sharedManager.

```objc
[[HNManager sharedManager] loadPostsWithFNID:[[HNManager sharedManager] postFNID] completion:(NSArray *posts){
  if (posts) {
    // Posts were successfuly retrieved
  }
  else {
    // No posts retrieved, handle the error
  }
}];
```

**HNpost.{h,m}**

The actual HNPost object is fairly simple. It just contains the metadata about the post like Title, and the URL. There is a class method here that scans through the HTML passed in to return the array of posts that the two web methods above return. This is the low-level stuff that you should never have to mess with, but might be beneficial to pore over if you'd like to learn more or implement changes yourself.

```objc
// HNPost.h

// Enums
typedef NS_ENUM(NSInteger, PostType) {
    PostTypeDefault,
    PostTypeAskHN,
    PostTypeJobs
};

// Properties
@property (nonatomic, assign) PostType *Type;
@property (nonatomic,retain) NSString *Username;
@property (nonatomic, retain) NSURL *Url;
@property (nonatomic, retain) NSString *UrlDomain;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, assign) int Points;
@property (nonatomic, assign) int CommentCount;
@property (nonatomic, retain) NSString *PostId;
@property (nonatomic, retain) NSString *TimeCreatedString;

// Methods
+ (NSArray *)parsedPostsFromHTML:(NSString *)html FNID:(NSString **)fnid;
```

---------------------

## <a id="fetching-comments"></a>Fetching Comments

There's only one method to load comments, and naturally, it follows from loading the Posts. After you load your Posts, you can pass one in to the following method to return an array of <code>HNComment</code> objects. If you go to an AskHN post, you'll notice that the text is inline with the rest of the comments (separated by a text area for a reply), so I decided to include that self-post as the first comment in the returned array. You can tell what this is by using the <code>Type</code> property of the HNComment. The same goes for an HNJobs post. Sometimes, a Jobs post will be a self-post to HN, instead of an external link, so you can capture this data in the exact same way as a regular comment. If the Type == CommentTypeJobs, then you know you have a self jobs post.

The main reason I did this for AskHN and Jobs was to get any Link data out of the post, and to present things nicely to the user inline with any other comments inside my own personal app.

```objc
[[HNManager sharedManager] loadCommentsFromPost:(HNPost *)post completion:(NSArray *comments){
  if (comments) {
    // Comments retrieved.
  }
  else {
    // No comments retrieved, handle the error
  }
}];
```

**HNComment.{h,m}**

Similar to the HNPost object, HNComment features a handy class method that generates an NSArray of HNComments by parsing the HTML itself. Again, I'd look this over just to get a feel for how it works.

```objc
// HNComment.h

// Enums
typedef NS_ENUM(NSInteger, CommentType) {
    CommentTypeDefault,
    CommentTypeAskHN,
    CommentTypeJobs
};

// Properties
@property (nonatomic, assign) CommentType *Type;
@property (nonatomic, retain) NSString *Text;
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *CommentId;
@property (nonatomic, retain) NSString *ParentID;
@property (nonatomic, retain) NSString *TimeCreatedString;
@property (nonatomic, retain) NSString *ReplyURLString;
@property (nonatomic, assign) int Level;
@property (nonatomic, retain) NSArray *Links;

// Methods
+ (NSArray *)parsedCommentsFromHTML:(NSString *)html;
```

---------------------

## <a id="login-out"></a>Logging In/Out

User related actions are a vital aspect of being part of the HackerNews community. I mean, if you can't be active in discussion or submit interesting links, then you might as well be a bystander. Unfortunately most HN Reader iOS/Mac apps neglect this part of the community and focus more on the interesting links themselves. There's a good reason for this - it's not trivial to implement; you have to think about Cookies and going through two web calls just to get a submission or comment to go through. It's annoying, and I've decided to make developers' lives easier by doing the annoying work myself and abstracting it away so you don't have to think about it again. It all starts with logging in.

The way HN operates in the browser is off of an HTTP Cookie. This Cookie is generated at login, and kept around for a pretty long time. Logging in on a different computer invalidates all Cookies for a user. Therefore, it's necessary to check if there's a cookie, and validate it before attempting to login. This is done automatically when the HNManager initializes itself using the method <code>validateAndSetCookie</code>. It will find the Cookie on the device and attempt to validate it. If it does check out, it will set the cookie to the <code>SessionCookie</code> parameter of the HNManager, as well as grab the correct HNUser so that the <code>SessionUser</code> property is filled in as well. If it doesn't find a Cookie, or the cookie is no longer valid, you will need to login the old-fashioned way using the following method.

**If: SessionCookie and SessionUser are nil, you need to login with this method.**

**Else: don't call this method, as it will generate an entirely new Cookie, and just be a wasted web call.**

```objc
[[HNManager sharedManager] loginWithUsername:@"user" password:@"pass" completion:(HNUser *user){
  if (user) {
    // Login was successful!
  }
  else {
    // Login failed, handle the error
  }
}];
```

Logging out just deletes the SessionCookie property and the SessionUser property from memory, as well as the actual cookie from <code>[NSHTTPCookieStorage sharedStorage]</code>, so you can't use them any more to make user-specific requests like submitting and commenting. Logging out is dead simple to implement.

```objc
[[HNManager sharedManager] logout];
```

---------------------

## <a id="submit"></a>Submitting a New Post

Coming soon!

---------------------

## <a id="reply"></a>Replying to a Post/Comment

Coming soon!

---------------------

## <a id="voting"></a>Voting on a Post/Comment

Coming soon!

---------------------

## <a id="get-submissions"></a>Fetching all submissions for a User

Coming soon!

---------------------

## <a id="license"></a>License

libHN is licensed under the standard MIT License.

**Copyright (C) 2013 by Benjamin Gordon**

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

---------------------
