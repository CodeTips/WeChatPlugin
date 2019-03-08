#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class CMessageWrap;

#pragma mark - Util

@interface WCBizUtil : NSObject

+ (id)dictionaryWithDecodedComponets:(id)arg1 separator:(id)arg2;

@end

@interface SKBuiltinBuffer_t : NSObject

@property(retain, nonatomic) NSData *buffer; // @dynamic buffer;

@end

#pragma mark - Manager

@interface MMNewSessionMgr : NSObject
- (unsigned int)GenSendMsgTime;
@end

#pragma mark - Message


@interface FriendAsistSessionMgr : NSObject
- (id)GetLastMessage:(id)arg1 HelloUser:(id)arg2 OnlyTo:(BOOL)arg3;
@end

@interface AutoSetRemarkMgr : NSObject
- (id)GetStrangerAttribute:(id)arg1 AttributeName:(int)arg2;
@end

@interface CMessageMgr : NSObject

- (id)GetMsg:(id)arg1 n64SvrID:(long long)arg2;
- (void)AsyncOnSpecialSession:(id)arg1 MsgList:(id)arg2;
- (id)GetHelloUsers:(id)arg1 Limit:(unsigned int)arg2 OnlyUnread:(BOOL)arg3;

- (void)DelMsg:(id)arg1 MsgList:(id)arg2 DelAll:(BOOL)arg3;
- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2;
- (void)onRevokeMsg:(id)arg1;
- (id)GetMsgByCreateTime:(id)arg1 FromID:(unsigned int)arg2 FromCreateTime:(unsigned int)arg3 Limit:(unsigned int)arg4 LeftCount:(unsigned int *)arg5 FromSequence:(unsigned int)arg6;
- (void)AddLocalMsg:(id)arg1 MsgWrap:(id)arg2 fixTime:(BOOL)arg3 NewMsgArriveNotify:(BOOL)arg4;
- (void)AsyncOnAddMsg:(id)arg1 MsgWrap:(id)arg2;
- (void)MessageReturn:(unsigned int)arg1 MessageInfo:(id)arg2 Event:(unsigned int)arg3;
- (void)UpdateMessage:(id)arg1 MsgWrap:(id)arg2;
- (void)AddEmoticonMsg:(id)arg1 MsgWrap:(id)arg2;

- (void)sendMsg:(NSString *)msg toContactUsrName:(NSString *)userName;

@end

@interface CGroupMgr : NSObject
- (BOOL)SetChatRoomDesc:(id)arg1 Desc:(id)arg2 Flag:(unsigned int)arg3;
- (BOOL)CreateGroup:(id)arg1 withMemberList:(id)arg2;
- (BOOL)DeleteGroupMember:(id)arg1 withMemberList:(id)arg2 scene:(unsigned long long)arg3;
@end

@interface MMLanguageMgr: NSObject

- (id)getStringForCurLanguage:(id)arg1 defaultTo:(id)arg2;


@end

#pragma mark - RedEnvelop


@interface WCRedEnvelopesLogicMgr: NSObject

- (void)OpenRedEnvelopesRequest:(id)params;
- (void)ReceiverQueryRedEnvelopesRequest:(id)arg1;
- (void)GetHongbaoBusinessRequest:(id)arg1 CMDID:(unsigned int)arg2 OutputType:(unsigned int)arg3;
- (void)OnWCToHongbaoCommonResponse:(id)arg1 Request:(id)arg2;

/** Added Methods */
- (unsigned int)calculateDelaySeconds;

@end

@interface HongBaoRes : NSObject

@property(retain, nonatomic) SKBuiltinBuffer_t *retText; // @dynamic retText;
@property(nonatomic) int cgiCmdid; // @dynamic cgiCmdid;

@end

@interface HongBaoReq : NSObject

@property(retain, nonatomic) SKBuiltinBuffer_t *reqText; // @dynamic reqText;

@end

#pragma mark - Contact

