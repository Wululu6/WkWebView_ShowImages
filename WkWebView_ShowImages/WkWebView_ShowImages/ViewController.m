//
//  ViewController.m
//  WkWebView_ShowImages
//
//  Created by apple on 2018/11/15.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebView+HtmlImages.h"
// 图片浏览器
#import "SDPhotoBrowser.h"
#import "NSString+ThreeDES.h"
#import "Masonry/Masonry.h"

// 屏幕高度
#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height
// 屏幕宽度
#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,SDPhotoBrowserDelegate>


@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) UIProgressView *progress;

@property (nonatomic, strong) NSMutableArray *imagesArr;
@property (nonatomic, strong) NSString *loadUrl;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    
    WKPreferences *preferences = [WKPreferences new];
    configuration.preferences = preferences;
    configuration.preferences.javaScriptEnabled = YES;
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;

    
    NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
    [userDic setObject:@"27" forKey:@"wid"];
    [userDic setObject:@"123456" forKey:@"username"];
    
    // 分享的url

    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:userDic options:0 error:nil];
    NSString *jsonStr = [[NSString alloc]initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    NSString *encryptionStr = [NSString encrypt:jsonStr];
    // 初始化loadUrl已加密
    self.loadUrl = [NSString stringWithFormat:@"http://www.dujiaoshou.com/zhuanlan/templets/tel_new.html?wid=%@",encryptionStr];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
    self.wkWebView = webView;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.loadUrl]]];
    [self.view addSubview:webView];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    self.view.backgroundColor = [UIColor redColor];
    if (@available(iOS 11.0, *)) {
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            
        }];
    } else {
        [webView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(49);
            
        }];
    }
    
    //TODO:kvo监听，获得页面title和加载进度值
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];

}


#pragma mark 加载进度条
- (UIProgressView *)progress {
    
    if (_progress == nil) {
        if (SCREEN_HEIGHT == 812) {
            _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 88, SCREEN_WIDTH, 2)];
        } else {
            _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 2)];
        }
        _progress.tintColor = [UIColor  redColor];
        _progress.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_progress];
    }
    return _progress;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    //前缀
    NSString *path = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
    if ([scheme isEqualToString:@"dujiaoshou"]) {
        
//        [self handleCustomAction:URL];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([scheme isEqualToString:@"myweb"]){
        
        if ([path hasPrefix:@"myweb:imageClick:"]){
            NSString *imageUrl = [path substringFromIndex:@"myweb:imageClick:".length];
            NSLog(@"image url------%@", imageUrl);
            
            NSArray *imgUrlArr=[self.wkWebView getImgUrlArray];
            if (imgUrlArr.count == 0) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                [tempArray addObject:imageUrl];
                imgUrlArr = [tempArray copy];
            }
            NSInteger index=0;
            for (NSInteger i=0; i<[imgUrlArr count]; i++) {
                if([imageUrl isEqualToString:imgUrlArr[i]]) {
                    index=i;
                    
                    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
                    browser.sourceImagesContainerView = self.view; // 原图的父控件
                    browser.imageCount = imgUrlArr.count; // 图片总数
                    browser.currentImageIndex = index;
                    
                    browser.delegate = self;
                    [browser show];
                    
                    break;
                }
            }
            
        }
        
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - photobrowser代理方法
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    
    return [[UIImage alloc] init];
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    //bmiddle//thumbnail
    
    NSArray *imgUrlArr=[self.wkWebView getImgUrlArray];
    NSString *urlStr = [imgUrlArr objectAtIndex:index];
    
    //    NSString *urlStr = [[self.photoItemArray[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
    
}

//在收到响应后，决定是否跳转（同上）
//该方法执行在内容返回之前
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    NSLog(@"在收到响应后，决定是否跳转。 3");
    
}

//接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    //    NSLog(@"接收到服务器跳转请求之后调用");
    
}

-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    //    NSLog(@"webViewWebContentProcessDidTerminate");
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    //通过js获取htlm中图片url
    [self.wkWebView getImageUrlByJS:webView];
    
}


// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"error2:%@",error);
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.wkWebView) {
            [self.progress setAlpha:1.0f];
            [self.progress setProgress:self.wkWebView.estimatedProgress animated:YES];
            if(self.wkWebView.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.5f
                                      delay:0.3f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.progress setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [self.progress setProgress:0.0f animated:NO];
                                 }];
            }
        }
        else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //网页title
    else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.wkWebView) {
            self.title = self.wkWebView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
