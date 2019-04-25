@interface SBApplication : NSObject

@property (nonatomic,readonly) NSString * bundleIdentifier;

@end

@interface SBMediaController : NSObject

@property (nonatomic,readonly) SBApplication * nowPlayingApplication;
-(id)_nowPlayingInfo;

@end

@interface MPUNowPlayingController : UIImageView

@property (nonatomic, retain) NSString *exoLastDigest;
@property (nonatomic, readonly) NSString *currentNowPlayingArtworkDigest;
@property (nonatomic) bool shouldUpdateNowPlayingArtwork;
@property (nonatomic, readonly) double currentDuration;
@property (nonatomic, readonly) double currentElapsed;

- (UIImage*)currentNowPlayingArtwork;

@end

@interface SBUIController : NSObject

+(instancetype)sharedInstanceIfExists;
-(BOOL)isOnAC;
-(int)batteryCapacityAsPercentage;

@end

@interface MRContentItem : NSObject

-(id)dictionaryRepresentation;

@end

@interface SBTelephonyManager : NSObject

+(id)sharedTelephonyManager;
-(BOOL)_pretendingToSearch;
-(BOOL)hasCellularTelephony;
-(int)dataConnectionType;
-(BOOL)isUsingVPNConnection;
-(int)signalStrengthBars;
-(id)operatorName;


@end

@interface SBWiFiManager : NSObject

-(BOOL)isPowered;
-(BOOL)isPrimaryInterface;
-(id)currentNetworkName;
-(void)_powerStateDidChange;
-(void)_linkDidChange;
-(void)updateDevicePresence;
-(void)_lock_spawnManagerCallbackThread;
-(void)_updateWiFiDevice;
-(void)_runManagerCallbackThread;
-(void)_updateCurrentNetwork;
-(void)updateSignalStrength;
-(void)_updateWiFiState;
-(void)updateSignalStrengthFromRawRSSI:(int)arg1 andScaledRSSI:(float)arg2 ;
-(int)signalStrengthRSSI;
-(void)setWiFiEnabled:(BOOL)arg1 ;
-(int)signalStrengthBars;
-(BOOL)wiFiEnabled;

@end