@interface SBMediaController : NSObject

-(id)_nowPlayingInfo;

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