//
//  Copyright (c) 2010, Kevin Bowman
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  * Neither the name of the organisation (joind.in) nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APICaller.h"
#import "JSON.h"
#import "EventListModel.h"
#import "EventDetailModel.h"
#import "TalkListModel.h"
#import "TalkDetailModel.h"
#import "NSString+md5.h"

@implementation APICaller

@synthesize delegate;
@synthesize urlData;
@synthesize connection;
@synthesize reqJSON;
@synthesize url;

- (id)initWithDelegate:(id)_delegate {
	self.delegate = _delegate;
	self.urlData = [[NSMutableData alloc] init];
	return self;
}

- (NSString *)getApiUrl {
	return API_URL;
}

#pragma mark Cache control methods

- (BOOL)checkCacheForRequest:(NSString *)_reqJSON toUrl:(NSString *)_url ignoreExpiry:(BOOL)ignoreExpiry {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *filename = [NSString stringWithFormat:@"%@/%@.json",  [paths objectAtIndex:0], [[NSString stringWithFormat:@"%@%@", _reqJSON, _url] md5]];
	//NSLog(@"Cache file is %@", filename);
	NSString *result = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
	if (result == NULL) {
		//NSLog(@"Not cached");
		return NO;
	} else {
		//NSLog(@"Cached, checking expiry...");
		NSDictionary *data = [result JSONValue];
		if (!ignoreExpiry) {
			//NSLog(@"Expiry: %i", [[data valueForKey:@"expires"] integerValue]);
			if ([[data valueForKey:@"expires"] integerValue] < [[NSDate date] timeIntervalSince1970] ) {
				//NSLog(@"Expired");
				return NO;
			}
		}
		// Store the data which made this response
		self.reqJSON = _reqJSON;
		self.url = _url;
		//NSLog(@"Returning cached data");
		[self gotResponse:[data valueForKey:@"data"]];
		return YES;
	}
}

- (void)writeDataToCache:(NSString *)responseString requestJSON:(NSString *)_reqJSON toUrl:(NSString *)_url {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];
	[d setObject:responseString forKey:@"data"];
	[d setObject:[NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:CACHE_TIME] timeIntervalSince1970]] forKey:@"expires"];
	NSString *filename = [NSString stringWithFormat:@"%@/%@.json", [paths objectAtIndex:0], [[NSString stringWithFormat:@"%@%@", _reqJSON, _url] md5]];
	[[d JSONRepresentation] writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

+ (void)clearCache {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSArray *cacheFiles = [NSBundle pathsForResourcesOfType:@"json" inDirectory:[paths objectAtIndex:0]];
	//NSLog(@"Cache files: %@", cacheFiles);
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString *file in cacheFiles) {
		//NSLog(@"Removing file %@", file);
		[fm removeItemAtPath:file error:nil];
	}
}

#pragma mark API call

- (void)callAPI:(NSString *)type action:(NSString *)action params:(NSDictionary *)params needAuth:(BOOL)needAuth {
	[self callAPI:type action:action params:params needAuth:needAuth canCache:YES];
}

- (void)callAPI:(NSString *)type params:(NSDictionary *)params needAuth:(BOOL)needAuth {
	[self callAPI:type action:@"" params:params needAuth:needAuth canCache:YES];
}

