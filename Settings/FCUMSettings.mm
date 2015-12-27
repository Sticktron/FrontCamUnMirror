//
//  FCUMSettings.xm
//  FrontCamUnMirror Settings
//
//  Copyright (C) 2014-2015 Sticktron. All rights reserved.
//
//

#define DEBUG_PREFIX @"••••• [FCUM Settings]"
#import "../DebugLog.h"

#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>
#import <Social/Social.h>
#import <spawn.h>


#define TINT_COLOR			[UIColor colorWithRed:0.5 green:0 blue:1 alpha:1]
#define BUNDLE_PATH			@"/Library/PreferenceBundles/FrontCamUnMirror.bundle/"


@interface FCUMSettingsController: PSListController
@end


@implementation FCUMSettingsController

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"FrontCamUnMirror" target:self];
	}
	return _specifiers;
}

- (void)setTitle:(id)title {
	// no thanks
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// add a heart button to the navbar
	NSString *path = [BUNDLE_PATH stringByAppendingPathComponent:@"Heart.png"];
	UIImage *heartImage = [[UIImage alloc] initWithContentsOfFile:path];
	
	UIBarButtonItem *heartButton = [[UIBarButtonItem alloc] initWithImage:heartImage
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(showLove)];
	heartButton.imageInsets = (UIEdgeInsets){2, 0, -2, 0};
	heartButton.tintColor = TINT_COLOR;
	
	[self.navigationItem setRightBarButtonItem:heartButton];
}

- (void)openEmail {
	NSString *url = @"mailto:sticktron@hotmail.com";
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

- (void)showLove {
	SLComposeViewController *composeController = [SLComposeViewController
												  composeViewControllerForServiceType:SLServiceTypeTwitter];
	
	[composeController setInitialText:@"I'm using #FrontCamUnMirror by @Sticktron and I like it!"];
	
	[self presentViewController:composeController
					   animated:YES
					 completion:nil];
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
	const char* args[] = { "killall", "-9", "backboardd", NULL };
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	
	// wait until killed
	//int status;
	//waitpid(pid, &status, WEXITED);
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
		
		NSString *path = [BUNDLE_PATH stringByAppendingPathComponent:@"Title.png"];
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

