//
//  ViewController.m
//  WeiChatVerification
//
//  Created by jiawang on 2020/8/10.
//  Copyright © 2020 jiawang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#define kMainScreenWidth        [[UIScreen mainScreen] bounds].size.width
#define kMainScreenHeight       [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property(nonatomic,strong)WKWebView *webView;
@property(nonatomic,copy)NSString *ticket;
@property(nonatomic,copy)NSString *randstr;
@property(nonatomic,strong)UIControl* backgroundView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * verificationBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 200, kMainScreenWidth - 80, 50)];
    [verificationBtn setTitle:@"点击验证" forState:UIControlStateNormal];
    [verificationBtn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:verificationBtn];
    [verificationBtn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundView = [[UIControl alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4F];
    self.backgroundView.userInteractionEnabled = YES;
    // Do any additional setup after loading the view.
}
#pragma mark - WKScriptMessageHandler  js交互
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"verificationClick"]) {
        NSLog(@"**************%@",message.body);
        if([[message.body objectForKey:@"ret"] intValue]==0){
            self.ticket = [message.body objectForKey:@"ticket"];
            self.randstr = [message.body objectForKey:@"randstr"];
            /*
              这里面得到回调获取所需要的参数以后，可以进行接下来的操作，调用后台的接口获取验证码。
            
             */
        }else{
            [[[UIAlertView alloc] initWithTitle:@"验证失败" message:@"验证码校验失败,请重新尝试" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
        }
        [self.backgroundView removeFromSuperview];
    }
}

-(void)clickBtn{
    [self.view addSubview:self.backgroundView];
    [self.webView removeFromSuperview];
    self.webView = nil;
    //创建网页配置对象
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
    config.allowsInlineMediaPlayback = YES;
    //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
    config.mediaTypesRequiringUserActionForPlayback = YES;
    //设置是否允许画中画技术 在特定设备上有效
    config.allowsPictureInPictureMediaPlayback = YES;
    //设置请求的User-Agent信息中应用程序名称 iOS9后可用
    config.applicationNameForUserAgent = @"ChinaDailyForiPad";
    //通过JS与webView内容交互
    config.userContentController = [WKUserContentController new];
    //注册一个name为verificationClick的js方法 设置处理接收JS方法的对象
    [config.userContentController addScriptMessageHandler:self name:@"verificationClick"];

    // 创建设置对象
    WKPreferences *preference = [[WKPreferences alloc]init];
    //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
    preference.minimumFontSize = 0;
    //设置是否支持javaScript 默认是支持的
    preference.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preference;


    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake((kMainScreenWidth * 0.3)/2, 60 , kMainScreenWidth * 0.7, kMainScreenWidth * 0.7) configuration:config];
    self.webView.backgroundColor = [UIColor clearColor];
    // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
    self.webView.allowsBackForwardNavigationGestures = YES;
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        // Fallback on earlier versions
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // UI代理
    self.webView.UIDelegate = self;
    // 导航代理
    self.webView.navigationDelegate = self;
    [self.backgroundView addSubview:self.webView];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"VerificationCode" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

@end