- (void)callAPI:(NSString *)type action:(NSString *)action params:(NSDictionary *)params needAuth:(BOOL)needAuth canCache:(BOOL)canCache {
	
//	NSMutableDictionary *reqRequest = [[NSMutableDictionary alloc] initWithCapacity:2];
	
//	if (needAuth) {
//		NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
//		NSString *user = [userPrefs stringForKey:@"username"];
//		NSString *pass = [userPrefs stringForKey:@"password"];
//		
//		if (user == nil) {
//			user = @"";
//		}
//		if (pass == nil) {
//			pass = @"";
//		}
//		
//		//NSLog(@"Type is %@, action is %@, params are %@", type, action, params);
//		
//		NSMutableDictionary *reqAuth = [[NSMutableDictionary alloc] initWithCapacity:2];
//		[reqAuth setObject:user forKey:@"user"];
//		[reqAuth setObject:[pass md5] forKey:@"pass"];
//		
//		[reqRequest setObject:reqAuth forKey:@"auth"];
//		[reqAuth    release];
//	}
	
//	NSMutableDictionary *reqAction = [[NSMutableDictionary alloc] initWithCapacity:2];
//	[reqAction setObject:action forKey:@"type"];
//	if (params != nil) {
//		[reqAction setObject:params forKey:@"data"];
//	} else {
//		[reqAction setObject:[NSNull null] forKey:@"data"];
//	}
	
//	[reqRequest setObject:reqAction forKey:@"action"];
	
//	NSMutableDictionary *reqObject = [[NSMutableDictionary alloc] initWithCapacity:1];
//	[reqObject setObject:reqRequest forKey:@"request"];
	
//	[reqRequest release];
//	[reqAction  release];
	
//	self.reqJSON = [reqObject JSONRepresentation];
	
//	[reqObject  release];
	
	//NSLog(@"JSON request is %@", reqJSON);
	
    self.url = [[NSMutableString alloc] init];
    if ([type hasPrefix:@"http"]) {
        [self.url setString:type]; // full URL supplied
    } else {
        [self.url setString:[NSString stringWithFormat:@"%@/%@", [self getApiUrl], type]];

        // Add query string parameters
        if ([self.url rangeOfString:@"?"].location == NSNotFound) {
            [self.url appendString:@"?"];
        } else {
            [self.url appendString:@"&"];
        }
        NSMutableString *resultString = [[NSMutableString alloc] init];
        for (NSString* key in [params allKeys]){
            if ([resultString length] > 0) {
                [resultString appendString:@"&"];
            }
            [resultString appendFormat:@"%@=%@", key, [params objectForKey:key]];
        }
        [self.url appendString:resultString];
    }
	
//	if ((!canCache) || (![self checkCacheForRequest:self.reqJSON toUrl:self.url ignoreExpiry:NO])) {
	
	if (canCache) {
		[self checkCacheForRequest:self.reqJSON toUrl:self.url ignoreExpiry:NO];
	}
	NSMutableURLRequest *req;
	req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:3.0f];
//	[req setHTTPBody:[self.reqJSON dataUsingEncoding:NSUTF8StringEncoding]];
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	//[req setValue:[NSString stringWithFormat:@"%@ %@ %@ %@", [UIDevice currentDevice].uniqueIdentifier, [UIDevice currentDevice].model, [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion] forHTTPHeaderField:@"X-Device-Info"];
	//[req setValue:[UIDevice currentDevice].uniqueIdentifier forHTTPHeaderField:@"X-Device-UDID"];
	[req setValue:[UIDevice currentDevice].model			forHTTPHeaderField:@"X-Device-Model"];
	[req setValue:[UIDevice currentDevice].systemName		forHTTPHeaderField:@"X-Device-SystemName"];
	[req setValue:[UIDevice currentDevice].systemVersion	forHTTPHeaderField:@"X-Device-SystemVersion"];
	[req setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]	forHTTPHeaderField:@"X-App-Version"];
	
	// Make asynchronous request (and store it in case it needs to be cancelled)
	//NSLog(@"Sending request");
	self.connection = [NSURLConnection connectionWithRequest:req delegate:self];
	[req release];
	
}

- (void)cancel {
	[self.connection cancel];
}

#pragma mark URL callback methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//NSLog(@"Connection failed");
	if (![self checkCacheForRequest:self.reqJSON toUrl:self.url ignoreExpiry:YES]) {
		[self gotError:[APIError APIErrorWithMsg:@"Network error" type:ERR_NETWORK]];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//NSLog(@"Got data...");
	[self.urlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//NSLog(@"Finished loading");
	NSString *responseString = [[NSString alloc] initWithData:self.urlData encoding:NSUTF8StringEncoding];
	
	// Reset buffer
	[self.urlData release];
	self.urlData = [[NSMutableData alloc] init];
	
	[self writeDataToCache:responseString requestJSON:self.reqJSON toUrl:self.url];
	
	[self gotResponse:responseString];
	[responseString release];

}

- (void)gotResponse:(NSString *)responseString {
	// Parse response
	//NSLog(@"Response is %@", responseString);
	SBJSON *jsonParser = [SBJSON new];
	NSObject *obj = [jsonParser objectWithString:responseString error:NULL];
	//NSLog(@"Got obj %@", obj);
	[jsonParser release];
	
	if (obj == nil) {
		if ([responseString isEqualToString:@"Invalid permissions!"]) {
			[self gotError:[APIError APIErrorWithMsg:responseString type:ERR_CREDENTIALS]];
		} else {
			[self gotError:[APIError APIErrorWithMsg:responseString type:ERR_UNKNOWN]];
		}
	} else {
		[self gotData:obj];
	}
}

#pragma mark Override these
- (void)call:(NSString *)eventType {
	[self doesNotRecognizeSelector:_cmd];
}
- (void)gotData:(NSObject *)obj {
	[self doesNotRecognizeSelector:_cmd];
}
- (void)gotError:(NSObject *)error {
	[self doesNotRecognizeSelector:_cmd];
}

@end

