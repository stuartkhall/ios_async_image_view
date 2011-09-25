//
//  AsyncImageView.h
//
//  Created by Stuart Hall on 9/03/11.
//

#import <Foundation/Foundation.h>

// OSX Support
#ifndef UIImageView
#define UIImageView NSImageView
#endif
#ifndef UIImage
#define UIImage NSImage
#endif

@protocol AsyncImageViewDelegate;

@interface AsyncImageView : UIImageView {
	__weak id<AsyncImageViewDelegate> delegate;
	
@private
	NSMutableData *responseData;
	NSString* requestedUrl;
    NSURLConnection* connection;
}

@property (nonatomic, retain) NSString* flag;

@property (nonatomic, assign) __weak id<AsyncImageViewDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString* requestedUrl;
@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSColor* borderColor;
@property (assign) BOOL enableInteraction;

- (void)loadFromUrl:(NSString*)url;

@end

@protocol AsyncImageViewDelegate<NSObject>

@optional

- (void)onImageLoaded:(AsyncImageView*)iv image:(UIImage*)image;
- (void)onImageFailed:(AsyncImageView*)iv;
- (void)onImageClicked:(AsyncImageView*)iv;

@end