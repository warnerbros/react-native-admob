import React from 'react';
import {
  NativeModules,
  requireNativeComponent,
  View,
  NativeEventEmitter,
} from 'react-native';

const RNBanner = requireNativeComponent('RNAdMobDFP', PublisherBanner);

export default class PublisherBanner extends React.Component {

  constructor() {
    super();
    this.onSizeChange = this.onSizeChange.bind(this);
    this.state = {
      style: {},
    };
  }

  onSizeChange(event) {
    const { height, width } = event.nativeEvent;
    this.setState({ style: { width, height } });
  }

  render() {
    const { 
      adUnitID,
      testDeviceID,
      bannerSize,
      targeting,
      style,
      didFailToReceiveAdWithError, 
      admobDispatchAppEvent,
      targetingDisabled,
			bannerWidth,
			bannerHeight,
    } = this.props;
    return (
      <View style={this.props.style}>
        <RNBanner
          style={this.state.style}
          onSizeChange={this.onSizeChange.bind(this)}
          onAdViewDidReceiveAd={this.props.adViewDidReceiveAd}
          onDidFailToReceiveAdWithError={(event) => didFailToReceiveAdWithError(event.nativeEvent.error)}
          onAdViewWillPresentScreen={this.props.adViewWillPresentScreen}
          onAdViewWillDismissScreen={this.props.adViewWillDismissScreen}
          onAdViewDidDismissScreen={this.props.adViewDidDismissScreen}
          onAdViewWillLeaveApplication={this.props.adViewWillLeaveApplication}
          onAdmobDispatchAppEvent={(event) => admobDispatchAppEvent(event)}
          testDeviceID={testDeviceID}
          adUnitID={adUnitID}
          bannerSize={bannerSize}
          targeting={targeting}
          targetingDisabled={targetingDisabled}
					bannerWidth={bannerWidth}
					bannerHeight={bannerHeight}
        />
      </View>
    );
  }
}

PublisherBanner.propTypes = {
  style: View.propTypes.style,

  /**
   * AdMob iOS library banner size constants
   * (https://developers.google.com/admob/ios/banner)
   * banner (320x50, Standard Banner for Phones and Tablets)
   * largeBanner (320x100, Large Banner for Phones and Tablets)
   * mediumRectangle (300x250, IAB Medium Rectangle for Phones and Tablets)
   * fullBanner (468x60, IAB Full-Size Banner for Tablets)
   * leaderboard (728x90, IAB Leaderboard for Tablets)
   * smartBannerPortrait (Screen width x 32|50|90, Smart Banner for Phones and Tablets)
   * smartBannerLandscape (Screen width x 32|50|90, Smart Banner for Phones and Tablets)
   *
   * banner is default
   */
  bannerSize: React.PropTypes.string,

  /**
   * AdMob ad unit ID
   */
  adUnitID: React.PropTypes.string,

  /**
   * Test device ID
   */
  testDeviceID: React.PropTypes.string,

  /**
   * AdMob iOS library events
   */
  adViewDidReceiveAd: React.PropTypes.func,
  didFailToReceiveAdWithError: React.PropTypes.func,
  adViewWillPresentScreen: React.PropTypes.func,
  adViewWillDismissScreen: React.PropTypes.func,
  adViewDidDismissScreen: React.PropTypes.func,
  adViewWillLeaveApplication: React.PropTypes.func,
  admobDispatchAppEvent: React.PropTypes.func,

  targetingDisabled: React.PropTypes.bool,

  targeting: React.PropTypes.shape({
    /**
     * Arbitrary object of custom targeting information.
     */
    customTargeting: React.PropTypes.object,

    /**
     * Array of exclusion labels.
     */
    categoryExclusions: React.PropTypes.arrayOf(React.PropTypes.string),

    /**
     * Array of keyword strings.
     */
    keywords: React.PropTypes.arrayOf(React.PropTypes.string),

    /**
     * When using backfill or an SDK mediation creative, gender can be supplied
     * in the ad request for targeting purposes.
     */
    gender: React.PropTypes.oneOf(['unknown', 'male', 'female']),

    /**
     * When using backfill or an SDK mediation creative, birthday can be supplied
     * in the ad request for targeting purposes.
     */
    birthday: React.PropTypes.instanceOf(Date),

    /**
     * Indicate that you want Google to treat your content as child-directed.
     */
    childDirectedTreatment: React.PropTypes.bool,

    /**
     * Applications that monetize content matching a webpage's content may pass
     * a content URL for keyword targeting.
     */
    contentURL: React.PropTypes.string,

    /**
     * You can set a publisher provided identifier (PPID) for use in frequency
     * capping, audience segmentation and targeting, sequential ad rotation, and
     * other audience-based ad delivery controls across devices.
     */
    publisherProvidedID: React.PropTypes.string,

    /**
     * The user’s current location may be used to deliver more relevant ads.
     */
    location: React.PropTypes.shape({
      latitude: React.PropTypes.number,
      longitude: React.PropTypes.number,
      accuracy: React.PropTypes.number,
    }),
  }),

  ...View.propTypes,
};

PublisherBanner.defaultProps = { 
  bannerSize: 'smartBannerPortrait',
  didFailToReceiveAdWithError: () => {},
  admobDispatchAppEvent: () => {},
  targetingDisabled: true,
};
