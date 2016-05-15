//
//  NetManager.h
//  VKNewsViewer
//
//  Created by Daniil Novoselov on 13.05.16.
//  Copyright © 2016 Daniil Novoselov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetManager : NSObject

@property (strong, readonly) AFHTTPRequestOperationManager *operationManager;


+ (instancetype)sharedManager;

#pragma marl - VK API methods
- (AFHTTPRequestOperation *)getNewsItemsNext:(BOOL)next andSuccess:(void (^)(NSArray *items))success failed:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failed;

#pragma mark - Authorization
- (NSString *)accessToken;
- (void)saveAccessToken:(NSString *)accessToken;

- (BOOL)isAuthorized;
- (void)deauthorize;

- (NSURL *)getAuthorizationURL;


@end
