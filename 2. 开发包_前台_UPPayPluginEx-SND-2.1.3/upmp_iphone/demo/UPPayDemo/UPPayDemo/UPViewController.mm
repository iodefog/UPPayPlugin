//
//  UPViewController.m
//  UPPayDemo
//
//  Created by liwang on 12-11-12.
//  Copyright (c) 2012年 liwang. All rights reserved.
//
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "UPViewController.h"
#import "UPPayPlugin.h"

#define KBtn_width        200
#define KBtn_height       80
#define KXOffSet          (self.view.frame.size.width - KBtn_width) / 2
#define KYOffSet          80

#define kVCTitle          @"TN测试"
#define kBtnFirstTitle    @"获取订单，开始测试"
#define kWaiting          @"正在获取TN,请稍后..."
#define kNote             @"提示"         
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"


#define kMode             @"01"
#define kConfigTnUrl      @"http://222.66.233.198:8080/sim/app.jsp?user=%@"
#define kNormalTnUrl      @"http://222.66.233.198:8080/sim/gettn"
//120.204.69.167:10306
//222.66.233.198:8080
//172.17.254.198:10306

@interface UPViewController ()

@end

@implementation UPViewController
@synthesize mode;
@synthesize tnURL;
@synthesize configURL;


- (void)dealloc
{
    self.mode = nil;
    self.tnURL = nil;
    self.configURL = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [self titleView];
    self.title = kVCTitle;
    self.mode = @"01";
    self.tnURL = @"http://222.66.233.198:8080/sim/gettn";
    self.configURL = @"http://222.66.233.198:8080/sim/app.jsp?user=123456789";
	// Do any additional setup after loading the view, typically from a nib.
    
    // Add the normalTn button
    CGFloat y = KYOffSet;
    UIButton* btnStartPay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnStartPay setTitle:kBtnFirstTitle forState:UIControlStateNormal];
    [btnStartPay addTarget:self action:@selector(normalPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnStartPay setFrame:CGRectMake(KXOffSet, y, KBtn_width, KBtn_height)];
    
    [self.view addSubview:btnStartPay];
    y += KBtn_height + KYOffSet;
    
    // Add the configTn button
    
    UIButton* btnConfig = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnConfig setTitle:@"配置自定义用户：123456789" forState:UIControlStateNormal];
    [btnConfig addTarget:self action:@selector(userPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnConfig setFrame:CGRectMake(KXOffSet, y, KBtn_width, KBtn_height)];
    [self.view addSubview:btnConfig];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alert

- (void)showAlertWait
{
    mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(mAlert.frame.size.width / 2.0f - 15, mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [mAlert addSubview:aiv];
    [aiv release];
    [mAlert release];
}

- (void)showAlertMessage:(NSString*)msg
{
    mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:nil cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [mAlert show];
    [mAlert release];
}
- (void)hideAlert
{
    if (mAlert != nil)
    {
        [mAlert dismissWithClickedButtonIndex:0 animated:YES];
        mAlert = nil;
    }
}

#pragma mark - UPPayPlugin Test


- (void)userPayAction:(id)sender
{
    if (![self.mode isEqualToString:@"00"])
    {
    NSURL* url = [NSURL URLWithString:self.configURL];
	NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
    [self showAlertWait];
    }
}


- (void)normalPayAction:(id)sender
{
    if ([self.mode isEqualToString:@"00"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"重要提示" message:@"您现在即将进行的是一笔真实的消费,消费金额0.01元,点击确定开始支付." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }
    else
    {
        NSURL* url = [NSURL URLWithString:self.tnURL];
        NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
        NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        [urlConn start];
        [self showAlertWait];
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    int code = [rsp statusCode];
    if (code != 200)
    {
        [self hideAlert];
        [self showAlertMessage:kErrorNet];
        [connection cancel];
        [connection release];
        connection = nil;
    }
    else
    {
        if (mData != nil)
        {
            [mData release];
            mData = nil;
        }
        mData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideAlert];
    NSString* tn = [[NSMutableString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
    if (tn != nil && tn.length > 0)
    {
        NSLog(@"tn=%@",tn);
        [UPPayPlugin startPay:tn mode:self.mode viewController:self delegate:self];
    }
    [tn release];
    [connection release];
    connection = nil;
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self hideAlert];
    [self showAlertMessage:kErrorNet];
    [connection release];
    connection = nil;
}





- (void)UPPayPluginResult:(NSString *)result
{
    NSString* msg = [NSString stringWithFormat:kResult, result];
    [self showAlertMessage:msg];
}


- (UIView *)titleView
{
    CGRect frame = CGRectMake(0, 0, 200, 44);
    NSArray *items = [NSArray arrayWithObjects:@"开发", @"测试", @"生产", nil];
    UISegmentedControl *titleView = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
    [titleView setFrame:frame];
    titleView.segmentedControlStyle = UISegmentedControlStyleBar;
    [titleView setSelectedSegmentIndex:0];
    [titleView addTarget:self action:@selector(segmanetDidSelected:) forControlEvents:UIControlEventValueChanged];
    return titleView;
}

- (void)segmanetDidSelected:(UISegmentedControl *)segment
{
    // development
    if (segment.selectedSegmentIndex == 0) {
        self.mode = @"01";
        self.tnURL = @"http://222.66.233.198:8080/sim/gettn";
        self.configURL = @"http://222.66.233.198:8080/sim/app.jsp?user=123456789";
    }
    
    // testment
    if (segment.selectedSegmentIndex == 1) {
        self.mode = @"02";
        self.tnURL = @"http://120.204.69.167:10306/sim/gettn";
        self.configURL = @"http://120.204.69.167:10306/sim/app.jsp?user=123456789";
    }
    
    // productment
    if (segment.selectedSegmentIndex == 2) {
        self.mode = @"00";
        self.tnURL = @"https://202.96.255.146/sim/gettn";
        self.configURL = @"";
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL* url = [NSURL URLWithString:self.tnURL];
        NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
        NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        [urlConn start];
        [self showAlertWait];
    }
}

@end
