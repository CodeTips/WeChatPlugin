//
//  LLSettingController.m
//  test
//
//  Created by fqb on 2017/12/15.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLSettingController.h"
#import "WCRedEnvelopesHelper.h"
#import "LLRedEnvelopesMgr.h"
#import <objc/runtime.h>

static NSString * const kSettingControllerKey = @"SettingControllerKey";

@interface LLSettingController () <MMPickLocationViewControllerDelegate>

@property (nonatomic, strong) LLSettingParam *settingParam; //设置参数

@property (nonatomic, strong) ContactsDataLogic *contactsDataLogic;

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;
@property (nonatomic, strong) MMPickLocationViewController *pickLocationController;

@end

@implementation LLSettingParam

@end

@implementation LLSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self setNavigationBar];
    [self setTableView];
    [self reloadTableData];
}

- (void)commonInit{
    _settingParam = [[LLSettingParam alloc] init];

    LLRedEnvelopesMgr *manager = [LLRedEnvelopesMgr shared];
    _settingParam.isOpenRedEnvelopesHelper = manager.isOpenRedEnvelopesHelper;
    _settingParam.isOpenSportHelper = manager.isOpenSportHelper;
    _settingParam.isOpenBackgroundMode = manager.isOpenBackgroundMode;
    _settingParam.isOpenRedEnvelopesAlert = manager.isOpenRedEnvelopesAlert;
    _settingParam.openRedEnvelopesDelaySecond = manager.openRedEnvelopesDelaySecond;
    _settingParam.isOpenVirtualLocation = manager.isOpenVirtualLocation;
    _settingParam.isOpenAutoReply = manager.isOpenAutoReply;
    _settingParam.isOpenAutoLeaveMessage = manager.isOpenAutoLeaveMessage;
    _settingParam.autoReplyText = manager.autoReplyText;
    _settingParam.autoLeaveMessageText = manager.autoLeaveMessageText;
    _settingParam.isOpenKeywordFilter = manager.isOpenKeywordFilter;
    _settingParam.keywordFilterText = manager.keywordFilterText;
    _settingParam.isSnatchSelfRedEnvelopes = manager.isSnatchSelfRedEnvelopes;
    _settingParam.isOpenAvoidRevokeMessage = manager.isOpenAvoidRevokeMessage;
    _settingParam.sportStepCountMode = manager.sportStepCountMode;
    _settingParam.sportStepCountUpperLimit = manager.sportStepCountUpperLimit;
    _settingParam.sportStepCountLowerLimit = manager.sportStepCountLowerLimit;
    _settingParam.wantSportStepCount = manager.wantSportStepCount;
    _settingParam.filterRoomDic = manager.filterRoomDic;
    _settingParam.virtualLocation = manager.virtualLocation;

    _contactsDataLogic = [[NSClassFromString(@"ContactsDataLogic") alloc] initWithScene:0x0 delegate:nil sort:0x1 extendChatRoom:0x0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfirmFilterChatRoom:) name:@"kConfirmFilterChatRoomNotification" object:nil];
}

- (void)setNavigationBar{
    self.title = @"微信助手设置";
    
    UIBarButtonItem *saveItem = [NSClassFromString(@"MMUICommonUtil") getBarButtonWithTitle:@"保存" target:self action:@selector(clickSaveItem) style:0 color:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)exchangeMethod{
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"MMTableViewCellInfo"), @selector(actionEditorCell:)), class_getInstanceMethod([LLSettingController class], @selector(onTextFieldEditChanged:)));
}

