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

@interface WFTemperature : NSObject

@property (assign,nonatomic) double celsius; 
@property (assign,nonatomic) double fahrenheit; 
@property (assign,nonatomic) double kelvin; 
+(BOOL)supportsSecureCoding;
-(double)celsius;
-(double)fahrenheit;
-(double)kelvin;
-(id)init;
-(id)initWithCoder:(id)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(BOOL)isEqual:(id)arg1 ;
-(unsigned long long)hash;
-(id)description;
-(id)copyWithZone:(NSZone*)arg1 ;
-(void)_setValue:(double)arg1 forUnit:(int)arg2 ;
-(void)_resetTemperatureValues;
-(BOOL)_unitIsHydrated:(int)arg1 outputValue:(out double*)arg2 ;
-(double)temperatureForUnit:(int)arg1 ;
-(id)initWithTemperatureUnit:(int)arg1 value:(double)arg2 ;
-(void)setCelsius:(double)arg1 ;
-(void)setKelvin:(double)arg1 ;
-(void)setFahrenheit:(double)arg1 ;
-(BOOL)isEqualToTemperature:(id)arg1 ;

@end

@interface City : NSObject

@property (readonly) NSDictionary * urlComponents; 
@property (nonatomic,retain) NSTimeZone * timeZone;                                      //@synthesize timeZone=_timeZone - In the implementation block
@property (nonatomic,retain) NSError * lastUpdateError;                                  //@synthesize lastUpdateError=_lastUpdateError - In the implementation block
@property (assign,nonatomic) unsigned long long lastUpdateStatus;                        //@synthesize lastUpdateStatus=_lastUpdateStatus - In the implementation block
@property (assign,nonatomic) BOOL isUpdating;                                            //@synthesize isUpdating=_isUpdating - In the implementation block
@property (assign,nonatomic) BOOL isRequestedByFrameworkClient;                          //@synthesize isRequestedByFrameworkClient=_isRequestedByFrameworkClient - In the implementation block
@property (assign,nonatomic) BOOL lockedForDemoMode;                                     //@synthesize lockedForDemoMode=_lockedForDemoMode - In the implementation block
@property (assign,nonatomic) long long updateInterval;                                   //@synthesize updateInterval=_updateInterval - In the implementation block
@property (nonatomic,retain) NSTimer * autoUpdateTimer;                                  //@synthesize autoUpdateTimer=_autoUpdateTimer - In the implementation block
@property (nonatomic,copy) NSString * updateTimeString;                                  //@synthesize updateTimeString=_updateTimeString - In the implementation block
@property (nonatomic,retain) NSHashTable * cityUpdateObservers;                          //@synthesize cityUpdateObservers=_cityUpdateObservers - In the implementation block
@property (nonatomic,readonly) BOOL timeZoneIsFresh; 
@property (nonatomic,copy) NSString * fullName;                                          //@synthesize fullName=_fullName - In the implementation block
@property (assign,nonatomic) BOOL isLocalWeatherCity;                                    //@synthesize isLocalWeatherCity=_isLocalWeatherCity - In the implementation block
@property (assign,nonatomic) BOOL transient;                          //@synthesize transient=_transient - In the implementation block
@property (nonatomic,copy) NSString * woeid;                                             //@synthesize woeid=_woeid - In the implementation block
@property (nonatomic,copy) NSString * name;                                              //@synthesize name=_name - In the implementation block
@property (nonatomic,readonly) NSString * locationID; 
@property (nonatomic,copy) NSString * state;                                             //@synthesize state=_state - In the implementation block
@property (nonatomic,copy) NSString * ISO3166CountryAbbreviation;                        //@synthesize ISO3166CountryAbbreviation=_ISO3166CountryAbbreviation - In the implementation block
@property (nonatomic,retain) WFTemperature * temperature;                                //@synthesize temperature=_temperature - In the implementation block
@property (nonatomic,retain) WFTemperature * feelsLike;                                  //@synthesize feelsLike=_feelsLike - In the implementation block
@property (assign,nonatomic) long long conditionCode;                                    //@synthesize conditionCode=_conditionCode - In the implementation block
@property (assign,nonatomic) unsigned long long observationTime;                         //@synthesize observationTime=_observationTime - In the implementation block
@property (assign,nonatomic) unsigned long long sunsetTime;                              //@synthesize sunsetTime=_sunsetTime - In the implementation block
@property (assign,nonatomic) unsigned long long sunriseTime;                             //@synthesize sunriseTime=_sunriseTime - In the implementation block
@property (assign,nonatomic) unsigned long long moonPhase;                               //@synthesize moonPhase=_moonPhase - In the implementation block
@property (assign,nonatomic) unsigned long long uvIndex;              //@synthesize uvIndex=_uvIndex - In the implementation block
@property (assign,nonatomic) double precipitationPast24Hours;                            //@synthesize precipitationPast24Hours=_precipitationPast24Hours - In the implementation block
@property (nonatomic,copy) NSURL * link;                                                 //@synthesize link=_link - In the implementation block
@property (nonatomic,copy) NSURL * deeplink;                                             //@synthesize deeplink=_deeplink - In the implementation block
@property (assign,nonatomic) double longitude; 
@property (assign,nonatomic) double latitude; 
@property (nonatomic,retain) NSDate * timeZoneUpdateDate;                                //@synthesize timeZoneUpdateDate=_timeZoneUpdateDate - In the implementation block
@property (nonatomic,retain) NSDate * updateTime;                                        //@synthesize updateTime=_updateTime - In the implementation block
@property (assign,nonatomic) float windChill;                                            //@synthesize windChill=_windChill - In the implementation block
@property (assign,nonatomic) float windDirection;                                        //@synthesize windDirection=_windDirection - In the implementation block
@property (assign,nonatomic) float windSpeed;                                            //@synthesize windSpeed=_windSpeed - In the implementation block
@property (assign,nonatomic) float humidity;                                             //@synthesize humidity=_humidity - In the implementation block
@property (assign,nonatomic) float visibility;                                           //@synthesize visibility=_visibility - In the implementation block
@property (assign,nonatomic) float pressure;                                             //@synthesize pressure=_pressure - In the implementation block
@property (assign,nonatomic) unsigned long long pressureRising;                          //@synthesize pressureRising=_pressureRising - In the implementation block
@property (assign,nonatomic) float dewPoint;                                             //@synthesize dewPoint=_dewPoint - In the implementation block
@property (assign,nonatomic) float heatIndex;                                            //@synthesize heatIndex=_heatIndex - In the implementation block
@property (nonatomic,retain) NSNumber * airQualityIdx;                                   //@synthesize airQualityIdx=_airQualityIdx - In the implementation block
@property (nonatomic,retain) NSNumber * airQualityCategory;                              //@synthesize airQualityCategory=_airQualityCategory - In the implementation block
@property (assign,nonatomic) BOOL isDay;                                                 //@synthesize isDay=_isDay - In the implementation block
@property (assign,nonatomic) BOOL autoUpdate;                                            //@synthesize autoUpdate=_autoUpdate - In the implementation block
@property (nonatomic,copy) NSArray * hourlyForecasts;                                    //@synthesize hourlyForecasts=_hourlyForecasts - In the implementation block
@property (nonatomic,copy) NSArray * dayForecasts;                                       //@synthesize dayForecasts=_dayForecasts - In the implementation block

@end


@interface WeatherPreferences : NSObject
-(int)loadDefaultSelectedCity;
-(id)loadDefaultSelectedCityID;
-(int)loadActiveCity;
+(id)sharedPreferences;
-(City *)localWeatherCity;
-(BOOL)isCelsius;
-(id)loadSavedCities;
-(id)_defaultCities;

@end