#import "RNDFPBannerView.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#else
#import "RCTBridgeModule.h"
#import "UIView+React.h"
#import "RCTLog.h"
#endif

#include "RCTConvert+GADGender.h"

@implementation RNDFPBannerView {
    DFPBannerView  *_bannerView;
    GADAdSize _kGADAdCustomSize;
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
    RCTLogError(@"AdMob Banner cannot have any subviews");
    return;
}

- (void)removeReactSubview:(UIView *)subview
{
    RCTLogError(@"AdMob Banner cannot have any subviews");
    return;
}

- (GADAdSize)getAdSizeFromString:(NSString *)bannerSize
{
    if ([bannerSize isEqualToString:@"banner"]) {
        return kGADAdSizeBanner;
    } else if ([bannerSize isEqualToString:@"largeBanner"]) {
        return kGADAdSizeLargeBanner;
    } else if ([bannerSize isEqualToString:@"mediumRectangle"]) {
        return kGADAdSizeMediumRectangle;
    } else if ([bannerSize isEqualToString:@"fullBanner"]) {
        return kGADAdSizeFullBanner;
    } else if ([bannerSize isEqualToString:@"leaderboard"]) {
        return kGADAdSizeLeaderboard;
    } else if ([bannerSize isEqualToString:@"smartBannerPortrait"]) {
        return kGADAdSizeSmartBannerPortrait;
    } else if ([bannerSize isEqualToString:@"smartBannerLandscape"]) {
        return kGADAdSizeSmartBannerLandscape;
    }
    else {
        return kGADAdSizeBanner;
    }
}

-(void)loadBanner {
    if (_adUnitID && (_bannerSize || (_bannerHeight && _bannerWidth) || _adSizes) && _onSizeChange && _onDidFailToReceiveAdWithError && (_targetingDisabled || _targeting != nil)) {
        GADAdSize size;
        if (_bannerHeight && _bannerWidth) {
            size = _kGADAdCustomSize;
        } else {
            size = [self getAdSizeFromString:_bannerSize];
        }
        _bannerView = [[DFPBannerView alloc] initWithAdSize:size];
        if (_adSizes) {
            _bannerView.validAdSizes = [self getValidAdSizes];
        }
        [_bannerView setAppEventDelegate:self]; //added Admob event dispatch listener
        if(!CGRectEqualToRect(self.bounds, _bannerView.bounds)) {
            if (self.onSizeChange) {
                self.onSizeChange(@{
                                    @"width": [NSNumber numberWithFloat: _bannerView.bounds.size.width],
                                    @"height": [NSNumber numberWithFloat: _bannerView.bounds.size.height]
                                    });
            }
        }
        _bannerView.delegate = self;
        _bannerView.adUnitID = _adUnitID;
        _bannerView.rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        DFPRequest *request = [DFPRequest request];
        if(_testDeviceID) {
            if([_testDeviceID isEqualToString:@"EMULATOR"]) {
                request.testDevices = @[kGADSimulatorID];
            } else {
                request.testDevices = @[_testDeviceID];
            }
        }
        
        if (_targeting != nil) {
            NSDictionary *customTargeting = [_targeting objectForKey:@"customTargeting"];
            if (customTargeting != nil) {
                request.customTargeting = customTargeting;
            }
            NSArray *categoryExclusions = [_targeting objectForKey:@"categoryExclusions"];
            if (categoryExclusions != nil) {
                request.categoryExclusions = categoryExclusions;
            }
            NSArray *keywords = [_targeting objectForKey:@"keywords"];
            if (keywords != nil) {
                request.keywords = keywords;
            }
            NSString *gender = [_targeting objectForKey:@"gender"];
            if (gender != nil) {
                request.gender = [RCTConvert GADGender:gender];
            }
            NSDate *birthday = [_targeting objectForKey:@"birthday"];
            if (birthday != nil) {
                request.birthday = [RCTConvert NSDate:birthday];
            }
            id childDirectedTreatment = [_targeting objectForKey:@"childDirectedTreatment"];
            if (childDirectedTreatment != nil) {
                [request tagForChildDirectedTreatment:childDirectedTreatment];
            }
            NSString *contentURL = [_targeting objectForKey:@"contentURL"];
            if (contentURL != nil) {
                request.contentURL = contentURL;
            }
            NSString *publisherProvidedID = [_targeting objectForKey:@"publisherProvidedID"];
            if (publisherProvidedID != nil) {
                request.publisherProvidedID = publisherProvidedID;
            }
            NSDictionary *location = [_targeting objectForKey:@"location"];
            if (location != nil) {
                CGFloat latitude = [[location objectForKey:@"latitude"] doubleValue];
                CGFloat longitude = [[location objectForKey:@"longitude"] doubleValue];
                CGFloat accuracy = [[location objectForKey:@"accuracy"] doubleValue];
                [request setLocationWithLatitude:latitude longitude:longitude accuracy:accuracy];
            }
        }
        
        [_bannerView loadRequest:request];
    }
}

