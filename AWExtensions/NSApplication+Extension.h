//
//  NSApplication+Extension.h
//  
//
//  Created by Emck on 2023/5/10.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSApplication (AWExtension)

// setup
- (void)setupDataAW:(nonnull NSDictionary *)dataInfo;
- (void)setupDelegateAW:(id)delegateAW;

// Notification Post
- (void)postLaunchAtLoginEvent:(nonnull NSButton *)Button;
- (void)postDockIconEvent:(BOOL)Visible;
- (void)postStatusBarIconEvent:(BOOL)Visible;

// NSNotification Event handle
- (void)handleLaunchAtLoginEvent:(NSNotification *)noti;
- (void)handleDockIconEvent:(NSNotification *)noti ;
- (void)handleStatusBarIconEvent:(NSNotification *)noti;

- (void)clean;

@end

NS_ASSUME_NONNULL_END
