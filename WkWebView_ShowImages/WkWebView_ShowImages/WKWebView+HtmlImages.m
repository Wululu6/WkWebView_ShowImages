//
//  WKWebView+HtmlImages.m
//  NewSikaoLine
//
//  Created by DJS on 2018/4/20.
//  Copyright © 2018年 Sikaoline. All rights reserved.
//

#import "WKWebView+HtmlImages.h"
#import <objc/runtime.h>

static char imgUrlArrayKey;

@implementation WKWebView (HtmlImages)

- (void)setMethod:(NSArray *)imgUrlArray
{
    objc_setAssociatedObject(self, &imgUrlArrayKey, imgUrlArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)getImgUrlArray
{
    return objc_getAssociatedObject(self, &imgUrlArrayKey);
}

/*
 *通过js获取htlm中图片url
 */
-(NSArray *)getImageUrlByJS:(WKWebView *)wkWebView {
    //查看大图代码
    //js方法遍历图片添加点击事件返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgUrlStr='';\
    for(var i=0;i<objs.length;i++){\
    if(i==0){\
    if(objs[i].alt==''){\
    imgUrlStr=objs[i].src;\
    }\
    }else{\
    if(objs[i].alt==''){\
    imgUrlStr+='#'+objs[i].src;\
    }\
    }\
    objs[i].onclick=function(){\
    if(this.alt==''){\
    document.location=\"myweb:imageClick:\"+this.src;\
    }\
    };\
    };\
    return imgUrlStr;\
    };";
    
    //用js获取全部图片
    // function(){document.getElementsByClassName("xq_banner")[0].style.display="none";}
    [wkWebView evaluateJavaScript:jsGetImages completionHandler:^(id Result, NSError * error) {
       
    }];
    
    NSString *js2=@"getImages()";
    __block NSArray *array=[NSArray array];
    [wkWebView evaluateJavaScript:js2 completionHandler:^(id Result, NSError * error) {
       
        NSString *resurlt=[NSString stringWithFormat:@"%@",Result];
        if([resurlt hasPrefix:@"#"])
        {
            resurlt=[resurlt substringFromIndex:1];
        }
        
        array=[resurlt componentsSeparatedByString:@"#"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSString *urlString in array) {
            if ([urlString containsString:@"http://www.dujiaoshou.com/uploads"]) {
                [tempArray addObject:urlString];
            }
        }
        
        [wkWebView setMethod:[tempArray copy]];
    }];
    
    return array;
}

//显示大图
- (BOOL)showBigImage:(NSURLRequest *)request
{
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
    
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"])
    {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        NSLog(@"image url------%@", imageUrl);
        
        NSArray *imgUrlArr=[self getImgUrlArray];
        NSInteger index=0;
        for (NSInteger i=0; i<[imgUrlArr count]; i++) {
            if([imageUrl isEqualToString:imgUrlArr[i]])
            {
                index=i;
                break;
            }
        }
        
//        [WFImageUtil showImgWithImageURLArray:[NSMutableArrayarrayWithArray:imgUrlArr] index:index myDelegate:nil];
        
        return NO;
    }
    return YES;
}



@end