- (void)adView:(DFPBannerView *)banner
didReceiveAppEvent:(NSString *)name
      withInfo:(NSString *)info {
    NSLog(@"Received app event (%@, %@)", name, info);
    NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
    myDictionary[name] = info;
    if (self.onAdmobDispatchAppEvent) {
        self.onAdmobDispatchAppEvent(@{ name: info });
    }
}

- (void)setCustomBannerSize
{
    double width = _bannerWidth;
    double height = _bannerHeight;
    _kGADAdCustomSize = GADAdSizeFromCGSize(CGSizeMake(width, height));
}

- (NSMutableArray *)getValidAdSizes
{
    NSMutableArray *adSizes = [[NSMutableArray alloc] init];
    for (NSArray *size in _adSizes) {
        double width = [size[0] floatValue];
        double height = [size[1] floatValue];
        GADAdSize customGADAdSize = GADAdSizeFromCGSize(CGSizeMake(width, height));
        [adSizes addObject:NSValueFromGADAdSize(customGADAdSize)];
    }
    
    return adSizes;
}

- (void)setBannerSize:(NSString *)bannerSize
{
    if(![bannerSize isEqual:_bannerSize] && ![bannerSize isEqual:@"custom"]) {
        _bannerSize = bannerSize;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        [self loadBanner];
    }
}

- (void)setAdSizes:(NSArray *)adSizes
{
    if(![adSizes isEqual:_adSizes]) {
        _adSizes = adSizes;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        [self loadBanner];
    }
}

- (void)setBannerWidth:(NSInteger)bannerWidth
{
    if(bannerWidth != _bannerWidth) {
        _bannerWidth = bannerWidth;
        if (_bannerHeight && _bannerWidth) {
            if (_bannerView) {
                [_bannerView removeFromSuperview];
            }
            [self setCustomBannerSize];
            [self loadBanner];
        }
    }
}

- (void)setBannerHeight:(NSInteger)bannerHeight
{
    if(bannerHeight != _bannerHeight) {
        _bannerHeight = bannerHeight;
        if (_bannerHeight && _bannerHeight) {
            if (_bannerView) {
                [_bannerView removeFromSuperview];
            }
            [self setCustomBannerSize];
            [self loadBanner];
        }
    }
}

- (void)setTargetingDisabled:(BOOL)targetingDisabled
{
    if (targetingDisabled != _targetingDisabled) {
        _targetingDisabled = targetingDisabled;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        [self loadBanner];
    }
}

- (void)setTargeting:(NSDictionary *)targeting
{
    if(![targeting isEqualToDictionary:_targeting]) {
        _targeting = targeting;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        [self loadBanner];
    }
}

- (void)setOnSizeChange:(RCTBubblingEventBlock)onSizeChange
{
    if(onSizeChange != _onSizeChange) {
        _onSizeChange = onSizeChange;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        [self loadBanner];
    }
}

- (void)setAdUnitID:(NSString *)adUnitID
{
    if(![adUnitID isEqual:_adUnitID]) {
        _adUnitID = adUnitID;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        
        [self loadBanner];
    }
}
- (void)setTestDeviceID:(NSString *)testDeviceID
{
    if(![testDeviceID isEqual:_testDeviceID]) {
        _testDeviceID = testDeviceID;
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        [self loadBanner];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews ];
    
    _bannerView.frame = CGRectMake(
                                   self.bounds.origin.x,
                                   self.bounds.origin.x,
                                   _bannerView.frame.size.width,
                                   _bannerView.frame.size.height);
    [self addSubview:_bannerView];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
    if (self.onAdViewDidReceiveAd) {
        self.onAdViewDidReceiveAd(@{});
    }
}

/// Tells the delegate an ad request failed.
- (void)adView:(DFPBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    if (self.onDidFailToReceiveAdWithError) {
        self.onDidFailToReceiveAdWithError(@{ @"error": [error localizedDescription] });
    }
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(DFPBannerView *)adView {
    if (self.onAdViewWillPresentScreen) {
        self.onAdViewWillPresentScreen(@{});
    }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(DFPBannerView *)adView {
    if (self.onAdViewWillDismissScreen) {
        self.onAdViewWillDismissScreen(@{});
    }
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(DFPBannerView *)adView {
    if (self.onAdViewDidDismissScreen) {
        self.onAdViewDidDismissScreen(@{});
    }
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(DFPBannerView *)adView {
    if (self.onAdViewWillLeaveApplication) {
        self.onAdViewWillLeaveApplication(@{});
    }
}

#pragma mark - GADAdSizeDelegate

/// Called before the ad view changes to the new size.
- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)size {
    // bannerView calls this method on its adSizeDelegate object before the banner updates it size,
    // allowing the application to adjust any views that may be affected by the new ad size.
    CGSize cgSize = CGSizeFromGADAdSize(size);
    NSNumber *widthInt = [NSNumber numberWithFloat:cgSize.width];
    NSNumber *heightInt = [NSNumber numberWithFloat:cgSize.height];
    if (self.onAdViewWillChangeAdSizeTo) {
        self.onAdViewWillChangeAdSizeTo(@{ @"width": widthInt, @"height": heightInt});
    }
}

@end
