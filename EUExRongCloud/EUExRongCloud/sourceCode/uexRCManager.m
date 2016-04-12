//
//  uexRCManager.m
//  EUExNIM
//
//  Created by 黄锦 on 16/3/21.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import "uexRCManager.h"


@implementation uexRCManager

+(instancetype)sharedInstance{
    static dispatch_once_t pred = 0;
    __strong static uexRCManager *sharedObject = nil;
    dispatch_once(&pred, ^{
        sharedObject = [[self alloc] init];
        
        
    });
    return sharedObject;
}
-(instancetype)init{
    self=[super init];
    if(self){
        self.callBackDispatchQueue=dispatch_queue_create("gcd.uexRongCloudCallBackDispatchQueue",NULL);
    }
    return self;
}
#pragma mark -registerApp
-(void) initWithAppKey:(NSString *)appKey{
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    if([appKey length]){
            _SDK=[RCIMClient sharedRCIMClient];
            [_SDK initWithAppKey:appKey];
            [self addDelegate];
            result[@"result"] = @(YES);
    }
    else{
        result[@"result"] =@(NO);
        [result setValue:@(1) forKey:@"error"];
    }
    
    [self callBackJsonWithFunction:@"cbInit" parameter:result];
}
-(void)addDelegate{
    [_SDK setRCConnectionStatusChangeDelegate:self];
    [_SDK setReceiveMessageDelegate:self object:nil];
}

#pragma mark -2.登陆与登出
- (void)onConnectionStatusChanged:(RCConnectionStatus)status{
    [self callBackJsonWithFunction:@"onConnectionStatusChanged" parameter:@{@"status":@(status)}];
}

#pragma mark -3.基础消息
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object{
    NSLog(@"消息接收成功 ! ");
    RCMessageContent *con  = message.content;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    result[@"conversationType"] = [self convertFromInteger:message.conversationType];
    result[@"messageDirection"] = [self convertFromDrection:message.messageDirection];
    result[@"targetId"] = message.targetId;
    result[@"objectName"] = message.objectName;
    result[@"sentStatus"] = @(message.sentStatus);
    result[@"senderUserId"] = message.senderUserId;
    result[@" messageId"] =@(message.messageId);
    result[@"sentTime"] = @(message.sentTime);
    result[@"receivedTime"] = @(message.receivedTime);
    if ([con isKindOfClass:[RCTextMessage class]]) {//文字消息
        RCTextMessage *mes = (RCTextMessage*)con;
        content[@"text"] = mes.content;
        content[@"extra"] = mes.extra;
    }
    if ([con isKindOfClass:[RCVoiceMessage class]]) {//语音消息
        RCVoiceMessage *mes = (RCVoiceMessage*)con;
        content[@"duration"] = @(mes.duration);
        content[@"extra"] = mes.extra;
        NSString *voicePath = [self saveMessageDataToLocalPath:mes.wavAudioData];
        content[@"voicePath"] = voicePath;
    }
    if ([con isKindOfClass:[RCImageMessage class]]) {//图片消息
        RCImageMessage *mes = (RCImageMessage*)con;
        content[@"imgPath"] = mes.imageUrl;
        content[@"thumbPath"] = [self saveImage:mes.thumbnailImage quality:0.8 usePng:YES];
        content[@"extra"] = mes.extra;

    }
    if ([con isKindOfClass:[RCRichContentMessage class]]) {//图文消息
        RCRichContentMessage *mes = (RCRichContentMessage*)con;
        content[@"title"] = mes.title;
        content[@"description"] = mes.digest;
        content[@"imgPath"] = mes.imageURL;
        content[@"url"] = mes.url;
        content[@"extra"] = mes.extra;
        
        
    }
    if ([con isKindOfClass:[RCLocationMessage class]]) {//位置消息
        RCLocationMessage *mes = (RCLocationMessage*)con;
        content[@"latitude"] = @(mes.location.latitude);
        content[@"longitude"] = @(mes.location.longitude);
        content[@"poi"] = mes.locationName;
        content[@"imgPath"] = [self saveImage:mes.thumbnailImage quality:0.8 usePng:YES];
        content[@"extra"] = mes.extra;
    }
    if ([con isKindOfClass:[RCCommandMessage class]]) {//命令消息
       RCCommandMessage *mes = (RCCommandMessage*)con;
        content[@"name"] = mes.name;
        content[@"data"] = mes.data;
    }
    result[@"content"] = content;
    dic[@"message"] = result;
    dic[@"left"] = @(nLeft);
    [self callBackJsonWithFunction:@"onMessageReceived" parameter:dic];
}





