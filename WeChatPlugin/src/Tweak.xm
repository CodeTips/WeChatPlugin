#import "WeChat.h"
#import "WCPluginManager.h"
#import "WCPluginSettingController.h"
#import <AVFoundation/AVFoundation.h>
#import "WCRemoteControlManager.h"

%hook WCDeviceStepObject

- (unsigned long)m7StepCount{
	if([WCPluginManager shared].isOpenSportHelper){
		return [[WCPluginManager shared] getSportStepCount]; // max value is 98800
	} else {
		return %orig;
	}
}

%end

%hook UINavigationController

- (void)PushViewController:(UIViewController *)controller animated:(BOOL)animated{
	if ([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].isHongBaoPush && [controller isMemberOfClass:NSClassFromString(@"BaseMsgContentViewController")]) {
		[WCPluginManager shared].isHongBaoPush = NO;
        [[WCPluginManager shared] handleRedEnvelopesPushVC:(BaseMsgContentViewController *)controller]; 
    } else {
    	%orig;
    }
}

%end

%hook UIViewController 

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
	WCPluginManager *manager = [WCPluginManager shared];
	if (manager.isOpenRedEnvelopesHelper && manager.isHiddenRedEnvelopesReceiveView && [viewControllerToPresent isKindOfClass:NSClassFromString(@"MMUINavigationController")]){
		manager.isHiddenRedEnvelopesReceiveView = NO;
		UINavigationController *navController = (UINavigationController *)viewControllerToPresent;
		if (navController.viewControllers.count > 0){
			if ([navController.viewControllers[0] isKindOfClass:NSClassFromString(@"WCRedEnvelopesRedEnvelopesDetailViewController")]){
				//模态红包详情视图
				if([manager isMySendMsgWithMsgWrap:manager.msgWrap]){
					//领取的是自己发的红包,不自动回复和自动留言
					return;
				}
				if(manager.isOpenAutoReply && [self isMemberOfClass:%c(BaseMsgContentViewController)]){
					BaseMsgContentViewController *baseMsgVC = (BaseMsgContentViewController *)self;
					[baseMsgVC AsyncSendMessage:manager.autoReplyText];
				}
				if(manager.isOpenAutoLeaveMessage){
					WCRedEnvelopesReceiveControlLogic *redEnvelopeLogic = MSHookIvar<WCRedEnvelopesReceiveControlLogic *>(navController.viewControllers[0],"m_delegate");
					[redEnvelopeLogic OnCommitWCRedEnvelopes:manager.autoLeaveMessageText];
				}
				return;
			}
		}
	} 
	%orig;	
}

%end

%hook CMessageMgr

- (void)MainThreadNotifyToExt:(NSDictionary *)ext{
	%orig;
	if([WCPluginManager shared].isOpenRedEnvelopesHelper){
		CMessageWrap *msgWrap = ext[@"3"];
	    [[WCPluginManager shared] handleMessageWithMessageWrap:msgWrap isBackground:NO];
	}
}

- (void)onNewSyncShowPush:(NSDictionary *)message{
	%orig;
	if ([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].isOpenBackgroundMode && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
		//app在后台运行
		CMessageWrap *msgWrap = (CMessageWrap *)message;
	    [[WCPluginManager shared] handleMessageWithMessageWrap:msgWrap isBackground:YES];
	}
}

%end

%hook WCRedEnvelopesReceiveHomeView

- (id)initWithFrame:(CGRect)frame andData:(id)data delegate:(id)delegate{
	WCRedEnvelopesReceiveHomeView *view = %orig;
	if([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].isHiddenRedEnvelopesReceiveView){
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([WCPluginManager shared].openRedEnvelopesDelaySecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			//打开红包
        	[view OnOpenRedEnvelopes];
    	});
	    view.hidden = YES;
	}
    return view;
}

- (void)showSuccessOpenAnimation{
	%orig;
	if ([WCPluginManager shared].isOpenRedEnvelopesHelper && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground){ 
		[[WCPluginManager shared] successOpenRedEnvelopesNotification];
	}
}

%end 

%hook MMUIWindow 

