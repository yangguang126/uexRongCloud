//
//  uexRCManager.h
//  EUExNIM
//
//  Created by 黄锦 on 16/3/21.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "EUExBase.h"
#import "EUtility.h"
#import "EUExRongCloud.h"
#import <RongIMLib/RongIMLib.h>

@interface uexRCManager : EUExBase<RCConnectionStatusChangeDelegate,RCIMClientReceiveMessageDelegate>

@property (nonatomic,strong) dispatch_queue_t callBackDispatchQueue;
@property (nonatomic,strong) RCIMClient *SDK;

+ (instancetype)sharedInstance;
-(void) initWithAppKey:(NSString *)appKey;
-(void)callBackJsonWithFunction:(NSString *)functionName parameter:(id)obj;


@end
