//
//  WKWebView+HtmlImages.h
//  NewSikaoLine
//
//  Created by DJS on 2018/4/20.
//  Copyright © 2018年 Sikaoline. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (HtmlImages)

- (NSArray *)getImageUrlByJS:(WKWebView *)wkWebView;

- (BOOL)showBigImage:(NSURLRequest *)request;

- (NSArray *)getImgUrlArray;

@end