- (void)addSubview:(UIView *)subView{
	if ([WCPluginManager shared].isOpenRedEnvelopesHelper && [subView isKindOfClass:NSClassFromString(@"WCRedEnvelopesReceiveHomeView")] && [WCPluginManager shared].isHiddenRedEnvelopesReceiveView){
		//隐藏弹出红包领取完成页面所在window
		((UIView *)self).hidden = YES;
	} else {
		%orig;
	}
}

- (void)dealloc{
	if ([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].isHiddenRedEnvelopesReceiveView){
		[WCPluginManager shared].isHiddenRedEnvelopesReceiveView = NO;
	} else {
		%orig;
	}
}

%end

%hook NewMainFrameViewController

- (void)viewDidLoad{
	%orig;
	[WCPluginManager shared].openRedEnvelopesBlock = ^{
		if([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].haveNewRedEnvelopes){
			[WCPluginManager shared].haveNewRedEnvelopes = NO;
			[WCPluginManager shared].isHongBaoPush = YES;
			[[WCPluginManager shared] openRedEnvelopes:self];
		}
	};
}

- (void)reloadSessions{
	%orig;
	if([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].openRedEnvelopesBlock){
		[WCPluginManager shared].openRedEnvelopesBlock();
	}
}

%end

%hook WCRedEnvelopesControlLogic

- (void)startLoading{
	if ([WCPluginManager shared].isOpenRedEnvelopesHelper && [WCPluginManager shared].isHiddenRedEnvelopesReceiveView){
		//隐藏加载菊花
		//do nothing	
	} else {
		%orig;
	}
}

%end

%hook NewSettingViewController

- (void)reloadTableData{
	%orig;
    WCTableViewNormalCellManager *configCell = [%c(WCTableViewNormalCellManager) normalCellForSel:@selector(configHandler) target:self title:@"Plugin" accessoryType:1];
    MMTableViewSectionInfo *sectionInfo = [%c(WCTableViewSectionManager) sectionInfoDefaut];
    [sectionInfo addCell:configCell];
    MMTableViewInfo *tableViewInfo = [self valueForKey:@"m_tableViewMgr"];
    [tableViewInfo insertSection:sectionInfo At:0];
    [[tableViewInfo getTableView] reloadData];
}

%new
- (void)configHandler{
    WCPluginSettingController *settingVC = [[WCPluginSettingController alloc] init];
    [((UIViewController *)self).navigationController PushViewController:settingVC animated:YES];
}

%end

%hook MicroMessengerAppDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application {
	%orig;
	[[WCPluginManager shared] reset];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
  %orig;
  [[WCPluginManager shared] enterBackgroundHandler];
}

%end

%hook MMMsgLogicManager

- (id)GetCurrentLogicController{
	if([WCPluginManager shared].isHiddenRedEnvelopesReceiveView && [WCPluginManager shared].logicController){
		return [WCPluginManager shared].logicController;
	} 
	return %orig;
}

%end

%hook OnlineDeviceInfoViewController

- (void)viewDidAppear:(BOOL)arg1
{
    %orig;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setupRemoteBtn) userInfo:nil repeats:NO];
}

