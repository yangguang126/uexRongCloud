//
//  EUExRongCloud.m
//  EUExRongCloud
//
//  Created by 黄锦 on 16/3/22.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import "EUExRongCloud.h"
#import "uexRCManager.h"
#import "EUtility.h"

@interface EUExRongCloud()

@property(nonatomic ,strong) uexRCManager *RCManager;

@end

@implementation EUExRongCloud

-(id)initWithBrwView:(EBrowserView *) eInBrwView {
    self = [super initWithBrwView:eInBrwView];
    if (self) {
        self.RCManager=[uexRCManager sharedInstance];

    }
    return self;
}

#pragma mark -1.registerApp
-(void) init:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    [self.RCManager initWithAppKey:[info objectForKey:@"appKey"]];
}

#pragma mark -2.登陆与登出
-(void) connect:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK connectWithToken:[info objectForKey:@"token"] success:^(NSString *userId) {
        result[@"userId"] = userId;
        result[@"resultCode"] = @(0);
        [self.RCManager callBackJsonWithFunction:@"cbConnect" parameter:result];
    } error:^(RCConnectErrorCode status) {
        result[@"resultCode"] = @(status);
        [self.RCManager callBackJsonWithFunction:@"cbConnect" parameter:result];
    } tokenIncorrect:^{
        NSLog(@"connect---tokenIncorrect");
        result[@"resultCode"] = @(31004);//@(31005);
        [self.RCManager callBackJsonWithFunction:@"cbConnect" parameter:result];
    }];
}
-(void) disconnect:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    [self.RCManager.SDK disconnect:[[info objectForKey:@"isReceivePush"] boolValue]];
}


