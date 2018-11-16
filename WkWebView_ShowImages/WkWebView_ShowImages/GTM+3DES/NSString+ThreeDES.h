//
//  NSString+ThreeDES.h
//  3DE
//
//  Created by Brandon Zhu on 31/10/2012.
//  Copyright (c) 2012 Brandon Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ThreeDES)
//加密
+ (NSString *)encrypt:(NSString*)plainText;
//解密
+ (NSString*)decrypt:(NSString *)encryptText;

+ (NSData *)xxencrypt:(NSString*)plainText;

+ (NSData *)dataFromHexString:(NSString *)hexString;

@end
