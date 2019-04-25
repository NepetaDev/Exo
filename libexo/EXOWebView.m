#import <Foundation/NSDistributedNotificationCenter.h>
#import <MediaRemote/MediaRemote.h>
#import "public/EXOWebView.h"

typedef enum {
    /*
        * Use nil for userInfo.
        */
    kMRPlay = 0,
    kMRPause = 1,
    kMRTogglePlayPause = 2,
    kMRStop = 3,
    kMRNextTrack = 4,
    kMRPreviousTrack = 5,
    kMRToggleShuffle = 6,
    kMRToggleRepeat = 7,
    kMRStartForwardSeek = 8,
    kMREndForwardSeek = 9,
    kMRStartBackwardSeek = 10,
    kMREndBackwardSeek = 11,
    kMRGoBackFifteenSeconds = 12,
    kMRSkipFifteenSeconds = 13,

    /*
        * Use a NSDictionary for userInfo, which contains three keys:
        * kMRMediaRemoteOptionTrackID
        * kMRMediaRemoteOptionStationID
        * kMRMediaRemoteOptionStationHash
        */
    kMRLikeTrack = 0x6A,
    kMRBanTrack = 0x6B,
    kMRAddTrackToWishList = 0x6C,
    kMRRemoveTrackFromWishList = 0x6D
} MRCommand;

@implementation EXOWebView 

-(id)initWithFrame:(CGRect)frame {
    self.exoInternalVariables = [@{} mutableCopy];

    NSString *content = [NSString stringWithContentsOfFile:@"/Library/Exo/exo.js" encoding:NSUTF8StringEncoding error:NULL];
    self.exoUserScript = [[WKUserScript alloc] initWithSource:content injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    self.exoContentController = [WKUserContentController new];
    [self.exoContentController addUserScript:self.exoUserScript];
    [self.exoContentController addScriptMessageHandler:self name:@"action"];

    self.exoWebViewConfig = [WKWebViewConfiguration new];
    self.exoWebViewConfig.ignoresViewportScaleLimits = false;
    self.exoWebViewConfig.userContentController = self.exoContentController;

    self = [super initWithFrame:frame configuration:self.exoWebViewConfig];

    self.userInteractionEnabled = false;
    self.scrollView.scrollEnabled = false;
    self.scrollView.pinchGestureRecognizer.enabled = false;
    self.scrollView.panGestureRecognizer.enabled = false;

    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"me.nepeta.exo/update" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        [self exoUpdate:notification.userInfo];
    }];

    return self;
}

-(void)exoUpdate:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:(NSJSONWritingOptions)0 error:&error];

    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self evaluateJavaScript:[NSString stringWithFormat:@"window.exo._update(%@);", jsonString] completionHandler:nil];
    }
}

-(void)exoInternalUpdate:(NSDictionary *)dictionary {
    for (NSString *key in dictionary) {
        self.exoInternalVariables[key] = dictionary[key];
    }

    [self exoUpdate:dictionary];
}

-(void)exoAction:(NSString *)action withArguments:(NSDictionary *)arguments {
    if ([action isEqualToString:@"requestUpdate"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.exo/request", nil, nil, true);
        [self exoUpdate:self.exoInternalVariables];
    } else if ([action isEqualToString:@"log"]) {
        if (arguments && arguments[@"message"] && [arguments[@"message"] isKindOfClass:[NSString class]]) {
            NSLog(@"[Exo] [EXTERNAL LOG] %@", arguments[@"message"]);
        }
    } else if ([action hasPrefix:@"media."]) {
        if ([action isEqualToString:@"media.play"]) {
            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRPlay, nil);
        } else if ([action isEqualToString:@"media.pause"]) {
            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRPause, nil);
        } else if ([action isEqualToString:@"media.stop"]) {
            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRStop, nil);
        } else if ([action isEqualToString:@"media.next"]) {
            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRNextTrack, nil);
        } else if ([action isEqualToString:@"media.previous"]) {
            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRPreviousTrack, nil);
        } else if ([action isEqualToString:@"media.togglePlayback"]) {
            MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
                NSDictionary *dict = (__bridge NSDictionary *)information;
                if (dict) {
                    if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoPlaybackRate]) {
                        if ([dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoPlaybackRate] intValue] > 0) {
                            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRPause, nil);
                        } else {
                            MRMediaRemoteSendCommand((MRMediaRemoteCommand)kMRPlay, nil);
                        }
                    }
                }
            });
        }
    } else if ([action isEqualToString:@"open.url"]) {
        if (arguments && arguments[@"url"] && [arguments[@"url"] isKindOfClass:[NSString class]] &&
                [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:arguments[@"url"]]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:arguments[@"url"]] options:@{} completionHandler:nil];
        }
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"action"]) {
        NSString *action = nil;
        NSDictionary *arguments = nil;
        if ([message.body isKindOfClass:[NSString class]]) {
            action = message.body;
        } else if ([message.body isKindOfClass:[NSDictionary class]]) {
            arguments = message.body;
            if (arguments[@"action"] && [arguments[@"action"] isKindOfClass:[NSString class]]) {
                action = arguments[@"action"];
            }
        }

        [self exoAction:action withArguments:arguments];
    }
}

@end