#pragma mark -3 消息发送
-(void) sendMessage:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *objectName = [info objectForKey:@"objectName"];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSString *targetId = [info objectForKey:@"targetId"];
    NSString *extra=[info objectForKey:@"extra"];
    long localId = [[info objectForKey:@"localId"] longValue];
    if (type == 0) {
        return;
    }
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    if ([objectName isEqualToString:RCTextMessageTypeIdentifier]) {//文字消息,@"RC:TxtMsg"
        NSString *content = [info objectForKey:@"text"];
        RCTextMessage *message=[RCTextMessage messageWithContent:content];
        message.extra = extra;
        
      RCMessage *mes = [self.RCManager.SDK sendMessage:type targetId:targetId content:message pushContent:nil pushData:nil success:^(long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(1);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(2);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }];
        if (mes) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(mes.messageId);
            result[@"resultCode"]=@(0);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }

    }
    if ([objectName isEqualToString:RCVoiceMessageTypeIdentifier]) {//语音消息,@"RC:VcMsg"
        NSData *data = [NSData dataWithContentsOfFile:[self absPath:[info objectForKey:@"voicePath"]] ];
        RCVoiceMessage *message = [RCVoiceMessage messageWithAudio:data duration:[[info objectForKey:@"duration"] longValue]];
        message.extra = extra;
       RCMessage *mes = [self.RCManager.SDK sendMessage:type targetId:targetId content:message pushContent:nil pushData:nil success:^(long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(1);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(2);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }];
        if (mes) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(mes.messageId);
            result[@"resultCode"]=@(0);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }
        
    }
    if ([objectName isEqualToString:RCImageMessageTypeIdentifier]) {//图片消息,@"RC:ImgMsg"
        RCImageMessage *message=[RCImageMessage messageWithImageURI:[self absPath:[info objectForKey:@"imgPath"]]];
        message.extra = extra;
       RCMessage *mes = [self.RCManager.SDK sendImageMessage:type targetId:targetId content:message pushContent:nil pushData:nil progress:^(int progress, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(3);
            result[@"progress"] = @(progress);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        } success:^(long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(1);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        } error:^(RCErrorCode errorCode, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(2);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }];
        if (mes) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(mes.messageId);
            result[@"resultCode"]=@(0);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }

    }
    if ([objectName isEqualToString:RCRichContentMessageTypeIdentifier]) {//图文消息,@"RC:ImgTextMsg"
        RCRichContentMessage *message = [RCRichContentMessage messageWithTitle:[info objectForKey:@"title"] digest:[info objectForKey:@"description"] imageURL:[info objectForKey:@"imgUrl"] url:[info objectForKey:@"url"] extra:[info objectForKey:@"extra"]];
      RCMessage *mes =  [self.RCManager.SDK sendMessage:type targetId:targetId content:message pushContent:nil pushData:nil success:^(long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(1);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(2);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }];
        if (mes) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(mes.messageId);
            result[@"resultCode"]=@(0);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }
        
    }
    if ([objectName isEqualToString:RCLocationMessageTypeIdentifier]) {//位置消息,@"RC:LBSMsg"
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[info objectForKey:@"latitude"] doubleValue], [[info objectForKey:@"latitude"] doubleValue]);
        UIImage *image =[UIImage imageWithContentsOfFile:[self absPath:[info objectForKey:@"imgPath"]]];
        RCLocationMessage *message = [RCLocationMessage messageWithLocationImage:image location:location locationName:[info objectForKey:@"poi"]];
      RCMessage *mes =  [self.RCManager.SDK sendMessage:type targetId:[info objectForKey:@"targetId"] content:message pushContent:nil pushData:nil success:^(long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(1);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];

        } error:^(RCErrorCode nErrorCode, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(2);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];

        }];
        if (mes) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(mes.messageId);
            result[@"resultCode"]=@(0);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }

        
    }
    if ([objectName isEqualToString:RCCommandMessageIdentifier]) {//命令消息,@"RC:CmdNtf"
        RCCommandMessage *message = [RCCommandMessage messageWithName:[info objectForKey:@"name"] data:[info objectForKey:@"data"]] ;
       RCMessage *mes = [self.RCManager.SDK sendMessage:type targetId:targetId content:message pushContent:nil pushData:nil success:^(long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(1);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(messageId);
            result[@"resultCode"]=@(2);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }];
        if (mes) {
            result[@"localId"] = @(localId);
            result[@"messageId"] = @(mes.messageId);
            result[@"resultCode"]=@(0);
            [self.RCManager callBackJsonWithFunction:@"cbSendMessage" parameter:result];
        }
    }
    
    
}
-(NSString *)getConversationList:(NSMutableArray *)inArguments{
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSArray *conversationList = @[@(ConversationType_PRIVATE),
                                                       @(ConversationType_DISCUSSION),
                                                       @(ConversationType_GROUP),
                                                       @(ConversationType_SYSTEM),
                                                       @(ConversationType_APPSERVICE),
                                                       @(ConversationType_PUBLICSERVICE)];
    if ([self.RCManager.SDK respondsToSelector:@selector(getConversationList:)]) {
        NSArray *conversations = [self.RCManager.SDK getConversationList:conversationList];
        NSMutableArray *arr = [NSMutableArray array];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (RCConversation *conversation in conversations) {
            dic[@"conversationTitle"] = conversation.conversationTitle?:@"'";
            dic[@"conversationType"] = [self convertFromInteger:conversation.conversationType];
            dic[@"draft"] = conversation.draft?:@"";
            dic[@"targetId"] = conversation.targetId?:@"";
            dic[@"portraitUrl"] = conversation.lastestMessage.senderUserInfo.portraitUri?:@"";
            dic[@"sentStatus"] = [self sentStatusConvertFromInteger:conversation.sentStatus];
            dic[@"objectName"] = conversation.objectName;
            dic[@"receivedStatus"] = [self receivedStatusConvertFromInteger:conversation.receivedStatus];
            dic[@"senderUserId"] = conversation.senderUserId;
            dic[@"unreadMessageCount"] = @(conversation.unreadMessageCount);
            dic[@"receivedTime"] = @(conversation.receivedTime);
            dic[@"sentTime"] = @(conversation.sentTime);
            dic[@"isTop"] = @(conversation.isTop);
            dic[@"latestMessageId"] = @(conversation.lastestMessageId);
             NSMutableDictionary *content = [NSMutableDictionary dictionary];
            RCMessageContent *con = conversation.lastestMessage;
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
            dic[@"lastestMessage"] = content;
            [arr addObject:dic];
        }
        [result setValue:@(0) forKey:@"resultCode"];
        [result setValue:arr forKey:@"conversations"];
        NSLog(@"result:%@",result);
        return [result JSONFragment] ;
    }else{
        [result setValue:@(1) forKey:@"resultCode"];
        return [result JSONFragment];
    }
    
}
-(NSString*)getConversation:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return nil;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    if (type == 0) {
        return @"";
    }
     if ([self.RCManager.SDK respondsToSelector:@selector(getConversation:targetId:)]) {
         RCConversation *conversation = [self.RCManager.SDK getConversation:type targetId:[info objectForKey:@"targetId"]];
         dic[@"resultCode"] = @(0);
         dic[@"conversationTitle"] = conversation.conversationTitle;
         dic[@"conversationType"] =[self convertFromInteger:conversation.conversationType];
         dic[@"draft"] = conversation.draft;
         dic[@"portraitUrl"] = conversation.lastestMessage.senderUserInfo.portraitUri?:@"";
         dic[@"targetId"] = conversation.targetId?:@"";
         if ([conversation.lastestMessage isKindOfClass:[RCTextMessage class]]) {//文字消息
             RCTextMessage* mes = (RCTextMessage*)conversation.lastestMessage;
             dic1[@"content"] = mes.content;
             dic1[@"extra"] = mes.extra;
         }
         if ([conversation.lastestMessage isKindOfClass:[RCVoiceMessage class]]) {//语音消息
             RCVoiceMessage* mes = (RCVoiceMessage*)conversation.lastestMessage;
             dic1[@"duration"] = @(mes.duration);
             dic1[@"extra"] = mes.extra;
             NSString *voicePath = [self saveMessageDataToLocalPath:mes.wavAudioData];
             dic1[@"voicePath"] = voicePath;
         }
         if ([conversation.lastestMessage isKindOfClass:[RCImageMessage class]]) {//图片消息
             RCImageMessage *mes = (RCImageMessage*)conversation.lastestMessage;
             dic1[@"imgPath"] = mes.imageUrl;
             dic1[@"thumbPath"] = [self saveImage:mes.thumbnailImage quality:0.8 usePng:YES];
             dic1[@"extra"] = mes.extra;
         }
         if ([conversation.lastestMessage isKindOfClass:[RCRichContentMessage class]]) {//图文消息
             RCRichContentMessage *mes = (RCRichContentMessage*)conversation.lastestMessage;
             dic1[@" title"] = mes.title;
             dic1[@"description"] = mes.digest;
             dic1[@"imgPath"] = mes.imageURL;
             dic1[@"url"] = mes.url;
             dic1[@"extra"] = mes.extra;
         }
         if ([conversation.lastestMessage isKindOfClass:[RCLocationMessage class]]) {//位置消息
             RCLocationMessage *mes = (RCLocationMessage*)conversation.lastestMessage;
             dic1[@"latitude"] = @(mes.location.latitude);
             dic1[@"longitude"] = @(mes.location.longitude);
             dic1[@"poi"] = mes.locationName;
             dic1[@"imgPath"] = [self saveImage:mes.thumbnailImage quality:0.8 usePng:YES];
             dic1[@"extra"] = mes.extra;
         }
         if ([conversation.lastestMessage isKindOfClass:[RCCommandMessage class]]) {////命令消息
             RCCommandMessage *mes = (RCCommandMessage*)conversation.lastestMessage;
             dic1[@"name"] = mes.name;
             dic1[@"data"] = mes.data;
         }
         dic[@"latestMessage"] = dic1;
         dic[@"sentStatus"] = [self sentStatusConvertFromInteger:conversation.sentStatus];
         dic[@"objectName"] = conversation.objectName?:@"";
         dic[@"receivedStatus"] = @(conversation.receivedStatus);
         dic[@"senderUserId"] = conversation.senderUserId;
         dic[@"unreadMessageCount"] = @(conversation.unreadMessageCount);
         dic[@"receivedTime"] = @(conversation.receivedTime);
         dic[@"sentTime"] = @(conversation.sentTime);
         dic[@"isTop"] = @(conversation.isTop);
         dic[@"latestMessageId"] = @(conversation.lastestMessageId);
         return [dic JSONFragment];
     }else{
         dic[@"resultCode"] = @(1);
         return [dic JSONFragment];
     }
   
}
-(void)removeConversation:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    if (type == 0) {
        return;
    }
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    if ([self.RCManager.SDK respondsToSelector:@selector(removeConversation:targetId:)]) {
      BOOL state = [self.RCManager.SDK removeConversation:type targetId:[info objectForKey:@"targetId"]];
        result[@"resultCode"] = state?@(0):@(1);
         [self.RCManager callBackJsonWithFunction:@"cbRemoveConversation" parameter:result];
    }else{
        result[@"resultCode"] = @(2);
        [self.RCManager callBackJsonWithFunction:@"cbRemoveConversation" parameter:result];
    }
    
}

