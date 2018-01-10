import React from 'react';
import PropTypes from 'prop-types';
import {
  NativeModules,
  requireNativeComponent,
  View,
  NativeEventEmitter,
  ViewPropTypes,
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
			adSizes,
			onAdViewWillChangeAdSizeTo,
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
					adSizes={adSizes}
					onAdViewWillChangeAdSizeTo={onAdViewWillChangeAdSizeTo}
        />
      </View>
    );
  }
}

PublisherBanner.propTypes = {
  ...ViewPropTypes,

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
  bannerSize: PropTypes.string,

  /**
   * AdMob ad unit ID
   */
  adUnitID: PropTypes.string,

  /**
   * Test device ID
   */
  testDeviceID: PropTypes.string,

  /**
   * AdMob iOS library events
   */
  adViewDidReceiveAd: PropTypes.func,
  didFailToReceiveAdWithError: PropTypes.func,
  adViewWillPresentScreen: PropTypes.func,
  adViewWillDismissScreen: PropTypes.func,
  adViewDidDismissScreen: PropTypes.func,
  adViewWillLeaveApplication: PropTypes.func,
  admobDispatchAppEvent: PropTypes.func,

	/**
	 * Tell component if targeting is enabled
	 * so it doesn't wait for targeting prop to be set.
	 */

  targetingDisabled: PropTypes.bool,

  targeting: PropTypes.shape({
    /**
     * Arbitrary object of custom targeting information.
     */
    customTargeting: PropTypes.object,

    /**
     * Array of exclusion labels.
     */
    categoryExclusions: PropTypes.arrayOf(PropTypes.string),

    /**
     * Array of keyword strings.
     */
    keywords: PropTypes.arrayOf(PropTypes.string),

    /**
     * When using backfill or an SDK mediation creative, gender can be supplied
     * in the ad request for targeting purposes.
     */
    gender: PropTypes.oneOf(['unknown', 'male', 'female']),

    /**
     * When using backfill or an SDK mediation creative, birthday can be supplied
     * in the ad request for targeting purposes.
     */
    birthday: PropTypes.instanceOf(Date),

    /**
     * Indicate that you want Google to treat your content as child-directed.
     */
    childDirectedTreatment: PropTypes.bool,

    /**
     * Applications that monetize content matching a webpage's content may pass
     * a content URL for keyword targeting.
     */
    contentURL: PropTypes.string,

    /**
     * You can set a publisher provided identifier (PPID) for use in frequency
     * capping, audience segmentation and targeting, sequential ad rotation, and
     * other audience-based ad delivery controls across devices.
     */
    publisherProvidedID: PropTypes.string,

    /**
     * The user’s current location may be used to deliver more relevant ads.
     */
    location: PropTypes.shape({
      latitude: PropTypes.number,
      longitude: PropTypes.number,
      accuracy: PropTypes.number,
    }),
  }),

	/**
	 * Array of valid ad sizes.
	 * First element is width and height is second.
	 * const size1 = [150, 50];
	 * const size2 = [234, 60];
	 * adSizes = [size1, size2];
	 */
	adSizes: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.number)),

	/**
	 * Called when ad will change its size.
	 * Usefull when using array of custom sizes.
	 */
	onAdViewWillChangeAdSizeTo: PropTypes.func,
};

PublisherBanner.defaultProps = {
  bannerSize: 'smartBannerPortrait',
  didFailToReceiveAdWithError: () => {},
  admobDispatchAppEvent: () => {},
  targetingDisabled: true,
};