#pragma mark - CallBack Method
const static NSString *kPluginName=@"uexRongCloud";
-(void)callBackJsonWithFunction:(NSString *)functionName parameter:(id)obj{
    NSString *jsonStr = [NSString stringWithFormat:@"if(%@.%@ != null){%@.%@(%@);}",kPluginName,functionName,kPluginName,functionName,[obj JSONFragment]];
    dispatch_async(self.callBackDispatchQueue, ^(void){
        [EUtility evaluatingJavaScriptInRootWnd:jsonStr];
    });
    
}
-(NSString*)convertFromInteger:(NSInteger)integer{
    if (integer == 1) {//私聊
        return @"PRIVATE";
    }
    if (integer == 2) {//讨论组
        return @"DISCUSSION";
    }
    if (integer == 3) {//群组
        return @"GROUP";
    }
    if (integer == 4) {
        return @"CHATROOM";//聊天室
    }
    if (integer == 5) {//客服
        return @"CUSTOMER_SERVICE";
    }
    if (integer == 6) {//系统
        return @"SYSTEM";
    }
    return @"";
}
-(NSString*)convertFromDrection:(NSInteger)integer{
    if (integer == 1) {//发送
        return @"SEND";
    }
    if (integer == 2) {//接收
        return @"RECEIVE";
    }
        return @"";
}
//图片\音频的保存路径
- (NSString *)getSaveDirPath{
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    NSString *wgtTempPath=[tempPath stringByAppendingPathComponent:[EUtility brwViewWidgetId:self.meBrwView]];
    
    return [wgtTempPath stringByAppendingPathComponent:@"uexRongCloud"];
}
-(NSString *) saveMessageDataToLocalPath:(NSData *)messageData
{
    
    if (!messageData) {
        return nil;
    }
    NSFileManager *fmanager = [NSFileManager defaultManager];
    NSString *uexImageSaveDir=[self getSaveDirPath];
    if (![fmanager fileExistsAtPath:uexImageSaveDir]) {
        [fmanager createDirectoryAtPath:uexImageSaveDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *timeStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
    
    NSString *imgName = [NSString stringWithFormat:@"%@.%@",[timeStr substringFromIndex:([timeStr length]-6)],@"wav"];
    NSString *imgTmpPath = [uexImageSaveDir stringByAppendingPathComponent:imgName];
    if ([fmanager fileExistsAtPath:imgTmpPath]) {
        [fmanager removeItemAtPath:imgTmpPath error:nil];
    }
    if([messageData writeToFile:imgTmpPath atomically:YES]){
        return imgTmpPath;
    }else{
        return nil;
    }
    
    
}

- (NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality usePng:(BOOL)usePng{
    NSData *imageData;
    NSString *imageSuffix;
    
    
    if(usePng){
        imageData=UIImagePNGRepresentation(image);
        imageSuffix=@"png";
    }else{
        imageData=UIImageJPEGRepresentation(image, quality);
        imageSuffix=@"jpg";
    }
    
    
    if(!imageData) return nil;
    
    NSFileManager *fmanager = [NSFileManager defaultManager];
    
    NSString *uexImageSaveDir=[self getSaveDirPath];
    if (![fmanager fileExistsAtPath:uexImageSaveDir]) {
        [fmanager createDirectoryAtPath:uexImageSaveDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *timeStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
    
    NSString *imgName = [NSString stringWithFormat:@"%@.%@",[timeStr substringFromIndex:([timeStr length]-6)],imageSuffix];
    NSString *imgTmpPath = [uexImageSaveDir stringByAppendingPathComponent:imgName];
    if ([fmanager fileExistsAtPath:imgTmpPath]) {
        [fmanager removeItemAtPath:imgTmpPath error:nil];
    }
    if([imageData writeToFile:imgTmpPath atomically:YES]){
        return imgTmpPath;
    }else{
        return nil;
    }
    
}

@end
