#import "LLRedEnvelopesMgr.h"
#import "RemoteControlManager.h"

%hook CMessageMgr

- (void)onRevokeMsg:(CMessageWrap*)arg1{

	if(![LLRedEnvelopesMgr shared].isOpenAvoidRevokeMessage){
		%orig;
	}
	else
	{
		if ([arg1.m_nsContent rangeOfString:@"<session>"].location == NSNotFound) { return; }
        if ([arg1.m_nsContent rangeOfString:@"<replacemsg>"].location == NSNotFound) { return; }
        
        NSString *(^parseParam)(NSString *, NSString *,NSString *) = ^NSString *(NSString *content, NSString *paramBegin,NSString *paramEnd) {
            NSUInteger startIndex = [content rangeOfString:paramBegin].location + paramBegin.length;
            NSUInteger endIndex = [content rangeOfString:paramEnd].location;
            NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
            return [content substringWithRange:range];
        };
    
    
        NSString *(^parseSender)(NSString *, NSString *) = ^NSString *(NSString *m_nsContent, NSString *m_nsSession) {
            NSString *regularPattern = [m_nsContent containsString:@"has recalled a message."] ? @"<!\\[CDATA\\[(.*?)has recalled a message.\\]\\]>" : @"<!\\[CDATA\\[(.*?)撤回了一条消息\\]\\]>";
            NSRegularExpression *regexCN = [NSRegularExpression regularExpressionWithPattern:regularPattern options:NSRegularExpressionCaseInsensitive error:nil];
            NSRange range = NSMakeRange(0, m_nsContent.length);
            NSTextCheckingResult *nameResult = [regexCN matchesInString:m_nsContent options:0 range:range].firstObject;
            if (nameResult.numberOfRanges < 2) { return nil; }
            NSString *senderName = [m_nsContent substringWithRange:[nameResult rangeAtIndex:1]];
        
            if ([m_nsSession hasSuffix:@"@chatroom"]) {
                NSArray *result = [m_nsContent componentsSeparatedByString:@":"];
                NSString *wxid = result.firstObject;
                return [NSString stringWithFormat:@"%@(%@)",senderName,wxid];
            }
            return senderName;
        };

        NSString *session = parseParam(arg1.m_nsContent, @"<session>", @"</session>");
        NSString *newmsgid = parseParam(arg1.m_nsContent, @"<newmsgid>", @"</newmsgid>");

        CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
        CContact *selfContact = [contactMgr getSelfContact];

        CMessageWrap *revokemsg = [self GetMsg:session n64SvrID:[newmsgid integerValue]];
        BOOL isSender = [revokemsg.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];

        BOOL en = [arg1.m_nsContent containsString:@"has recalled a message."];

        if (isSender) {
            %orig;
        } 
        else
        {
            CMessageWrap *msgWrap = [[objc_getClass("CMessageWrap") alloc] initWithMsgType:0x2710];
            [msgWrap setM_nsFromUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsToUsr:arg1.m_nsFromUsr];
            [msgWrap setM_uiStatus:0x4];
            [msgWrap setM_uiCreateTime:[arg1 m_uiCreateTime]];
            NSString *sender = parseSender(arg1.m_nsContent,session);
            NSString * sendContent = [NSString stringWithFormat:en ? @"Prevent %@ recalled a message." : @"拦截 %@ 的一条撤回消息", sender ? sender : arg1.m_nsFromUsr];
            [msgWrap setM_nsContent:sendContent];

            [self AddLocalMsg:session MsgWrap:msgWrap fixTime:0x1 NewMsgArriveNotify:0x0];
        }
	}
}

%new
- (void)sendMsg:(NSString *)msg toContactUsrName:(NSString *)userName{
    CMessageWrap *wrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1];
    id usrName = [NSClassFromString(@"SettingUtil") getLocalUsrName:0];
    [wrap setM_nsFromUsr:usrName];
    [wrap setM_nsContent:msg];
    [wrap setM_nsToUsr:userName];
    MMNewSessionMgr *sessionMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("MMNewSessionMgr") class]];
    [wrap setM_uiCreateTime:[sessionMgr GenSendMsgTime]];
    [wrap setM_uiStatus:YES];
    
    CMessageMgr *chatMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CMessageMgr") class]];
    [chatMgr AddMsg:userName MsgWrap:wrap];
}

- (id)GetMsgByCreateTime:(id)arg1 FromID:(unsigned int)arg2 FromCreateTime:(unsigned int)arg3 Limit:(unsigned int)arg4 LeftCount:(unsigned int *)arg5 FromSequence:(unsigned int)arg6
{
    id result = %orig;
    return [RemoteControlManager filterMessageWrapArr:result];
}

%end