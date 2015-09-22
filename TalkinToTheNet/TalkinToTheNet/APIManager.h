//
//  APIManager.h
//  LearnAPI
//
//  Created by Mesfin Bekele Mekonnen on 9/20/15.
//  Copyright © 2015 Mesfin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject

+ (void)GETRequestWithURL:(NSURL *)URL
        completionHandler:(void(^)(NSData * data,NSURLResponse * response, NSError * error))completionHandler;

@end