@interface GroupMember : NSObject
@property(copy, nonatomic) NSString *m_nsNickName;; // @synthesize m_nsNickName;
@property(nonatomic) unsigned int m_uiMemberStatus; // @synthesize m_uiMemberStatus;
@property(copy, nonatomic) NSString *m_nsMemberName; // @synthesize m_nsMemberName;
@end

#pragma mark - QRCode

@interface ScanQRCodeLogicController: NSObject

@property(nonatomic) unsigned int fromScene;
- (id)initWithViewController:(id)arg1 CodeType:(int)arg2;
- (void)tryScanOnePicture:(id)arg1;
- (void)doScanQRCode:(id)arg1;
- (void)showScanResult;

@end

@interface NewQRCodeScanner: NSObject

- (id)initWithDelegate:(id)arg1 CodeType:(int)arg2;
- (void)notifyResult:(id)arg1 type:(id)arg2 version:(int)arg3;

@end

#pragma mark - MMTableView


@interface SettingUtil : NSObject
+ (id)getLocalUsrName:(unsigned int)arg1;
@end

@interface MMLoadingView : UIView

@property(retain, nonatomic) UILabel *m_label; // @synthesize m_label;
@property (assign, nonatomic) BOOL m_bIgnoringInteractionEventsWhenLoading; // @synthesize m_bIgnoringInteractionEventsWhenLoading;

- (void)setFitFrame:(long long)arg1;
- (void)startLoading;
- (void)stopLoading;
- (void)stopLoadingAndShowError:(id)arg1;
- (void)stopLoadingAndShowOK:(id)arg1;


@end

@interface MMTextView : UITextView
@property(retain, nonatomic) NSString *placeholder;
@end


@interface ContactSelectView : UIView

@property(nonatomic) unsigned int m_uiGroupScene; // @synthesize m_uiGroupScene;
@property(nonatomic) BOOL m_bMultiSelect; // @synthesize m_bMultiSelect;
@property(retain, nonatomic) NSMutableDictionary *m_dicMultiSelect; // @synthesize m_dicMultiSelect;

- (id)initWithFrame:(struct CGRect)arg1 delegate:(id)arg2;
- (void)initData:(unsigned int)arg1;
- (void)initView;
- (void)addSelect:(id)arg1;

@property(nonatomic) BOOL m_bShowHistoryGroup; // @synthesize m_bShowHistoryGroup;
@property(nonatomic) BOOL m_bShowRadarCreateRoom; // @synthesize m_bShowRadarCreateRoom;
@property(retain, nonatomic) NSDictionary *m_dicExistContact; // @synthesize m_dicExistContact;
- (void)initSearchBar;
- (void)makeGroupCell:(id)arg1 head:(id)arg2 title:(id)arg3;

@end

#pragma mark - Logic

@interface SayHelloDataLogic : NSObject
@property (nonatomic, strong) NSMutableArray *m_arrHellos;
- (void)loadData:(unsigned int)arg1;
+ (id)getContactFrom:(id)arg1;
- (id)getContactForIndex:(unsigned int)arg1;
- (void)onFriendAssistAddMsg:(NSArray *)arg1;
@end

@interface CContactVerifyLogic : NSObject
- (void)startWithVerifyContactWrap:(id)arg1
                            opCode:(unsigned int)arg2
                        parentView:(id)arg3
                      fromChatRoom:(BOOL)arg4;
@end

@interface SKBuiltinString_t : NSObject
// Remaining properties
@property(copy, nonatomic) NSString *string; // @dynamic string;
@end

@interface CreateChatRoomResponse : NSObject
@property(strong, nonatomic) SKBuiltinString_t *chatRoomName; // @dynamic chatRoomName;
@end



#pragma mark - UtilCategory

@interface NSMutableDictionary (SafeInsert)

- (void)safeSetObject:(id)arg1 forKey:(id)arg2;

@end

@interface NSDictionary (NSDictionary_SafeJSON)

