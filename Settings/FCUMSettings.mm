//
//  FCUMSettings.xm
//  FrontCamUnMirror Settings
//
//  Copyright (C) 2014-2016 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"•• [FCUM Settings]"
#import "../DebugLog.h"

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>
#import <Social/Social.h>
#import <spawn.h>


#define BUNDLE_PATH			@"/Library/PreferenceBundles/FrontCamUnMirror.bundle/"
#define PREFS_PLIST_PATH	[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.fcum.plist"]

#define TINT_COLOR			[UIColor colorWithRed:0 green:0 blue:0 alpha:1]


@interface FCUMSettingsController: PSListController
@end


@implementation FCUMSettingsController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"FrontCamUnMirror" target:self];
	}
	return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFS_PLIST_PATH];
	if (!settings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return settings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PLIST_PATH]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:PREFS_PLIST_PATH atomically:NO]; //sandbox issue if atomic

	NSString *notificationValue = specifier.properties[@"PostNotification"];
	if (notificationValue) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFStringRef(notificationValue), NULL, NULL, YES);
	}
}

- (void)setTitle:(id)title {
	// no thanks
}

- (void)openEmail {
	NSString *url = @"mailto:sticktron@hotmail.com?subject=FrontCamUnMirror%20Support";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)openTwitter {
	NSURL *url;

	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		url = [NSURL URLWithString:@"tweetbot:///user_profile/sticktron"];

	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		url = [NSURL URLWithString:@"twitterrific:///profile?screen_name=sticktron"];

	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		url = [NSURL URLWithString:@"tweetings:///user?screen_name=sticktron"];

	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		url = [NSURL URLWithString:@"twitter://user?screen_name=sticktron"];

	} else {
		url = [NSURL URLWithString:@"http://twitter.com/sticktron"];
	}

	[[UIApplication sharedApplication] openURL:url];
}

- (void)openGitHub {
	NSString *url = @"https://github.com/Sticktron/FrontCamUnMirror";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)respring {
	NSLog(@"FCUM called for a respring!");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respring"
													message:@"Restart SpringBoard now?"
												   delegate:self
										  cancelButtonTitle:@"NO"
										  otherButtonTitles:@"YES", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)buttonIndex {
	if (buttonIndex == 1) { // YES
		[self respringNow];
	}
}

- (void)respringNow {
	pid_t pid;
	const char* args[] = { "killall", "-9", "SpringBoard", NULL };
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end


//------------------------------------------------------------------------------


@interface FCUMSwitchCell : PSSwitchTableCell
@end

@implementation FCUMSwitchCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:TINT_COLOR];
	}
	return self;
}
@end


//------------------------------------------------------------------------------


@interface FCUMButtonCell : PSTableCell
@end

@implementation FCUMButtonCell
- (void)layoutSubviews {
	[super layoutSubviews];

	// if I do this at init it doesn't stick :(
	[self.textLabel setTextColor:UIColor.blackColor];
}
@end


//------------------------------------------------------------------------------


@interface FCUMTitleCell : PSTableCell
@end

@implementation FCUMTitleCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FCUMTitleCell" specifier:specifier];
	if (self) {
		self.backgroundColor = UIColor.clearColor;

		NSString *path = [BUNDLE_PATH stringByAppendingPathComponent:@"logo.png"];
		UIImage *titleImage = [UIImage imageWithContentsOfFile:path];

		UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
		titleImageView.frame = self.contentView.bounds;
		titleImageView.contentMode = UIViewContentModeCenter;
		titleImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

		[self.contentView addSubview:titleImageView];
	}
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 100.0f;
}

@end
