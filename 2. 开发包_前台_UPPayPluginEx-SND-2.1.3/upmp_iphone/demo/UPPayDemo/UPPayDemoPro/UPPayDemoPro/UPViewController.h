//
//  UPViewController.h
//  UPPayDemo
//
//  Created by liwang on 12-11-12.
//  Copyright (c) 2012年 liwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPPayPluginDelegate.h"


@interface UPViewController : UIViewController<UPPayPluginDelegate, UIAlertViewDelegate>
{
    UIAlertView* mAlert;
    NSMutableData* mData;
}

@property(nonatomic, retain)NSString *mode;
@property(nonatomic, retain)NSString *tnURL;
@property(nonatomic, retain)NSString *configURL;

- (void)showAlertWait;
- (void)showAlertMessage:(NSString*)msg;
- (void)hideAlert;

- (UIView *)titleView;

- (void)segmanetDidSelected:(UISegmentedControl *)segment;


@end