- (id)arrayForKey:(id)arg1;
- (id)dictionaryForKey:(id)arg1;
- (double)doubleForKey:(id)arg1;
- (float)floatForKey:(id)arg1;
- (long long)int64ForKey:(id)arg1;
- (long long)integerForKey:(id)arg1;
- (id)stringForKey:(id)arg1;

@end

@interface NSString (NSString_SBJSON)

- (id)JSONArray;
- (id)JSONDictionary;
- (id)JSONValue;

@end


@protocol MultiSelectContactsViewControllerDelegate <NSObject>
- (void)onMultiSelectContactReturn:(NSArray *)arg1;

@optional
- (int)getFTSCommonScene;
- (void)onMultiSelectContactCancelForSns;
- (void)onMultiSelectContactReturnForSns:(NSArray *)arg1;
@end

@interface MultiSelectContactsViewController : UIViewController

@property(nonatomic) BOOL m_bKeepCurViewAfterSelect; // @synthesize m_bKeepCurViewAfterSelect=_m_bKeepCurViewAfterSelect;
@property(nonatomic) unsigned int m_uiGroupScene; // @synthesize m_uiGroupScene;
@property(nonatomic, weak) id <MultiSelectContactsViewControllerDelegate> m_delegate; // @synthesize m_delegate;

@end

@interface WCPayInfoItem: NSObject
@property(nonatomic) unsigned int m_sceneId; // @synthesize m_sceneId;
@property(nonatomic) unsigned int m_uiPaySubType; // @synthesize m_uiPaySubType;
@property(retain, nonatomic) NSString *m_nsPayMsgID; // @synthesize m_nsPayMsgID;
@property(retain, nonatomic) NSString *m_c2cNativeUrl;
- (NSString *)m_nsPayMsgID;
@end

#pragma mark - Message

@interface CMessageWrap : NSObject

@property(nonatomic) unsigned int m_uiMessageType; // @synthesize m_uiMessageType;
@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;
@property(nonatomic) long long m_n64MesSvrID; // @synthesize m_n64MesSvrID;
@property(nonatomic) unsigned int m_uiMesLocalID; // @synthesize m_uiMesLocalID;
@property(nonatomic) unsigned int m_uiCreateTime; // @synthesize m_uiCreateTime;
@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsToUsr;
@property(retain, nonatomic) WCPayInfoItem *m_oWCPayInfoItem; // @dynamic m_oWCPayInfoItem;
@property(nonatomic) unsigned int m_uiAppMsgInnerType; // @dynamic m_uiAppMsgInnerType;
@property (assign, nonatomic) NSUInteger m_uiStatus;
@property (retain, nonatomic) NSString* m_nsRealChatUsr;        ///< 群消息的发信人，具体是群里的哪个人
@property (retain, nonatomic) NSString *m_nsDesc;
@property (retain, nonatomic) NSString *m_nsAppExtInfo;
@property (assign, nonatomic) NSUInteger m_uiAppDataSize;
@property (retain, nonatomic) NSString *m_nsShareOpenUrl;
@property (retain, nonatomic) NSString *m_nsShareOriginUrl;
@property (retain, nonatomic) NSString *m_nsJsAppId;
@property (retain, nonatomic) NSString *m_nsPrePublishId;
@property (retain, nonatomic) NSString *m_nsAppID;
@property (retain, nonatomic) NSString *m_nsAppName;
@property (retain, nonatomic) NSString *m_nsThumbUrl;
@property (retain, nonatomic) NSString *m_nsAppMediaUrl;
@property (retain, nonatomic) NSData *m_dtThumbnail;
@property (retain, nonatomic) NSString *m_nsTitle;
@property (retain, nonatomic) NSString *m_nsMsgSource;

@property (nonatomic, copy) NSString *m_nsLastDisplayContent;
@property (nonatomic, copy) NSString *m_nsPushContent;

