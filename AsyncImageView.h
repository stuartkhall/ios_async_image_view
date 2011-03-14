//
//  AsyncImageView.h
//
//  Created by Stuart Hall on 9/03/11.
//

#import <Foundation/Foundation.h>

@protocol AsyncImageViewDelegate;

@interface AsyncImageView : UIImageView {
	__weak id<AsyncImageViewDelegate> delegate;
	
@private
	NSMutableData *responseData;
	NSString* requestedUrl;
    NSURLConnection* connection;
}

@property (nonatomic, assign) __weak id<AsyncImageViewDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString* requestedUrl;
@property (nonatomic, retain) NSURLConnection* connection;

- (void)loadFromUrl:(NSString*)url;

@end

@protocol AsyncImageViewDelegate<NSObject>

- (void)onTouchUpInside:(AsyncImageView*)iv;

@optional

- (void)onImageLoaded:(AsyncImageView*)iv image:(UIImage*)image;
- (void)onImageFailed:(AsyncImageView*)iv;

@end