//
//  NetManager.m
//  VKNewsViewer
//
//  Created by Daniil Novoselov on 13.05.16.
//  Copyright © 2016 Daniil Novoselov. All rights reserved.
//

#import "NetManager.h"

#define BASE_API_URL_STRING @"https://api.vk.com/method/"
@interface NetManager()
@property (strong, nonatomic) NSString *next_from;
@end

@implementation NetManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (AFHTTPRequestOperationManager *)operationManager {
    static dispatch_once_t once;
    static AFHTTPRequestOperationManager *manager;
    dispatch_once(&once, ^{
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_API_URL_STRING]];
        manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    });
    return manager;
}

#pragma mark - VK API methods
- (AFHTTPRequestOperation *)getNewsItemsNext:(BOOL)next
                                  andSuccess:(void (^)(NSArray *items))success
                                      failed:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failed {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] forKey:@"access_token"];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [parameters setObject:@"post" forKey:@"filters"];
    [parameters setObject:@"30" forKey:@"count"];
    if (next && self.next_from) {
        [parameters setObject:self.next_from forKey:@"start_from"];
    }
    
    AFHTTPRequestOperation *operation = [self.operationManager GET:@"newsfeed.get" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"response object: %@", responseObject);
        NSDictionary *responseDict = [responseObject objectForKey:@"response"];
        NSLog(@"responseDict: %@", [responseDict allKeys]);
        NSArray *items = [responseDict objectForKey:@"items"];
        success(items);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"newsfeed.get request error: %@", error);
        failed(operation, error);
    }];
    NSLog(@"returning... %@", operation.request.URL);
    return operation;
}
#pragma mark - Authorization
- (NSString *)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
}
- (void)saveAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)isAuthorized {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]? YES : NO;
}
- (void)deauthorize {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSURL *)getAuthorizationURL {
    NSString *urlString = [NSString stringWithFormat:@"https://oauth.vk.com/authorize?"
                           "client_id=%@&"
                           "display=touch&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "scope=friends,wall,offline&"
                           "response_type=token&"
                           "v=5.52", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"VkApplicationId"]];
    return [NSURL URLWithString:urlString];
}


@end
