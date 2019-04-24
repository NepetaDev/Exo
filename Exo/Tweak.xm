#import <Foundation/NSDistributedNotificationCenter.h>
#import <notify.h>
#import <mach/mach_init.h>
#import <mach/mach_host.h>
#import <MediaRemote/MediaRemote.h>
#import <sys/utsname.h>
#import "Tweak.h"

@interface EXOObserver : NSObject

@property (nonatomic, retain) NSMutableDictionary *data;
@property (nonatomic, retain) NSTimer *every10MinutesTimer;
@property (nonatomic, retain) NSTimer *everyMinuteTimer;
@property (nonatomic, retain) NSTimer *every30SecondsTimer;

+(instancetype)sharedInstance;
-(id)init;
-(void)update:(NSDictionary *)updateData;

-(void)once;
-(void)dataRequested;
-(void)postNotification:(NSDictionary *)data;

-(void)startUpdating;
-(void)stopUpdating;

-(void)every30Seconds;
-(void)everyMinute;
-(void)every10Minutes;

-(void)updateBattery;
-(void)updateMemory;
-(void)updateDevice;
//...

@end

@implementation EXOObserver

/* Main stuff */

+(instancetype)sharedInstance
{
    static EXOObserver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [EXOObserver alloc];
        sharedInstance.data = [NSMutableDictionary new];
        [sharedInstance once];
    });
    return sharedInstance;
}

-(id)init {
    return [EXOObserver sharedInstance];
}

-(void)once {
    [self updateDevice];
}

-(void)update:(NSDictionary *)updateData {
    for (NSString *key in updateData) {
        self.data[key] = updateData[key];
    }

    [self postNotification:updateData];
}

-(void)dataRequested {
    [self postNotification:self.data];
}

-(void)postNotification:(NSDictionary *)data {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"me.nepeta.exo/update" object:nil userInfo:data];
}

/* Timer stuff */

-(void)startUpdating {
    [self stopUpdating];

    [self everyMinute];
    self.everyMinuteTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(everyMinute) userInfo:nil repeats:YES];

    [self every30Seconds];
    self.every30SecondsTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(every30Seconds) userInfo:nil repeats:YES];

    [self every10Minutes];
    self.every10MinutesTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(every10Minutes) userInfo:nil repeats:YES];
}

-(void)stopUpdating {
    if (self.everyMinuteTimer) [self.everyMinuteTimer invalidate];
    if (self.every30SecondsTimer) [self.every30SecondsTimer invalidate];
    if (self.every10MinutesTimer) [self.every10MinutesTimer invalidate];
}

-(void)every30Seconds {
    
}

-(void)everyMinute {
    [self updateBattery];
    [self updateMemory];
}

-(void)every10Minutes {

}

/* Update stuff */

-(void)updateBattery {
    SBUIController *controller = [%c(SBUIController) sharedInstanceIfExists];

    if (!controller) return;

    [self update:@{
        @"battery.charging": @([controller isOnAC]),
        @"battery.percentage": @([controller batteryCapacityAsPercentage])
    }];
}

-(void)updateMemory {
    /* Based on: https://stackoverflow.com/questions/5012886/determining-the-available-amount-of-ram-on-an-ios-device/8540665#8540665 */

    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return;
    }

    /* Stats in bytes */ 
    natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    natural_t mem_physical = [NSProcessInfo processInfo].physicalMemory;
 
    [self update:@{
        @"memory.physical": @(mem_physical),
        @"memory.used": @(mem_used),
        @"memory.free": @(mem_free),
        @"memory.total": @(mem_total),
    }];
}

-(void)updateDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *type = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    [self update:@{
        @"device.type": type,
        @"device.name": [[UIDevice currentDevice] name],
        @"system.version": [UIDevice currentDevice].systemVersion
    }];
}

@end

void dataRequested() {
    [[EXOObserver sharedInstance] dataRequested];
}

void updateChargingStatus(CFNotificationCenterRef center, void *o, CFStringRef name, id object, NSDictionary *userInfo) {
    [[EXOObserver sharedInstance] update:@{
        @"battery.charging": userInfo[@"IsCharging"]
    }];
}

%hook SBWiFiManager

-(void)_updateCurrentNetwork {
    %orig;
    NSString *name = [self currentNetworkName];
    if (!name) name = @"";
    [[EXOObserver sharedInstance] update:@{
        @"wifi.network": name,
    }];
}

-(void)updateSignalStrength {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"wifi.strength.current": @([self signalStrengthBars]),
        @"wifi.strength.rssi": @([self signalStrengthRSSI]),
    }];
}

-(void)setWiFiEnabled:(BOOL)arg1 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"wifi.enabled": @(arg1)
    }];
}

%end

%hook SBTelephonyManager

-(void)_setSignalStrengthBars:(unsigned long long)arg1 maxBars:(unsigned long long)arg2 inSubscriptionContext:(id)arg3 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"mobile.strength.current": @(arg1),
        @"mobile.strength.max": @(arg2)
    }];
}

-(void)_setSignalStrengthBars:(unsigned long long)arg1 maxBars:(unsigned long long)arg2 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"mobile.strength.current": @(arg1),
        @"mobile.strength.max": @(arg2)
    }];
}

-(void)_setOperatorName:(NSString *)arg1 inSubscriptionContext:(id)arg2 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"mobile.network": arg1 ?: @""
    }];
}

-(void)_setOperatorName:(NSString *)arg1 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"mobile.network": arg1 ?: @""
    }];
}

-(void)_reallySetOperatorName:(NSString *)arg1 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"mobile.network": arg1 ?: @""
    }];
}

-(void)setOperatorName:(NSString *)arg1 {
    %orig;
    [[EXOObserver sharedInstance] update:@{
        @"mobile.network": arg1 ?: @""
    }];
}

%end

%hook SBMediaController

-(void)setNowPlayingInfo:(id)arg1 {
    %orig;
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict = (__bridge NSDictionary *)information;

        if (dict) {
            NSMutableDictionary *updateData = [NSMutableDictionary new];
            if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoPlaybackRate]) {
                updateData[@"media.playing"] = @([dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoPlaybackRate] intValue] > 0);
            }
            
            if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum]) {
                updateData[@"media.album"] = [dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum] copy];
            }

            if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist]) {
                updateData[@"media.artist"] = [dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] copy];
            }
            
            if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle]) {
                updateData[@"media.title"] = [dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] copy];
            }
            
            if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime]) {
                updateData[@"media.elapsed"] = [dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] copy];
            }
            
            if (dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDuration]) {
                updateData[@"media.duration"] = [dict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDuration] copy];
            }
            
            [[EXOObserver sharedInstance] update:updateData];
        }
    });
}

%end

%hook SBDashBoardViewController

-(void)viewWillAppear:(BOOL)animated {
    %orig;

    [[EXOObserver sharedInstance] startUpdating];
}

%end

static void screenDisplayStatus(CFNotificationCenterRef center, void* o, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
    uint64_t state;
    int token;
    notify_register_check("com.apple.iokit.hid.displayStatus", &token);
    notify_get_state(token, &state);
    notify_cancel(token);
    if (state) {
        [[EXOObserver sharedInstance] startUpdating];
    } else {
        [[EXOObserver sharedInstance] stopUpdating];
    }
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)updateChargingStatus, (CFStringRef)@"SBUIACStatusChangedNotification", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)dataRequested, (CFStringRef)@"me.nepeta.exo/request", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)screenDisplayStatus, (CFStringRef)@"com.apple.iokit.hid.displayStatus", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}