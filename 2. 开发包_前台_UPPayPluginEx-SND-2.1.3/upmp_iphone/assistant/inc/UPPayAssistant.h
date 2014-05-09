//
//  UPPayAssistant.h
//  UPPayAssistant
//
//  Created by  on 12-6-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPPayAssistant : NSObject{
    
}


/*支付信息格式如下：中间无空格符号
 
 orderInfo 格式: uppay://uppayservice/?style=original&paydata=data
 
 注意: 1、 支付信息由商户提供，写入页面。以href标签形式出现。实际使用中，浏览器不需要关心此参数的构成。
 2、 浏览器只需要将商户支付页面，以uppay://开头的href标签内容作为参数,传入接口startUnionPayWithPayData。
 orderInfo = @"uppay://uppayservice/?style=original&paydata=data";
 3、 格式错误将会提示订单信息错误.
 */


//----------------------------------------------------------------------------------------

/*商户调用此接口启用银联支付插件
 *
 *[param in] orderInfo 支付信息,参照支付信息格式;
 *[param in] scheme    回调app scheme,由app自定义
 *
 *
 *[param out] 返回NO:支付插件调用失败;
 *           返回YES:支付插件调用成功;
 */

+ (BOOL)startUnionPayWithPayData:(NSString*)orderInfo scheme:(NSString*)scheme;




/*商户调用此接口验证回调是否来自银联支付插件
 *
 *[param in] url : handleOpenURL方法中参数url
 *          
 *
 *[param out] 返回nil:非银联支付插件调用;
 *           返回非nil:resultUrl;
 */

+ (NSString*)openedByUnionPay:(NSURL*)url;




@end