-(void)clearConversations:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSArray *array = [info objectForKey:@"conversationTypes"];
    if (array.count<1) {
        return;
    }
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *str in array) {
        NSInteger integer = [self convertFromString:str];
        [arr addObject:@(integer)];
    }
    if ([self.RCManager.SDK respondsToSelector:@selector(clearConversations:)]) {
        BOOL state = [self.RCManager.SDK clearConversations:arr];
        result[@"resultCode"] = state?@(0):@(1);
        [self.RCManager callBackJsonWithFunction:@"cbClearConversations" parameter:result];
    }else{
        result[@"resultCode"] = @(2);
        [self.RCManager callBackJsonWithFunction:@"cbClearConversations" parameter:result];
    }
   
    
}
-(void)setConversationToTop:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
     NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    if ([self.RCManager.SDK respondsToSelector:@selector(setConversationToTop:targetId:isTop:)]) {
      BOOL state =  [self.RCManager.SDK setConversationToTop:type targetId:[info objectForKey:@"targetId"] isTop:[[info objectForKey:@"isTop"] boolValue]];
        result[@"resultCode"] = state?@(0):@(1);
        [self.RCManager callBackJsonWithFunction:@"cbSetConversationToTop" parameter:result];
    }else{
        result[@"resultCode"] = @(2);
        [self.RCManager callBackJsonWithFunction:@"cbSetConversationToTop" parameter:result];

    }
    
    
}
-(void)getConversationNotificationStatus:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
     NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
     NSMutableDictionary *result=[NSMutableDictionary dictionary];
    if ([self.RCManager.SDK respondsToSelector:@selector(getConversationNotificationStatus:targetId:success:error:)]) {
        [self.RCManager.SDK getConversationNotificationStatus:type targetId:[info objectForKey:@"targetId"] success:^(RCConversationNotificationStatus nStatus) {
            result[@"resultCode"] = @(0);
            result[@"status"] = @(nStatus);
            [self.RCManager callBackJsonWithFunction:@"cbGetConversationNotificationStatus" parameter:result];
        } error:^(RCErrorCode status) {
            result[@"resultCode"] = @(1);
            [self.RCManager callBackJsonWithFunction:@"cbGetConversationNotificationStatus" parameter:result];
        }];
    } else {
        result[@"resultCode"] = @(2);
        [self.RCManager callBackJsonWithFunction:@"cbGetConversationNotificationStatus" parameter:result];
    }
    
}
-(void)setConversationNotificationStatus:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
     __weak typeof(self) Myself = self;
    if ([self.RCManager.SDK respondsToSelector:@selector(setConversationNotificationStatus:targetId:isBlocked:success:error:)]) {
        [self.RCManager.SDK setConversationNotificationStatus:type targetId:[info objectForKey:@"targetId"] isBlocked:![[info objectForKey:@"status"] boolValue] success:^(RCConversationNotificationStatus nStatus) {
            result[@"resultCode"] = @(0);
            result[@"status"] = @(nStatus);
            [Myself.RCManager callBackJsonWithFunction:@"cbSetConversationNotificationStatus" parameter:result];

        } error:^(RCErrorCode status) {
            result[@"resultCode"] = @(1);
            [Myself.RCManager callBackJsonWithFunction:@"cbSetConversationNotificationStatus" parameter:result];

        }];
    } else {
        result[@"resultCode"] = @(2);
        [self.RCManager callBackJsonWithFunction:@"cbSetConversationNotificationStatus" parameter:result];
    }
    
}