@property(nonatomic) unsigned int m_uiGameType;     // 游戏类型
@property(nonatomic) unsigned int m_uiGameContent;  // 游戏内容

- (id)initWithMsgType:(long long)arg1;
- (WCPayInfoItem *)m_oWCPayInfoItem;
- (id)nativeUrl;
- (NSString *)wishingString;
- (BOOL)IsSendBySendMsg;
+ (BOOL)isSenderFromMsgWrap:(CMessageWrap *)msgWrap;

@end




@interface CBaseContact : NSObject

@property(retain, nonatomic) NSString *m_nsAliasName; // @synthesize m_nsAliasName;
@property(retain, nonatomic) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl; // @synthesize m_nsHeadImgUrl;
@property (nonatomic, copy) NSString *m_nsOwner;                        // 拥有者
@property (nonatomic, copy) NSString *m_nsMemberName;
@property (nonatomic, copy) NSString *m_nsEncodeUserName;                // 微信用户名转码
@property (nonatomic, assign) int m_uiFriendScene;                       // 是否是自己的好友(非订阅号、自己)
@property (nonatomic,assign) BOOL m_isPlugin;                            // 是否为微信插件

- (BOOL)isChatroom;
- (BOOL)isEqualToContact:(id)arg1;
- (id)getContactDisplayName;
- (id)getChatRoomMemberWithoutMyself:(id)arg1;
@end

@interface CContact: CBaseContact

@property (nonatomic, copy) NSString *m_nsNickName;                     // 用户昵称
@end

@interface CContactMgr: NSObject

- (id)getContactByName:(id)arg1;
- (id)getAllContactUserName;
- (id)getSelfContact;
- (id)getContactForSearchByName:(id)arg1;
- (BOOL)getContactsFromServer:(id)arg1;
- (BOOL)isInContactList:(id)arg1;
- (BOOL)addLocalContact:(id)arg1 listType:(unsigned int)arg2;
- (id)getContactList:(unsigned int)arg1 contactType:(unsigned int)arg2;

@end

@interface MMSessionInfo : NSObject

@property(retain, nonatomic) CMessageWrap *m_msgWrap; // @synthesize m_msgWrap;
@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;

@end

@interface UIViewController (ModalView)

- (void)PresentModalViewController:(id)arg1 animated:(BOOL)arg2;
- (void)DismissMyselfAnimated:(BOOL)arg1;

@end

@interface NewMainFrameViewController : UIViewController
{
    UITableView *m_tableView;
}

- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (void)openRedEnvelopes;

@end

@interface BaseMsgContentViewController : UIViewController

{
    UITableView *m_tableView;
}
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (void)tapAppNodeView:(id)arg1;
- (CContact *)getChatContact;
- (void)AsyncSendMessage:(NSString *)message;

- (id)GetContact;

- (void)backToWebViewController;

@end

@interface MMUINavigationController : UINavigationController

- (id)initWithRootViewController:(id)arg1;

@end

@interface UINavigationController (LogicController)

- (void)PushViewController:(id)arg1 animated:(BOOL)arg2;

@end

@interface WCRedEnvelopesReceiveControlLogic : NSObject

- (void)OnCommitWCRedEnvelopes:(NSString *)arg1;

@end

@interface WCRedEnvelopesReceiveHomeView : UIView

- (void)OnOpenRedEnvelopes;

@end

@protocol WCRedEnvelopesRedEnvelopesDetailViewControllerDelegate <NSObject>

- (void)OnCommitWCRedEnvelopes:(NSString *)arg1;

@end

@interface WCRedEnvelopesRedEnvelopesDetailViewController : UIViewController

@end

@interface MMTableView: UITableView

- (void)setTableHeaderView:(UIView *)view;

@end

@interface MMUIViewController : UIViewController

- (void)startLoadingBlocked;
- (void)startLoadingNonBlock;
- (void)startLoadingWithText:(NSString *)text;
- (void)stopLoading;
- (void)stopLoadingWithFailText:(NSString *)text;
- (void)stopLoadingWithOKText:(NSString *)text;

