//
//  AsyncImageView.m
//
//  Created by Stuart Hall on 9/03/11.
//

#import "AsyncImageView.h"


@implementation AsyncImageView

@synthesize responseData;
@synthesize delegate;
@synthesize requestedUrl;
@synthesize connection;

static NSString* CacheDirectory = nil;

- (void)dealloc {
    // Cleanup
	self.responseData = nil;
	self.delegate = nil;
    self.connection = nil;
	[super dealloc];
}

- (NSString*)pathForImage:(NSString*)url {
	// Ensure the cache directory has been preloaded
	if (!CacheDirectory) {
        // Extract the cache path
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		CacheDirectory = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"AsyncImageView"] retain];
        
        // Ensure our folder exists
        [[NSFileManager defaultManager] createDirectoryAtPath:CacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	// Take the url and make a valid filename
	NSString* filename = [[url componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
	filename = [filename stringByAppendingString:@".img"];
	return [CacheDirectory stringByAppendingPathComponent:filename];
}

- (void)saveFileImage:(UIImage *)image forUrl:(NSString*)url {
	// Extract the data for the image
	NSData* data = UIImagePNGRepresentation(image);
	if (!data) {
		data = UIImageJPEGRepresentation(image, 1.0);
	}
	
	// Write to the disk
    [[NSFileManager defaultManager] createFileAtPath:[self pathForImage:url] contents:data attributes:nil];
}

- (UIImage *)loadFileImage:(NSString *)url { 
	// Attempts to load the image from a url
    return [UIImage imageWithContentsOfFile:[self pathForImage:url]];
}

- (void)loadFromUrl:(NSString*)url {
    // Cancel the existing request
    if (connection) {
        [connection cancel];
        self.connection = nil;
    }
    
	// See if we have the image cached already
	self.image = [self loadFileImage:url];
	if (!self.image) {
		// Not cached
		self.requestedUrl = url;
		self.responseData = [NSMutableData data];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		[request setHTTPMethod:@"GET"];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// Trim any data we currently have, request is about to start
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// Just append our data
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
	// Request failed
	self.connection = nil;
	
	// Alert the delegate of failure
	if (delegate && [delegate respondsToSelector:@selector(onImageFailed:)]) {
		[delegate onImageFailed:self];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)c {
	// Success!
	self.connection = nil;	
	
	// Turn into an image
	self.image = [UIImage imageWithData:responseData];
	if (self.image) {
		// Cache the image
		[self saveFileImage:self.image forUrl:requestedUrl];
		
		// Alert the delegate
		if (delegate && [delegate respondsToSelector:@selector(onImageLoaded:image:)]) {
			[delegate onImageLoaded:self image:self.image];
		}
	}
	else {
		// Alert the delegate of failure
		if (delegate && [delegate respondsToSelector:@selector(onImageFailed:)]) {
			[delegate onImageFailed:self];
		}
	}

	
	// Cleanup
	self.responseData = nil;
}

#pragma mark Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	// Add some user feedback like a button
	self.alpha = 0.5;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	// Clear the user feedback
	self.alpha = 1;
	
	if (delegate) {
		// Let the delegate know about the touch
		[delegate onTouchUpInside:self];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	
	// Clear the user feedback
	self.alpha = 1;
}

@end