- (void)setTableView{
    _tableViewInfo = [[NSClassFromString(@"MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:0];
    [self.view addSubview:[_tableViewInfo getTableView]];
    [_tableViewInfo setDelegate:self];
    if (@available(iOS 11, *)) {         
        [_tableViewInfo getTableView].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;             
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
}

- (void)reloadTableData{
    MMTableViewCellInfo *openRedEnvelopesCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openRedEnvelopesSwitchHandler:) target:self title:@"是否开启红包助手" on:_settingParam.isOpenRedEnvelopesHelper];
    MMTableViewCellInfo *backgroundModeCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openBackgroundMode:) target:self title:@"是否开启后台模式" on:_settingParam.isOpenBackgroundMode];
    MMTableViewCellInfo *openAlertCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openRedEnvelopesAlertHandler:) target:self title:@"是否开启红包提醒" on:_settingParam.isOpenRedEnvelopesAlert];
    MMTableViewCellInfo *delayTimeCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"延迟秒数" margin:120 tip:@"请输入延迟抢红包秒数" focus:NO autoCorrect:NO text:[NSString stringWithFormat:@"%.2f",_settingParam.openRedEnvelopesDelaySecond] isFitIpadClassic:YES];
    [delayTimeCell addUserInfoValue:@(UIKeyboardTypeDecimalPad) forKey:@"keyboardType"];
    [delayTimeCell addUserInfoValue:@"delayTimeCell" forKey:@"cellType"];
    MMTableViewCellInfo *filterRoomCell = [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(onfilterRoomCellClicked) target:self title:@"过滤群聊" rightValue:self.settingParam.filterRoomDic.count?[NSString stringWithFormat:@"已选%ld个群聊",(long)self.settingParam.filterRoomDic.count]:@"暂未选择" accessoryType:1];
    objc_setAssociatedObject(delayTimeCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *openAutoReplyCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openAutoReplySwitchHandler:) target:self title:@"红包领取后自动回复" on:_settingParam.isOpenAutoReply];
    MMTableViewCellInfo *autoReplyTextCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"自动回复内容" margin:120 tip:@"请输入自动回复内容" focus:NO autoCorrect:NO text:_settingParam.autoReplyText isFitIpadClassic:YES];
    [autoReplyTextCell addUserInfoValue:@"autoReplyTextCell" forKey:@"cellType"];
    objc_setAssociatedObject(autoReplyTextCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *openAutoLeaveMessageCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openAutoLeaveMessageSwitchHandler:) target:self title:@"红包领取后自动留言" on:_settingParam.isOpenAutoLeaveMessage];
    MMTableViewCellInfo *autoLeaveMessageTextCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"自动留言内容" margin:120 tip:@"请输入自动留言内容" focus:NO autoCorrect:NO text:_settingParam.autoLeaveMessageText isFitIpadClassic:YES];
    [autoLeaveMessageTextCell addUserInfoValue:@"autoLeaveMessageTextCell" forKey:@"cellType"];
    objc_setAssociatedObject(autoLeaveMessageTextCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *openKeywordFilterCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openKeywordFilterSwitchHandler:) target:self title:@"是否打开关键字过滤" on:_settingParam.isOpenKeywordFilter];
    MMTableViewCellInfo *keywordFilterTextCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"关键字过滤" margin:120 tip:@"多个关键字以英文逗号分隔" focus:NO autoCorrect:NO text:_settingParam.keywordFilterText isFitIpadClassic:YES];
    [keywordFilterTextCell addUserInfoValue:@"keywordFilterTextCell" forKey:@"cellType"];
    objc_setAssociatedObject(keywordFilterTextCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *isSnatchSelfCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(isSnatchSelfRedEnvelopesSwitchHandler:) target:self title:@"是否抢自己发的红包" on:_settingParam.isSnatchSelfRedEnvelopes];

    MMTableViewSectionInfo *redEnvelopesSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [redEnvelopesSection setHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,20)]];
    [redEnvelopesSection addCell:openRedEnvelopesCell];
    [redEnvelopesSection addCell:backgroundModeCell];
    [redEnvelopesSection addCell:openAlertCell];
    [redEnvelopesSection addCell:delayTimeCell];
    [redEnvelopesSection addCell:filterRoomCell];
    [redEnvelopesSection addCell:openAutoReplyCell];
    [redEnvelopesSection addCell:autoReplyTextCell];
    [redEnvelopesSection addCell:openAutoLeaveMessageCell];
    [redEnvelopesSection addCell:autoLeaveMessageTextCell];
    [redEnvelopesSection addCell:openKeywordFilterCell];
    [redEnvelopesSection addCell:keywordFilterTextCell];
    [redEnvelopesSection addCell:isSnatchSelfCell];

    MMTableViewCellInfo *openVirtualLocationCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openVirtualLocationSwitchHandler:) target:self title:@"是否开启虚拟定位" on:_settingParam.isOpenVirtualLocation];
    MMTableViewCellInfo *selectVirtualLocationCell = [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(onVirtualLocationCellClicked) target:self title:@"选择虚拟位置" rightValue:_settingParam.virtualLocation.poiName?:@"暂未选择" accessoryType:1];
    
    MMTableViewSectionInfo *virtualLocationSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [virtualLocationSection setHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,20)]];
    [virtualLocationSection addCell:openVirtualLocationCell];
    [virtualLocationSection addCell:selectVirtualLocationCell];

    MMTableViewCellInfo *openStepCountCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openStepCountSwitchHandler:) target:self title:@"是否开启运动助手" on:_settingParam.isOpenSportHelper];
    MMTableViewCellInfo *stepCountModeCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(stepCountModeSwitchHandler:) target:self title:@"范围随机/固定步数" on:_settingParam.sportStepCountMode];
    MMTableViewCellInfo *stepCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"固定运动步数" margin:120 tip:@"请输入想要的运动步数" focus:NO autoCorrect:NO text:[NSString stringWithFormat:@"%ld",(long)_settingParam.wantSportStepCount] isFitIpadClassic:YES];
    [stepCell addUserInfoValue:@(UIKeyboardTypeNumberPad) forKey:@"keyboardType"];
    [stepCell addUserInfoValue:@"stepCell" forKey:@"cellType"];
    objc_setAssociatedObject(stepCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *stepUpperLimitCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"运动步数上限" margin:120 tip:@"请输入运动步数上限" focus:NO autoCorrect:NO text:[NSString stringWithFormat:@"%ld",(long)_settingParam.sportStepCountUpperLimit] isFitIpadClassic:YES];
    [stepUpperLimitCell addUserInfoValue:@(UIKeyboardTypeNumberPad) forKey:@"keyboardType"];
    [stepUpperLimitCell addUserInfoValue:@"stepUpperLimitCell" forKey:@"cellType"];
    objc_setAssociatedObject(stepUpperLimitCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *stepLowerLimitCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"运动步数下限" margin:120 tip:@"请输入运动步数下限" focus:NO autoCorrect:NO text:[NSString stringWithFormat:@"%ld",(long)_settingParam.sportStepCountLowerLimit] isFitIpadClassic:YES];
    [stepLowerLimitCell addUserInfoValue:@(UIKeyboardTypeNumberPad) forKey:@"keyboardType"];
    [stepLowerLimitCell addUserInfoValue:@"stepLowerLimitCell" forKey:@"cellType"];
    objc_setAssociatedObject(stepLowerLimitCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);

    MMTableViewSectionInfo *stepCountSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [stepCountSection setHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,20)]];
    [stepCountSection addCell:openStepCountCell];
    [stepCountSection addCell:stepCountModeCell];
    if(_settingParam.sportStepCountMode){
        [stepCountSection addCell:stepUpperLimitCell];
        [stepCountSection addCell:stepLowerLimitCell];
    } else {
        [stepCountSection addCell:stepCell];
    }

    MMTableViewCellInfo *openAvoidRevokeMessageCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openAvoidRevokeMessageSwitchHandler:) target:self title:@"是否防好友撤回消息" on:_settingParam.isOpenAvoidRevokeMessage];

    MMTableViewSectionInfo *revokeMessageSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [revokeMessageSection setHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,20)]];
    [revokeMessageSection addCell:openAvoidRevokeMessageCell];

    [_tableViewInfo clearAllSection];

    [_tableViewInfo addSection:redEnvelopesSection];
    [_tableViewInfo addSection:virtualLocationSection];
    [_tableViewInfo addSection:stepCountSection];
    [_tableViewInfo addSection:revokeMessageSection];
    
    [[_tableViewInfo getTableView] reloadData];
}