@end

@interface MMWindowViewController : MMUIViewController
@end

@interface OnlineDeviceInfoViewController : MMWindowViewController

- (id)makeControlButtonWithTitle:(id)arg1 image:(id)arg2 highlightedImage:(id)arg3 target:(id)arg4 action:(SEL)arg5;
- (void)setupRemoteBtn;

@end

@interface NewSettingViewController: MMUIViewController

- (void)reloadTableData;
- (void)setting;
- (void)simplifySetting;
- (void)groupSetting;

@end

@interface CPushContact : CContact
@property (nonatomic, copy) NSString *m_nsChatRoomUserName;
@property (nonatomic, copy) NSString *m_nsDes;
@property (nonatomic, copy) NSString *m_nsSource;
@property (nonatomic, copy) NSString *m_nsSourceNickName;
@property (nonatomic, copy) NSString *m_nsSourceUserName;
@property (nonatomic, copy) NSString *m_nsTicket;
- (BOOL)isMyContact;
@end

@interface CVerifyContactWrap : NSObject
@property (nonatomic, copy) NSString *m_nsChatRoomUserName;
@property (nonatomic, copy) NSString *m_nsOriginalUsrName;
@property (nonatomic, copy) NSString *m_nsSourceNickName;
@property (nonatomic, copy) NSString *m_nsSourceUserName;
@property (nonatomic, copy) NSString *m_nsTicket;
@property (nonatomic, copy) NSString *m_nsUsrName;
@property (nonatomic, strong) CContact *m_oVerifyContact;
@property (nonatomic, assign) unsigned int m_uiScene;
@property (nonatomic, assign) unsigned int m_uiWCFlag;
@end
@protocol ContactSelectViewDelegate <NSObject>

- (void)onSelectContact:(CContact *)arg1;

@end

@interface SayHelloViewController : UIViewController
@property (nonatomic, strong) SayHelloDataLogic *m_DataLogic;
- (void)OnSayHelloDataVerifyContactOK:(CPushContact *)arg1;
@end

@interface ContactInfoViewController : MMUIViewController

@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;

@end

@interface MMTableViewInfo : NSObject

- (void)setDelegate:(id)delegate;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
- (MMTableView *)getTableView;
- (void)clearAllSection;
- (void)addSection:(id)arg1;
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;
- (id)getSectionAt:(int)arg1;

@property(nonatomic,assign) id delegate;

@end

@interface MMTableViewSectionInfo : NSObject

+ (id)sectionInfoDefaut;
- (void)addCell:(id)arg1;
- (void)setHeaderView:(UIView *)headerView;
- (void)setFHeaderHeight:(CGFloat)height;
+ (id)sectionInfoHeader:(id)arg1;
+ (id)sectionInfoHeader:(id)arg1 Footer:(id)arg2;

- (void)removeCellAt:(unsigned long long)arg1;
- (unsigned long long)getCellCount;

@end

@interface WCTableViewCellManager : NSObject

+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(BOOL)arg4;
@property(retain, nonatomic) id userInfo; // @synthesize userInfo=_userInfo;

@end

