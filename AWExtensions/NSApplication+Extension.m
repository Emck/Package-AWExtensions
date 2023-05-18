//
//  NSApplication+Extension.m
//  
//
//  Created by Emck on 2023/5/10.
//

#import "NSApplication+Extension.h"
#import <ServiceManagement/ServiceManagement.h>

#pragma mark - Constant
static NSString * const EventLaunchAtLogin       = @"EventLaunchAtLogin";
static NSString * const EventLaunchAtLoginResult = @"EventLaunchAtLoginResult";
static NSString * const EventDockIcon            = @"EventDockIcon";
static NSString * const EventStatusBarIcon       = @"EventStatusBarIcon";
static NSString * const LoginItemsHelper         = @".LoginItemsHelper";


#pragma mark - Static Variable
static id           DelegateAW;                 // Delegate by AWExtensions
static NSMenu       *AppMenuBarMenu;            // App MenuBarMenu
static NSStatusItem *StatusItem;                // Status Bar Menu
static NSString     *StatusBarIcon;             // Status Bar Icon


@implementation NSApplication (AWExtension)

- (void)setupDataAW:(nonnull NSDictionary *)dataInfo {
    AppMenuBarMenu = [dataInfo objectForKey:@"MenuBar"];
    StatusBarIcon  = [dataInfo objectForKey:@"BarIcon"];
    if (AppMenuBarMenu == nil || StatusBarIcon == nil) NSLog(@"Need Set 'MenuBar' and 'BarIcon' data");
    // register Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLaunchAtLoginEvent:) name:EventLaunchAtLogin object:nil];    // register LaunchAtLoginEvent
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDockIconEvent:)      name:EventDockIcon object:nil];         // register DockIconEvent
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStatusBarIconEvent:) name:EventStatusBarIcon object:nil];    // register StatusBarIconEvent
}

- (void)setupDelegateAW:(id)delegateAW {
    if (delegateAW == nil) return;
    DelegateAW = delegateAW;
    [[NSNotificationCenter defaultCenter] addObserver:DelegateAW selector:@selector(handleLaunchAtLoginResultEvent:) name:EventLaunchAtLoginResult object:nil];    // register LaunchAtLoginEventResult
}

- (void)clean {
    DelegateAW = nil;
    AppMenuBarMenu = nil;
    StatusItem = nil;
    StatusBarIcon = nil;
}


#pragma mark - Notification Post
- (void)postLaunchAtLoginEvent:(nonnull NSButton *)Button {
    [[NSNotificationCenter defaultCenter] postNotificationName:EventLaunchAtLogin object:nil userInfo:@{@"Button": Button}];
}

- (void)postDockIconEvent:(BOOL)Visible {
    [[NSNotificationCenter defaultCenter] postNotificationName:EventDockIcon object:nil userInfo:@{@"Visible": @(Visible)}];
}

- (void)postStatusBarIconEvent:(BOOL)Visible {
    [[NSNotificationCenter defaultCenter] postNotificationName:EventStatusBarIcon object:nil userInfo:@{@"Visible": @(Visible)}];
}


#pragma mark - NSNotification Event handle
- (void)handleLaunchAtLoginEvent:(NSNotification *)noti {
    NSButton *checkButton = [noti.userInfo objectForKey:@"Button"];
    if (checkButton == nil) return;
    BOOL Enable = checkButton.state;
    if (@available(macOS 13.0, *)) {
        NSError *error;
        if (Enable) [[SMAppService mainAppService] registerAndReturnError:&error];
        else if ([SMAppService mainAppService].status == SMAppServiceStatusEnabled) [[SMAppService mainAppService] unregisterAndReturnError:&error];
        [[NSNotificationCenter defaultCenter] postNotificationName:EventLaunchAtLoginResult object:nil userInfo:@{@"Enable": @(Enable), @"Result": @(error == nil), @"Button": checkButton}];
    }
    else {
        NSString *HelperIdentifier = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:LoginItemsHelper];
        BOOL error = SMLoginItemSetEnabled((__bridge CFStringRef)HelperIdentifier, Enable);
        [[NSNotificationCenter defaultCenter] postNotificationName:EventLaunchAtLoginResult object:nil userInfo:@{@"Enable": @(Enable), @"Result": @(error), @"Button": checkButton}];
    }
}

- (void)handleDockIconEvent:(NSNotification *)noti {
    BOOL visible = [[noti.userInfo objectForKey:@"Visible"] boolValue];
    NSApplication* app = [NSApplication sharedApplication];
    NSApplicationActivationPolicy targetPolicy = visible ? NSApplicationActivationPolicyRegular : NSApplicationActivationPolicyAccessory;
    if (app.activationPolicy == targetPolicy) return; // No need to do anything, we already have the policy we want

    [app setActivationPolicy:targetPolicy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [app unhide: nil];
        [app activateIgnoringOtherApps:YES];
    });
}

- (void)handleStatusBarIconEvent:(NSNotification *)noti {
    if (AppMenuBarMenu == nil) return;
    BOOL visible = [[noti.userInfo objectForKey:@"Visible"] boolValue];
    if (visible) {  // show status bar and menu
        NSImage *Image = [NSImage imageNamed:StatusBarIcon];
        [Image setTemplate:YES];
        [Image setSize:NSMakeSize(20,20)];
        StatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        StatusItem.button.toolTip = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        StatusItem.button.cell.highlighted = YES;
        StatusItem.button.image = Image;
        StatusItem.menu = AppMenuBarMenu;
    }
    else {          // hide status bar and menu
        [[NSStatusBar systemStatusBar] removeStatusItem: StatusItem];
        StatusItem.menu = nil;
        StatusItem = nil;
    }
}


@end