//点击保存
- (void)clickSaveItem{
    LLRedEnvelopesMgr *manager = [LLRedEnvelopesMgr shared];
    manager.isOpenRedEnvelopesHelper = _settingParam.isOpenRedEnvelopesHelper;
    manager.isOpenSportHelper = _settingParam.isOpenSportHelper;
    manager.isOpenBackgroundMode = _settingParam.isOpenBackgroundMode;
    manager.isOpenRedEnvelopesAlert = _settingParam.isOpenRedEnvelopesAlert;
    manager.openRedEnvelopesDelaySecond = _settingParam.openRedEnvelopesDelaySecond;
    manager.isOpenVirtualLocation = _settingParam.isOpenVirtualLocation;
    manager.isOpenAutoReply = _settingParam.isOpenAutoReply;
    manager.isOpenAutoLeaveMessage = _settingParam.isOpenAutoLeaveMessage;
    manager.autoReplyText = _settingParam.autoReplyText;
    manager.autoLeaveMessageText = _settingParam.autoLeaveMessageText;
    manager.isOpenKeywordFilter = _settingParam.isOpenKeywordFilter;
    manager.keywordFilterText = _settingParam.keywordFilterText;
    manager.isSnatchSelfRedEnvelopes = _settingParam.isSnatchSelfRedEnvelopes;
    manager.isOpenAvoidRevokeMessage = _settingParam.isOpenAvoidRevokeMessage;
    manager.sportStepCountMode = _settingParam.sportStepCountMode;
    manager.sportStepCountUpperLimit = _settingParam.sportStepCountUpperLimit;
    manager.sportStepCountLowerLimit = _settingParam.sportStepCountLowerLimit;
    manager.wantSportStepCount = _settingParam.wantSportStepCount;
    manager.filterRoomDic = _settingParam.filterRoomDic;
    [manager saveVirtualLocation:_settingParam.virtualLocation];
    [manager saveUserSetting]; // 保存用户设置
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openRedEnvelopesSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenRedEnvelopesHelper = openSwitch.on;
}

- (void)openBackgroundMode:(UISwitch *)backgroundMode{
    _settingParam.isOpenBackgroundMode = backgroundMode.on;
}

- (void)openRedEnvelopesAlertHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenRedEnvelopesAlert = openSwitch.on;
}

- (void)openAutoReplySwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenAutoReply = openSwitch.on;
}

- (void)openAutoLeaveMessageSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenAutoLeaveMessage = openSwitch.on;
}

- (void)openKeywordFilterSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenKeywordFilter = openSwitch.on;
}

- (void)onTextFieldEditChanged:(UITextField *)textField{
    LLSettingController *settingController = objc_getAssociatedObject(self, &kSettingControllerKey);
    MMTableViewCellInfo *cellInfo = (MMTableViewCellInfo *)self;
    NSString *cellType = [cellInfo getUserInfoValueForKey:@"cellType"];
    if([cellType isEqualToString:@"delayTimeCell"]){
        settingController.settingParam.openRedEnvelopesDelaySecond = [textField.text floatValue];
    } else if ([cellType isEqualToString:@"stepCell"]){
        settingController.settingParam.wantSportStepCount = [textField.text integerValue];
    } else if ([cellType isEqualToString:@"autoReplyTextCell"]){
        settingController.settingParam.autoReplyText = textField.text;
    } else if ([cellType isEqualToString:@"autoLeaveMessageTextCell"]){
        settingController.settingParam.autoLeaveMessageText = textField.text;
    } else if ([cellType isEqualToString:@"keywordFilterTextCell"]){
        settingController.settingParam.keywordFilterText = textField.text;
    } else if ([cellType isEqualToString:@"stepUpperLimitCell"]){
        settingController.settingParam.sportStepCountUpperLimit = [textField.text integerValue];
    } else if ([cellType isEqualToString:@"stepLowerLimitCell"]){
        settingController.settingParam.sportStepCountLowerLimit = [textField.text integerValue];
    } 
}

- (void)openVirtualLocationSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenVirtualLocation = openSwitch.on;
}

- (void)onVirtualLocationCellClicked{
    _pickLocationController = [[NSClassFromString(@"MMPickLocationViewController") alloc] initWithScene:0 OnlyUseUserLocation:NO];
    _pickLocationController.delegate = self;
    MMUINavigationController *navController = [[NSClassFromString(@"MMUINavigationController") alloc] initWithRootViewController:_pickLocationController];
    [self PresentModalViewController:navController animated:YES];
}

- (void)openStepCountSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenSportHelper = openSwitch.on;
}

- (void)stepCountModeSwitchHandler:(UISwitch *)modeSwitch{
    _settingParam.sportStepCountMode = modeSwitch.on;
    [self reloadTableData]; //刷新页面
}

- (void)isSnatchSelfRedEnvelopesSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isSnatchSelfRedEnvelopes = openSwitch.on;
}

- (void)onfilterRoomCellClicked{
    LLFilterChatRoomController *chatRoomVC = [[NSClassFromString(@"LLFilterChatRoomController") alloc] init];
    MemberDataLogic *dataLogic = [[NSClassFromString(@"MemberDataLogic") alloc] initWithMemberList:[_contactsDataLogic getChatRoomContacts] admin:0x0];
    [chatRoomVC setMemberLogic:dataLogic];
    chatRoomVC.filterRoomDic = _settingParam.filterRoomDic;
    [self.navigationController PushViewController:chatRoomVC animated:YES];
}

- (void)openAvoidRevokeMessageSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenAvoidRevokeMessage = openSwitch.on;
}

- (void)onGithubCellClicked{
    NSURL *myGithubURL = [NSURL URLWithString:@"https://github.com/kevll/WeChatRedEnvelopesHelper"];
    MMWebViewController *githubWebVC = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:myGithubURL presentModal:NO extraInfo:nil delegate:nil];
    [self.navigationController PushViewController:githubWebVC animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)onConfirmFilterChatRoom:(NSNotification *)notify{
    _settingParam.filterRoomDic = notify.object;
    [self reloadTableData]; //刷新页面
}

- (void)onPickLocationControllerConfirmClicked{
    [_pickLocationController DismissMyselfAnimated:YES];
    POIInfo *currentPOIInfo = [_pickLocationController getCurrentPOIInfo];
    _settingParam.virtualLocation = currentPOIInfo;
    [_pickLocationController reportOnDone];
    [self reloadTableData]; //刷新页面
}

#pragma mark - MMPickLocationViewControllerDelegate

- (UIBarButtonItem *)onGetRightBarButton{
    return [NSClassFromString(@"MMUICommonUtil") getBarButtonWithTitle:@"确定" target:self action:@selector(onPickLocationControllerConfirmClicked) style:0];
}

- (void)onCancelSeletctedLocation{
    [_pickLocationController DismissMyselfAnimated:YES];
    [_pickLocationController reportOnDone];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self exchangeMethod];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self exchangeMethod]; //reset
}

- (void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