@interface WCTableViewNormalCellManager : WCTableViewCellManager
+ (WCTableViewNormalCellManager *)urlInnerCellForTitle:(id)arg1 url:(id)arg2;
+ (WCTableViewNormalCellManager *)urlInnerBlueCellForTitle:(id)arg1 rightValue:(id)arg2 url:(id)arg3;
+ (double)getAutoSizingRightMargin:(id)arg1;
+ (WCTableViewNormalCellManager *)badgeCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 badge:(id)arg4 rightValue:(id)arg5 imageName:(id)arg6;
+ (WCTableViewNormalCellManager *)badgeCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 badge:(id)arg4 rightValue:(id)arg5;
+ (WCTableViewNormalCellManager *)badgeCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 badge:(id)arg4;
+ (WCTableViewNormalCellManager *)editorCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 tip:(id)arg4 focus:(BOOL)arg5 autoCorrect:(BOOL)arg6 text:(id)arg7;
+ (WCTableViewNormalCellManager *)normalCellForTitle:(id)arg1 rightValue:(id)arg2 imageName:(id)arg3;
+ (WCTableViewNormalCellManager *)normalCellForTitle:(id)arg1 rightValue:(id)arg2;
+ (WCTableViewNormalCellManager *)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 accessoryType:(long long)arg4;
+ (WCTableViewNormalCellManager *)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 detail:(id)arg4 imageName:(id)arg5 accessoryType:(long long)arg6;
+ (WCTableViewNormalCellManager *)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 rightValue:(id)arg4 imageName:(id)arg5 accessoryType:(long long)arg6;
+ (WCTableViewNormalCellManager *)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 rightValue:(id)arg4 accessoryType:(long long)arg5;
+ (WCTableViewNormalCellManager *)cellForMakeSel:(SEL)arg1 makeTarget:(id)arg2 height:(double)arg3 userInfo:(id)arg4;
+ (unsigned long long)accessoryType:(long long)arg1;
- (void)switchDidChanged:(id)arg1;
- (void)configureCell:(id)arg1 withRightConfig:(id)arg2;
- (void)configureCell:(id)arg1 withLeftConfig:(id)arg2;
- (double)cellSeparatorLeftInset;
- (double)cellHeightFor:(id)arg1;
- (void)configureCell:(id)arg1;
- (id)init;
- (void)makeEditorCell:(id)arg1;
- (void)makeNormalCell:(id)arg1;
- (void)makeNormalCell:(id)arg1 title:(id)arg2;
- (void)actionUrlInnerCell;
- (void)actionUrlCell;
- (void)actionEditorCell:(id)arg1;
- (id)getUserInfoValueForKey:(id)arg1;
- (void)addUserInfoValue:(id)arg1 forKey:(id)arg2;

@end

@interface MMUICommonUtil : NSObject

+ (id)getBarButtonWithTitle:(id)arg1 target:(id)arg2 action:(SEL)arg3 style:(int)arg4;
+ (id)getBarButtonWithTitle:(id)arg1 target:(id)arg2 action:(SEL)arg3 style:(int)arg4 color:(id)arg6;
+ (id)getBarButtonWithImageName:(id)arg1 target:(id)arg2 action:(SEL)arg3 style:(int)arg4 accessibility:(id)arg5 useTemplateMode:(BOOL)arg6;

@end

@interface MMWebViewController : UIViewController

- (id)initWithURL:(NSURL *)url presentModal:(BOOL)presentModal extraInfo:(id)extraInfo delegate:(id)delegate;
- (id)initWithURL:(id)arg1 presentModal:(BOOL)arg2 extraInfo:(id)arg3;
-  (void)didReceiveNewMessage;
- (void)backToMsgContentViewController;

@end

@interface WCRedEnvelopesControlData: NSObject

@property(retain, nonatomic) CMessageWrap *m_oSelectedMessageWrap;
- (void)setM_oSelectedMessageWrap:(CMessageWrap *)msgWrap;

@end

@interface MMServiceCenter : NSObject

+ (id)defaultCenter;
- (id)getService:(Class)aClass;

@end

@interface WCRedEnvelopesControlMgr: NSObject

- (void)startReceiveRedEnvelopesLogic:(UIViewController *)controller Data:(WCRedEnvelopesControlData *)data;
- (unsigned int)startReceiveGreetingRedEnvelopesLogic:(id)arg1 Data:(id)arg2;
- (unsigned int)startReceiveRedEnvelopesLogicByC2C:(id)arg1 Data:(id)arg2;

@end

@interface BaseMsgContentLogicController: NSObject