-(void)getLatestMessages:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSString *targetId = [info objectForKey:@"targetId"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *result=[NSMutableArray array];
    NSArray *array = [self.RCManager.SDK getLatestMessages:type targetId:targetId count:[[info objectForKey:@"count"] intValue]];
        for (RCMessage *message in array) {
            dic[@"extra"] = message.extra;
            dic[@"conversationType"] = [self convertFromInteger:message.conversationType];
            dic[@"messageDirection"] = [self convertFromDrection:message.messageDirection];
            dic[@"targetId"] = message.targetId;
            dic[@"objectName"] = message.objectName?:@"";
            dic[@"sentStatus"] = [self sentStatusConvertFromInteger:message.sentStatus];
            dic[@"senderUserId"] = message.senderUserId;
            dic[@"messageId"] = @(message.messageId);
            dic[@"sentTime"] = @(message.sentTime);
            dic[@"receivedTime"] = @(message.receivedTime);
            NSMutableDictionary *content = [NSMutableDictionary dictionary];
            RCMessageContent *con = message.content;
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
            dic[@"content"] = content;
            [result addObject:dic];
        }
         [self.RCManager callBackJsonWithFunction:@"cbGetLatestMessages" parameter:result];
    
}

-(void)getHistoryMessages:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSString *targetId = [info objectForKey:@"targetId"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *result=[NSMutableArray array];
        NSArray *array = [self.RCManager.SDK getHistoryMessages:type targetId:targetId oldestMessageId:[[info objectForKey:@"oldestMessageId"] floatValue] count:[[info objectForKey:@"count"] intValue]];
        for (RCMessage *message in array) {
            
            dic[@"extra"] = message.extra;
            dic[@"conversationType"] = [self convertFromInteger:message.conversationType];
            dic[@"messageDirection"] = [self convertFromDrection:message.messageDirection];
            dic[@"targetId"] = message.targetId;
            dic[@"objectName"] = message.objectName?:@"";
            dic[@"sentStatus"] = [self sentStatusConvertFromInteger:message.sentStatus];
            dic[@"senderUserId"] = message.senderUserId;
            dic[@"messageId"] = @(message.messageId);
            dic[@"sentTime"] = @(message.sentTime);
            dic[@"receivedTime"] = @(message.receivedTime);
            NSMutableDictionary *content = [NSMutableDictionary dictionary];
            RCMessageContent *con = message.content;
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
            dic[@"content"] = content;
            [result addObject:dic];
        }
       [self.RCManager callBackJsonWithFunction:@"cbGetHistoryMessages" parameter:result];
}
-(void)deleteMessages:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSArray *array = [info objectForKey:@"messageIds"];
    if ([self.RCManager.SDK respondsToSelector:@selector(deleteMessages:)]) {
        BOOL state = [self.RCManager.SDK deleteMessages:array];
        result[@"resultCode"] = state?@(0):@(1);
         [self.RCManager callBackJsonWithFunction:@"cbDeleteMessages" parameter:result];
    }else{
         result[@"resultCode"] = @(2);
         [self.RCManager callBackJsonWithFunction:@"cbDeleteMessages" parameter:result];
    }
}
-(void)clearMessages:(NSMutableArray *)inArguments{// 清空某一会话的所有聊天消息记录
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSString *targetId = [info objectForKey:@"targetId"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    if ([self.RCManager.SDK respondsToSelector:@selector(clearMessages:targetId:)]) {
      BOOL state = [self.RCManager.SDK clearMessages:type targetId:targetId];
        result[@"resultCode"] = state?@(0):@(1);
        [self.RCManager callBackJsonWithFunction:@"cbClearMessages" parameter:result];
    } else {
        result[@"resultCode"] = @(2);
        [self.RCManager callBackJsonWithFunction:@"cbClearMessages" parameter:result];

    }
}
-(NSNumber*)getTotalUnreadCount:(NSMutableArray *)inArguments{//获取所有未读消息数
    NSInteger num = [self.RCManager.SDK getTotalUnreadCount];
    return @(num) ;
    
}
-(NSNumber*)getUnreadCount:(NSMutableArray *)inArguments{//获取来自某用户（某会话）的未读消息数
    if(inArguments.count<1){
        exit(0);
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSString *targetId = [info objectForKey:@"targetId"];
    NSInteger num = [self.RCManager.SDK getUnreadCount:type targetId:targetId];
    return @(num);
    
}
-(NSNumber*)getUnreadCountByConversationTypes:(NSMutableArray *)inArguments{//获取来自某用户（某会话）的未读消息数
    if(inArguments.count<1){
         exit(0);
    }
    id info=[inArguments[0] JSONValue];
    NSArray *array = [info objectForKey:@"conversationTypes"];
    NSInteger num = [self.RCManager.SDK getUnreadCount:array];
    return @(num);
    
}
-(void)setMessageReceivedStatus:(NSMutableArray *)inArguments{//设置接收到的消息状态
    if(inArguments.count<1){
        exit(0);
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSInteger  messageId = [[info objectForKey:@"messageId"] integerValue];
    NSInteger receivedStatus = [[info objectForKey:@"receivedStatus"] integerValue];
    BOOL state = [self.RCManager.SDK setMessageReceivedStatus:messageId receivedStatus:receivedStatus];
    result[@"resultCode"] = @(state?0:1);
    [self.RCManager callBackJsonWithFunction:@"cbSetMessageReceivedStatus" parameter:result];
    
    
}
-(void)clearMessagesUnreadStatus:(NSMutableArray *)inArguments{//清除某一会话的消息未读状态
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSInteger type = [self convertFromString:[info objectForKey:@"conversationType"]];
    NSString *targetId = [info objectForKey:@"targetId"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    BOOL state = [self.RCManager.SDK clearMessages:type targetId:targetId];
    result[@"resultCode"] = @(state?0:1);
    [self.RCManager callBackJsonWithFunction:@"cbClearMessagesUnreadStatus" parameter:result];

}
/*
#pragma mark - -4黑名单
-(void)addToBlacklist:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *userId = [info objectForKey:@"userId"];
     NSMutableDictionary *result=[NSMutableDictionary dictionary];
    __weak typeof(self) Myself = self;
    [self.RCManager.SDK addToBlacklist:userId success:^{
        result[@"resultCode"] = @(0);
        [Myself.RCManager callBackJsonWithFunction:@"cbAddToBlacklist" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"] = @(1);
        [Myself.RCManager callBackJsonWithFunction:@"cbAddToBlacklist" parameter:result];
    }];
    
}

-(void)removeFromBlacklist:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *userId = [info objectForKey:@"userId"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK removeFromBlacklist:userId success:^{
        result[@"resultCode"] = @(0);
        [self.RCManager callBackJsonWithFunction:@"cbRemoveFromBlacklist" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"] = @(1);
        [self.RCManager callBackJsonWithFunction:@"cbRemoveFromBlacklist" parameter:result];
    }];
}
- (void)getBlacklistStatus:(NSMutableArray *)inArguments{//查询某个用户是否已经在黑名单中
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *userId = [info objectForKey:@"userId"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK getBlacklistStatus:userId success:^(int bizStatus) {
        result[@"resultCode"] = @(0);
        result[@"bizStatus"] = @(bizStatus);//0表示已经在黑名单中，101表示不在黑名单中
        [self.RCManager callBackJsonWithFunction:@"cbGetBlacklistStatus" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"] = @(1);
         [self.RCManager callBackJsonWithFunction:@"cbGetBlacklistStatus" parameter:result];
    }];
}
-(void)getBlacklist:(NSMutableArray *)inArguments{
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK getBlacklist:^(NSArray *blockUserIds) {
        result[@"blockUserIds"] = blockUserIds;
        result[@"resultCode"] = @(0);
        [self.RCManager callBackJsonWithFunction:@"cbGetBlacklist" parameter:result];
    } error:^(RCErrorCode status) {
         result[@"resultCode"] = @(1);
        [self.RCManager callBackJsonWithFunction:@"cbGetBlacklist" parameter:result];
    }];
}
#pragma mark - -5讨论组操作
- (void)createDiscussion:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *name = [info objectForKey:@"name"];
    NSArray *userIdList = [info objectForKey:@"userIdList"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK createDiscussion:name userIdList:userIdList success:^(RCDiscussion *discussion) {
        result[@"resultCode"]=@(0);
        result[@"discussionId"] = discussion.discussionId;
        result[@"discussionName"] = discussion.discussionName;
        result[@"creatorId"] = discussion.creatorId;
        result[@"memberIdList"] = discussion.memberIdList;
        result[@"inviteStatus"] = @(discussion.inviteStatus);//0表示允许，1表示不允许，默认值为0
        [self.RCManager callBackJsonWithFunction:@"cbCreateDiscussion" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbCreateDiscussion" parameter:result];
    }];
}
- (void)addMemberToDiscussion:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *discussionId = [info objectForKey:@"discussionId"];
    NSArray *userIdList = [info objectForKey:@"userIdList"];
     NSMutableDictionary *result=[NSMutableDictionary dictionary];
    __weak typeof (self) Myself = self;//__weak typeof(self) Myself = self;
    [self.RCManager.SDK addMemberToDiscussion:discussionId userIdList:userIdList success:^(RCDiscussion *discussion) {
        result[@"resultCode"]=@(0);
        result[@"discussionId"] = discussion.discussionId;
        result[@"discussionName"] = discussion.discussionName;
        result[@"creatorId"] = discussion.creatorId;
        result[@"memberIdList"] = discussion.memberIdList;
        result[@"inviteStatus"] = @(discussion.inviteStatus);//0表示允许，1表示不允许，默认值为0
        [Myself.RCManager callBackJsonWithFunction:@"cbAddMemberToDiscussion" parameter:result];
    } error:^(RCErrorCode status) {
         result[@"resultCode"]=@(1);
        [Myself.RCManager callBackJsonWithFunction:@"cbAddMemberToDiscussion" parameter:result];
    }];
    
}
- (void)removeMemberFromDiscussion:(NSMutableArray *)inArguments{//讨论组踢人，将用户移出讨论组
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *discussionId = [info objectForKey:@"discussionId"];
    NSString *userId = [info objectForKey:@"userId"];
     NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK removeMemberFromDiscussion:discussionId userId:userId success:^(RCDiscussion *discussion) {
        result[@"resultCode"]=@(0);
        result[@"discussionId"] = discussion.discussionId;
        result[@"discussionName"] = discussion.discussionName;
        result[@"creatorId"] = discussion.creatorId;
        result[@"memberIdList"] = discussion.memberIdList;
        result[@"inviteStatus"] = @(discussion.inviteStatus);//0表示允许，1表示不允许，默认值为0
        [self.RCManager callBackJsonWithFunction:@"cbRemoveMemberFromDiscussion" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbRemoveMemberFromDiscussion" parameter:result];//如果当前登陆用户不是此讨论组的创建者并且此讨论组没有开放加人权限，则会返回错误。

    }];
}
- (void)quitDiscussion:(NSMutableArray *)inArguments{//退出当前讨论组
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *discussionId = [info objectForKey:@"discussionId"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK quitDiscussion:discussionId success:^(RCDiscussion *discussion) {
        result[@"resultCode"]=@(0);
        result[@"discussionId"] = discussion.discussionId;
        result[@"discussionName"] = discussion.discussionName;
        result[@"creatorId"] = discussion.creatorId;
        result[@"memberIdList"] = discussion.memberIdList;
        result[@"inviteStatus"] = @(discussion.inviteStatus);//0表示允许，1表示不允许，默认值为0
        [self.RCManager callBackJsonWithFunction:@"cbQuitDiscussion" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbQuitDiscussion" parameter:result];
    }];
}
- (void)getDiscussion:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *discussionId = [info objectForKey:@"discussionId"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK getDiscussion:discussionId success:^(RCDiscussion *discussion) {
        result[@"resultCode"]=@(0);
        result[@"discussionId"] = discussion.discussionId;
        result[@"discussionName"] = discussion.discussionName;
        result[@"creatorId"] = discussion.creatorId;
        result[@"memberIdList"] = discussion.memberIdList;
        result[@"inviteStatus"] = @(discussion.inviteStatus);//0表示允许，1表示不允许，默认值为0
        [self.RCManager callBackJsonWithFunction:@"cbGetDiscussion" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbGetDiscussion" parameter:result];
    }];
}
- (void)setDiscussionName:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *targetId= [info objectForKey:@"targetId"];
    NSString *discussionName = [info objectForKey:@"discussionName"];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    __weak typeof(self) Myself = self;
    [self.RCManager.SDK setDiscussionName:targetId name:discussionName success:^{
        result[@"resultCode"]=@(0);
        [Myself.RCManager callBackJsonWithFunction:@"cbSetDiscussionName" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [Myself.RCManager callBackJsonWithFunction:@"cbSetDiscussionName" parameter:result];
    }];
}
- (void)setDiscussionInviteStatus:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *targetId= [info objectForKey:@"targetId"];
    BOOL isOpen = [[info objectForKey:@"isOpen"] boolValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    __weak typeof(self) Myself = self;
    [self.RCManager.SDK setDiscussionInviteStatus:targetId isOpen:isOpen success:^{
        result[@"resultCode"]=@(0);
        [Myself.RCManager callBackJsonWithFunction:@"cbSetDiscussionInviteStatus" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [Myself.RCManager callBackJsonWithFunction:@"cbSetDiscussionInviteStatus" parameter:result];
    }];
}
#pragma mark - -6聊天室操作
- (void)joinChatRoom:(NSMutableArray *)inArguments{// 加入聊天室（如果聊天室不存在则会创建）
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *targetId= [info objectForKey:@"targetId"];
    int messageCount = [[info objectForKey:@"messageCount"] intValue];//-1<=messageCount<=50
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK joinChatRoom:targetId messageCount:messageCount success:^{
        result[@"resultCode"]=@(0);
        [self.RCManager callBackJsonWithFunction:@"cbJoinChatRoom" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbJoinChatRoom" parameter:result];

    }];
}
- (void)joinExistChatRoom:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSString *targetId= [info objectForKey:@"targetId"];
    int messageCount = [[info objectForKey:@"messageCount"] intValue];//-1<=messageCount<=50
     NSMutableDictionary *result=[NSMutableDictionary dictionary];
    [self.RCManager.SDK joinExistChatRoom:targetId messageCount:messageCount success:^{
        result[@"resultCode"]=@(0);
        [self.RCManager callBackJsonWithFunction:@"cbJoinExistChatRoom" parameter:result];

    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbJoinExistChatRoom" parameter:result];
    }];

}
- (void)quitChatRoom:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSString *targetId= [info objectForKey:@"targetId"];
    [self.RCManager.SDK quitChatRoom:targetId success:^{
        result[@"resultCode"]=@(0);
        [self.RCManager callBackJsonWithFunction:@"cbQuitChatRoom" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(1);
        [self.RCManager callBackJsonWithFunction:@"cbQuitChatRoom" parameter:result];
    }];
}
- (void)getChatRoomInfo:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSString *targetId= [info objectForKey:@"targetId"];
    int count = [[info objectForKey:@"count"] intValue];
    int order = [[info objectForKey:@"order"] intValue];
    [self.RCManager.SDK getChatRoomInfo:targetId count:count order:order success:^(RCChatRoomInfo *chatRoomInfo) {
        result[@"resultCode"]=@(0);
        result[@"targetId"]= chatRoomInfo.targetId;
        result[@"memberOrder"] = @(chatRoomInfo.memberOrder);
        NSMutableArray *memberInfoArray = [NSMutableArray array];
        for (RCChatRoomMemberInfo *memberInfo in chatRoomInfo.memberInfoArray) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = memberInfo.userId;
            dic[@"joinTime"]=@(memberInfo.joinTime);
            [memberInfoArray addObject:dic];
        }
        result[@"memberInfoArray"] = memberInfoArray;
        result[@"totalMemberCount"] = @(chatRoomInfo.totalMemberCount);
         [self.RCManager callBackJsonWithFunction:@"cbGetChatRoomInfo" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"]=@(status);
         [self.RCManager callBackJsonWithFunction:@"cbGetChatRoomInfo" parameter:result];
    }];

}
#pragma mark --7客服
- (void)joinCustomerServiceChat:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSString *customerServiceId = [info objectForKey:@"customerServiceId"];
    [self.RCManager.SDK joinCustomerServiceChat:customerServiceId success:^{
        result[@"resultCode"] = @(0);
    [self.RCManager callBackJsonWithFunction:@"cbJoinCustomerServiceChat" parameter:result];
        
    } error:^(RCErrorCode status) {
        result[@"resultCode"] = @(status);
    [self.RCManager callBackJsonWithFunction:@"cbJoinCustomerServiceChat" parameter:result];
    }];
    
}
- (void)quitCustomerServiceChat:(NSMutableArray *)inArguments{
    if(inArguments.count<1){
        return;
    }
    id info=[inArguments[0] JSONValue];
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    NSString *customerServiceId = [info objectForKey:@"customerServiceId"];
    [self.RCManager.SDK quitCustomerServiceChat:customerServiceId success:^{
        result[@"resultCode"] = @(0);
        [self.RCManager callBackJsonWithFunction:@"cbQuitCustomerServiceChat" parameter:result];
    } error:^(RCErrorCode status) {
        result[@"resultCode"] = @(status);
        [self.RCManager callBackJsonWithFunction:@"cbQuitCustomerServiceChat" parameter:result];
    }];
}
#pragma mark －－8消息接收监听
- (void)setReceiveMessageDelegate:(NSMutableArray *)inArguments{
    
}
//插入消息
 */
#pragma mark - -10工具类
-(NSInteger)convertFromString:(NSString*)conversationStr{
    if ([conversationStr isEqualToString:@"PRIVATE"]) {
        return 1;
    }
    if ([conversationStr isEqualToString:@"DISCUSSION"]) {
        return 2;
    }
    if ([conversationStr isEqualToString:@"GROUP"]) {
        return 3;
    }
    if ([conversationStr isEqualToString:@"CHATROOM"]) {
        return 4;
    }
    if ([conversationStr isEqualToString:@"CUSTOMER_SERVICE"]) {
        return 5;
    
    }
    if ([conversationStr isEqualToString:@"SYSTEM"]) {
        return 6;
        
    }
    return 0;
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
-(NSString*)receivedStatusConvertFromInteger:(NSInteger)integer{
    if (integer == 0) {//未读
        return @"UNRESD";
    }
    if (integer == 1) {//已读
        return @"READ";
    }
    if (integer == 2) {//已听
        return @"LISTENED";
    }
    if (integer == 4) {//已下载
        return @"DOWNLOADED";
    }
        return @"";
}
-(NSString*)sentStatusConvertFromInteger:(NSInteger)integer{
    if (integer == 10) {//发送中
        return @"SENDING";
    }
    if (integer == 20) {//发送失败
        return @"FAILED";
    }
    if (integer == 30) {//已发送成功
        return @"SENT";
    }
    if (integer == 40) {
        return @"RECEIVED";//对方已接收
    }
    if (integer == 50) {//对方已阅读
        return @"READ";
    }
    if (integer == 60) {//对方已销毁
        return @"DESTROYED ";
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
- (NSString *)getImageSaveDirPath{
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    NSString *wgtTempPath=[tempPath stringByAppendingPathComponent:[EUtility brwViewWidgetId:self.meBrwView]];
    
    return [wgtTempPath stringByAppendingPathComponent:@"uexRongCloud"];
}
//图片\音频的保存路径
- (NSString *)getAudioSaveDirPath{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    NSString *wgtTempPath=[tempPath stringByAppendingPathComponent:[EUtility brwViewWidgetId:self.meBrwView]];
    
    return [wgtTempPath stringByAppendingPathComponent:@"uexRongCloud"];
}
-(NSString *) saveMessageDataToLocalPath:(NSData *)messageData
{
    
    if (!messageData) {
        return nil;
    }
     NSFileManager *fmanager = [NSFileManager defaultManager];
    NSString *uexImageSaveDir=[self getAudioSaveDirPath];
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
    
    NSString *uexImageSaveDir=[self getImageSaveDirPath];
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
