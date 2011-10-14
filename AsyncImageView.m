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
@synthesize flag;
@synthesize borderColor;
@synthesize enableInteraction;

static NSString* CacheDirectory = nil;

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.enableInteraction = YES;
    }
    
    return self;
}

- (void)dealloc {
    // Cleanup
    self.flag = nil;
	self.responseData = nil;
	self.delegate = nil;
    self.connection = nil;
    self.borderColor = nil;
    
	[super dealloc];
}

- (NSString*)pathForImage:(NSString*)url {
	// Ensure the cache directory has been preloaded
	if (!CacheDirectory) {
        // Extract the cache path
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        NSString* bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
		CacheDirectory = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName]  stringByAppendingPathComponent:@"AsyncImageView"] retain];
        
        // Ensure our folder exists
        [[NSFileManager defaultManager] createDirectoryAtPath:CacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	// Take the url and make a valid filename
	NSString* filename = [[url componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
	filename = [filename stringByAppendingString:@".img"];
	return [CacheDirectory stringByAppendingPathComponent:filename];
}

- (void)saveFileImage:(NSData *)data forUrl:(NSString*)url {
	// Write to the disk
    [[NSFileManager defaultManager] createFileAtPath:[self pathForImage:url] contents:data attributes:nil];
}

- (UIImage *)loadFileImage:(NSString *)url { 
	// Attempts to load the image from a url
    return [[[UIImage alloc] initWithContentsOfFile:[self pathForImage:url]] autorelease];
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
  else {
    // Alert the delegate
		if (delegate && [delegate respondsToSelector:@selector(onImageLoaded:image:)]) {
			[delegate onImageLoaded:self image:self.image];
		}
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
	self.image = [[[UIImage alloc] initWithData:responseData] autorelease];
	if (self.image) {
		// Cache the image
		[self saveFileImage:responseData forUrl:requestedUrl];
		
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

- (void)mouseDown:(NSEvent *)event {
    if (enableInteraction)
        [self setAlphaValue:0.5];
    else
        [super mouseDown:event];
}

- (void)mouseUp:(NSEvent *)event {
    if (enableInteraction) {
        [self setAlphaValue:1];
        
        if (delegate && [delegate respondsToSelector:@selector(onImageClicked:)]) {
            [delegate onImageClicked:self];
        }
    }
    else {
        [super mouseUp:event];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (enableInteraction) {
        [self setAlphaValue:1];
    }
    else {
        [super mouseExited:theEvent];
    }
}

- (void)drawRect:(NSRect)frame {
    [super drawRect:frame]; // this takes care of image
    
    if (borderColor) {
        [NSBezierPath setDefaultLineWidth:1.0];
        [borderColor set];
        [NSBezierPath strokeRect:frame];
    }
}


@end

