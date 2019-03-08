#import "WCRemoteControlManager.h"
#import <objc/runtime.h>

static NSString * const kRemoteControlEnableKey = @"kRemoteControlEnableKey";


@implementation WCRemoteControlModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.enable = [dict[@"enable"] boolValue];
        self.function = dict[@"function"];
        self.command = dict[@"command"];
    }
    return self;
}

- (NSDictionary *)dictionary {
    return @{@"enable": @(self.enable),
             @"function": self.function,
             @"command": self.command};
}

@end

@implementation WCRemoteControlManager

+ (instancetype)sharedManager {
    static WCRemoteControlManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WCRemoteControlManager alloc] init];
        manager.isEnableRemoteControl = [[NSUserDefaults standardUserDefaults] boolForKey:kRemoteControlEnableKey];
    });
    return manager;
}

- (NSArray *)remoteCommands
{
    if (!_remoteCommands) {
        _remoteCommands = ({
            NSString* remoteFilePath = [PluginPath stringByAppendingPathComponent:@"RemoteControlCommands.plist"];
            NSArray *originModels = [NSArray arrayWithContentsOfFile:remoteFilePath];
            NSMutableArray *newRemoteControlModels = [[NSMutableArray alloc] init];
            [originModels.firstObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WCRemoteControlModel *model = [[WCRemoteControlModel alloc] initWithDict:obj];
                [newRemoteControlModels addObject:model];
            }];
            newRemoteControlModels;
        });
    }
    return _remoteCommands;
}

- (NSArray *)enableRemoteCommands
{
    if (!_enableRemoteCommands) {
        _enableRemoteCommands = ({
            NSMutableArray *enableCommands = [[NSMutableArray alloc] init];
            [self.remoteCommands enumerateObjectsUsingBlock:^(WCRemoteControlModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[WCRemoteControlModel class]] && obj.enable) {
                    [enableCommands addObject:obj];
                }
            }];
            enableCommands;
        });
    }
    return _isEnableRemoteControl?_enableRemoteCommands:nil;
}

- (void)sendRemoteControlCommand:(UIButton*)sender
{
    NSInteger index = sender.tag;
    WCRemoteControlModel *model = [self.enableRemoteCommands objectAtIndex:index - 100];
    CMessageMgr *chatMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CMessageMgr") class]];
    [chatMgr sendMsg:model.command toContactUsrName:@"filehelper"];
}

+ (NSMutableArray *)filterMessageWrapArr:(NSMutableArray *)msgList
{
    NSMutableArray *msgListResult = [msgList mutableCopy];
    for (CMessageWrap* msgWrap in msgList) {
        if ([msgWrap.m_nsToUsr isEqualToString:@"filehelper"] && [msgWrap.m_nsContent hasPrefix:@"#remote."]) {
            [msgListResult removeObject:msgWrap];
        }
    }
    return msgListResult;
}

- (void)handleRemoteControl:(UISwitch *)sender
{
    self.isEnableRemoteControl = sender.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:_isEnableRemoteControl forKey:kRemoteControlEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