- (id)initWithLocalID:(unsigned int)arg1 CreateTime:(unsigned int)arg2 ContentViewDisshowStatus:(int)arg3;
- (BaseMsgContentViewController *)getViewController;
- (void)setM_contact:(CContact *)contact;
- (void)setM_dicExtraInfo:(id)info;
- (void)onWillEnterRoom;
- (id)getMsgContentViewController;

@end

@interface MemberDataLogic: NSObject

- (id)initWithMemberList:(id)arg1 admin:(id)arg2;
- (CContact *)getItemInSection:(unsigned long long)arg1 atRow:(unsigned long long)arg2;
- (unsigned long long)getSectionItemCount:(unsigned long long)arg1;
- (unsigned long long)getSectionCount;
- (unsigned long long)getTotalCount;

@end

@protocol ContactsDataLogicDelegate <NSObject>
- (BOOL)onFilterContactCandidate:(CContact *)arg1;
- (void)onContactsDataChange;

@optional
- (void)onContactAsynSearchSectionResultChanged:(NSArray *)arg1 sectionTitles:(NSDictionary *)arg2 sectionResults:(NSDictionary *)arg3;
- (void)onContactsDataNeedChange;
@end

@interface ContactsDataLogic: NSObject

@property(nonatomic) unsigned int m_uiScene; // @synthesize m_uiScene;

- (id)initWithScene:(unsigned int)arg1 delegate:(id)arg2 sort:(BOOL)arg3 extendChatRoom:(BOOL)arg4;
- (id)getChatRoomContacts;
- (id)getKeysArray;
- (BOOL)reloadContacts;
- (BOOL)hasHistoryGroupContacts;
- (id)getContactsArrayWith:(id)arg1;
- (id)initWithScene:(unsigned int)arg1 delegate:(id)arg2 sort:(BOOL)arg3;

@end

@interface MemberListViewController: UIViewController

@end

@interface ChatRoomListViewController: MemberListViewController

- (void)setMemberLogic:(MemberDataLogic *)logic;

@end

@interface LLFilterChatRoomController: ChatRoomListViewController

@property (nonatomic, strong) NSMutableDictionary *filterRoomDic; //过滤群组字典
@property (nonatomic, copy) void (^onConfirmSelectFilterRoom)(NSMutableDictionary *filterRoomDic);

- (void)setNavigationBar;
- (void)commonInit;
- (void)clickConfirmItem;
@end

@interface CAppViewControllerManager: NSObject

+ (UITabBarController *)getTabBarController;
+ (UINavigationController *)getCurrentNavigationController;

@end

@interface POIInfo : NSObject <NSCoding>

@property(retain, nonatomic) NSString *infoUrl; // @synthesize infoUrl=_infoUrl;
@property(retain, nonatomic) NSString *poiName; // @synthesize poiName=_poiName;
@property(retain, nonatomic) NSString *address; // @synthesize address=_address;
@property(retain, nonatomic) NSString *bid; // @synthesize bid=_bid;
@property(nonatomic) double scale; // @synthesize scale=_scale;
@property(nonatomic) struct CLLocationCoordinate2D coordinate; // @synthesize coordinate=_coordinate;

@end

@interface QMapView : UIView

@property(nonatomic) struct CLLocationCoordinate2D centerCoordinate;

@end

@protocol MMPickLocationViewControllerDelegate

@optional
- (UIBarButtonItem *)onGetRightBarButton;
- (void)onCancelSeletctedLocation;
@end

@interface MMPickLocationViewController : UIViewController

@property (nonatomic, weak) id <MMPickLocationViewControllerDelegate> delegate; // @synthesize delegate=_delegate;

- (id)initWithScene:(unsigned int)arg1 OnlyUseUserLocation:(BOOL)arg2;
- (id)getCurrentPOIInfo;
- (void)reportOnDone;

@end
@interface SettingBaseViewController : MMUIViewController

@end
@interface SettingDiscoverEntranceViewController : SettingBaseViewController

@end

