//
//  APIManager.m
//  LearnAPI
//
//  Created by Mesfin Bekele Mekonnen on 9/20/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

+ (void)GETRequestWithURL:(NSURL *)URL
       completionHandler:(void(^)(NSData * data,NSURLResponse * response, NSError * error))completionHandler{
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(data,response, error);
        });
        
    }];
    
    [task resume];
    
}
@end
