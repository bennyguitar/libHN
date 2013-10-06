libHN
=====

The definitive Cocoa framework for adding HackerNews to your iOS/Mac app. This mini library includes features such as grabbing Posts (including filtering by Top, Ask, New, Jobs, Best), Comments, Logging in, and Submitting new posts/comments!

---------------------

## Getting Started

Installing libHN is a breeze. First things first, add all of the classes in the top-level **libHN Classes** folder inside of this repository into your app. Done? Good. Now, just <code>#import "libHN.h"</code> in any of your controllers, classes, or views you plan on using libHN in. That's it. We're done here.

---------------------

## HNManager

**HNManager** is going to be your go-to class for using libHN. Every action flows through there - all web calls, session generation, etc. It's your conduit to HackerNews functionality. HNManager is a Singleton class, and has a <code>defaultManager</code> initialization that you should use to make sure everything gets routed correctly through the Manager.

---------------------

## Fetching Posts

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

---------------------

## Fetching Comments

Coming soon!

---------------------

## Logging In/Out

Coming soon!

---------------------

## Submitting a New Post!

Coming soon!

---------------------

## Replying to a Post/Comment!

Coming soon!

---------------------

## License

Coming soon!

---------------------
