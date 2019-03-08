#import <Foundation/Foundation.h>
#import "WeChat.h"

#define PluginPath @"/Library/Application Support/WeChatPlugin/"

@interface WCRemoteControlModel : NSObject

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, copy) NSString *function;
@property (nonatomic, copy) NSString *command;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

@end


@interface WCRemoteControlManager : NSObject

@property (nonatomic, strong)NSArray *remoteCommands;
@property (nonatomic, strong)NSArray *enableRemoteCommands;
@property (nonatomic, assign)BOOL isEnableRemoteControl;
+ (instancetype)sharedManager;

- (void)handleRemoteControl:(UISwitch *)sender;
- (void)sendRemoteControlCommand:(UIButton*)sender;
+ (NSMutableArray * )filterMessageWrapArr:(NSMutableArray *)msgList;
@end