%new
- (void)setupRemoteBtn
{
    if([WCRemoteControlManager sharedManager].enableRemoteCommands.count)
    {
        NSMutableArray *controlButtons = [self valueForKey:@"_controlButtons"];
        UIView *controlView = [controlButtons.firstObject superview];
        controlView.frame = CGRectMake(controlView.frame.origin.x, controlView.frame.origin.y - 40, controlView.frame.size.width, controlView.frame.size.height);
        UIView *remoteView = [[UIView alloc] initWithFrame:CGRectMake(controlView.frame.origin.x, controlView.frame.origin.y + controlView.frame.size.height + 10, controlView.frame.size.width, controlView.frame.size.height)];
        [controlView.superview addSubview:remoteView];
        NSArray *commands = [WCRemoteControlManager sharedManager].enableRemoteCommands;
        for (int i = 0; i < (commands.count > 3 ? 3 : commands.count); i ++) {
            WCRemoteControlModel *model = commands[i];
            NSString *imageName = [model.command componentsSeparatedByString:@"."].lastObject;
            NSString *imagePath = [PluginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.png",imageName]];
    		NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    		UIImage *image = [UIImage imageWithData:imageData scale:2];
            UIButton *button = [self makeControlButtonWithTitle:model.function image:image highlightedImage:image target:[WCRemoteControlManager sharedManager] action:@selector(sendRemoteControlCommand:)];
            button.frame = CGRectMake(i * (81 + (remoteView.frame.size.width - 3 * 81) / 2), 0, button.frame.size.width, button.frame.size.height);
            button.tag = i + 100;
            [remoteView addSubview:button];
        }
    }
}


%end

%hook VoipCXMgr

+ (BOOL)isCallkitAvailable{
	return YES;
}
+ (BOOL)isDeviceCallkitAvailable{
	return YES;
}

%end


%hook MMLocationMgr

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
   if([WCPluginManager shared].isOpenVirtualLocation && newLocation && [newLocation isMemberOfClass:[CLLocation class]]){
        CLLocation *virutalLocation = [[WCPluginManager shared] getVirutalLocationWithRealLocation:newLocation];
    	%orig(manager,virutalLocation,oldLocation?virutalLocation:nil);
    } else {
        %orig;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(CLLocation *)location{
    if([WCPluginManager shared].isOpenVirtualLocation && location && [location isMemberOfClass:[CLLocation class]]){
        %orig(mapView,[[WCPluginManager shared] getVirutalLocationWithRealLocation:location]);
    } else {
        %orig;
    }
}

%end

%hook QMapView

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if([WCPluginManager shared].isOpenVirtualLocation && newLocation && [newLocation isMemberOfClass:[CLLocation class]]){
        CLLocation *virutalLocation = [[WCPluginManager shared] getVirutalLocationWithRealLocation:newLocation];
        %orig(manager,virutalLocation,oldLocation?virutalLocation:nil);
    } else {
        %orig;
    }
}

- (id)correctLocation:(id)arg1{
    return [WCPluginManager shared].isOpenVirtualLocation ? arg1 : %orig;
}

%end

%hook CMessageMgr

- (void)onRevokeMsg:(CMessageWrap*)arg1{

	if(![WCPluginManager shared].isOpenAvoidRevokeMessage){
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
    return [WCRemoteControlManager filterMessageWrapArr:result];
}

%end

%subclass LLFilterChatRoomController : ChatRoomListViewController

%property (nonatomic, retain) NSMutableDictionary *filterRoomDic;

- (void)viewDidLoad{
	%orig;

	[self setNavigationBar];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self commonInit];
    });
}

- (void)initSearchBar{
	
}

%new
- (void)commonInit{
	MMTableView *tableView = MSHookIvar<MMTableView *>(self,"m_tableView");
	[tableView setEditing:YES animated:YES];

	MemberDataLogic *memberData = MSHookIvar<MemberDataLogic *>(self,"m_memberData");
	NSUInteger sectionCount = [memberData getSectionCount];
	[self.filterRoomDic enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull usrName, NSString *  _Nonnull aliasName, BOOL * _Nonnull stop) {
        BOOL isBreak = NO;
    	for(int i = 0; i < sectionCount; i++){
    		NSUInteger rowCount = [memberData getSectionItemCount:i];
    		for(int j = 0; j < rowCount; j++){
    			CContact *contact = [memberData getItemInSection:i atRow:j];
    			if([contact.m_nsUsrName isEqualToString:usrName]){
                    isBreak = YES;
    				[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    break;
    			}
    		}
            if(isBreak){
                break;
            }
    	}
    }];
}

%new
- (void)setNavigationBar{
    self.title = @"过滤群聊设置";
    
    UIBarButtonItem *confirmItem = [NSClassFromString(@"MMUICommonUtil") getBarButtonWithTitle:@"确定" target:self action:@selector(clickConfirmItem) style:0 color:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = confirmItem;
}

%new
- (void)clickConfirmItem{
	MMTableView *tableView = MSHookIvar<MMTableView *>(self,"m_tableView");
	MemberDataLogic *memberData = MSHookIvar<MemberDataLogic *>(self,"m_memberData");
	NSMutableDictionary *filterRoomDic = [NSMutableDictionary dictionary];
	[[tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		CContact *contact = [memberData getItemInSection:obj.section atRow:obj.row];
        if(contact.m_nsUsrName){
        	[filterRoomDic setObject:contact.m_nsAliasName?:@"alias" forKey:contact.m_nsUsrName];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kConfirmFilterChatRoomNotification" object:filterRoomDic];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (int)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

%end
