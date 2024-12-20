import { router } from "expo-router";
import { useState } from "react";
import { StyleSheet, View } from "react-native";
import { IconButton, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { RFValue } from "react-native-responsive-fontsize";
import { heightPercentageToDP as hp, widthPercentageToDP as wp } from "react-native-responsive-screen";
import { OnboardingContainer } from "@/components/OnboardingContainer";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { MixpanelService } from "@/SDK/Mixpanel";
import useTimeOnScreen from "@/hooks/useTimeOnScreen";
import { useSharedValue, withSpring } from 'react-native-reanimated';
import { Slider } from 'react-native-awesome-slider';
import { GestureHandlerRootView } from "react-native-gesture-handler";

const DAYS_IN_A_YEAR = 365;
const HOURS_IN_A_DAY = 24;
const YEAR_IN_A_LIFE = 70;

export default function HowMuchTime() {

  const { t } = useTranslation();
  const [hours, setHours] = useState(3);
  const getTimeOnScreen = useTimeOnScreen();

  const progress = useSharedValue(3);
  const min = useSharedValue(0);
  const max = useSharedValue(10);

  const Hours = () => {
    return (
      <View style={styles.hourContainer}>
        <Text style={styles.hourNumber}>{hours}</Text>
        <Text style={styles.hourLetter}>h</Text>
      </View>
    )
  };

  const ProgressBar = () => {

    return (
      <GestureHandlerRootView>
        <Slider
          style={{ transform: [{ rotate: "-90deg" }], width: 300 }}
          progress={progress}
          minimumValue={min}
          maximumValue={max}
          sliderHeight={100}
          renderBubble={() => <></>}
          renderThumb={() => <></>}
          theme={{ minimumTrackTintColor: '#FDE047' }}
          onSlidingComplete={(value) => {
            setHours(Math.round(value));
          }}
        />
      </GestureHandlerRootView>
    );
  };

  const updateHours = (type: string) => {
    if (type === 'increase' && hours < 10) {
      setHours(hours + 1);
      progress.value = withSpring(hours + 1);
    } else if (type === 'decrease' && hours > 0) {
      setHours(hours - 1);
      progress.value = withSpring(hours - 1);
    }
  }

  const UpdateBarButtons = () => {
    return (
      <View style={styles.updateButtonsContainer}>
        <IconButton onPress={() => updateHours('increase')} icon="arrow-up" />
        <IconButton onPress={() => updateHours('decrease')} icon="arrow-down" />
      </View>
    )
  };

  const redirect = () => {
    const days = Math.round((hours * DAYS_IN_A_YEAR) / HOURS_IN_A_DAY);
    const years = Math.round((hours * DAYS_IN_A_YEAR * YEAR_IN_A_LIFE) / (HOURS_IN_A_DAY * DAYS_IN_A_YEAR));

    const timeSpent = getTimeOnScreen();

    MixpanelService.trackEvent("onboarding_time_selected", {
      onboarding_step: 2,
      selected_hours: hours,
      interaction_type: 'adjusted',
      initial_value: 3,
      time_spend_on_screen: timeSpent,
      slider_interaction: 2,
      devive_type: 'iOS',
    });

    router.push({ pathname: '/save-time-screen', params: { days, years } });

  };
 
  return (
    <OnboardingContainer scrollEnabled={false} onPress={redirect} buttonLabel={t('howMuchTime.continueButton')}>
      <Text style={styles.title}>
        {t('howMuchTime.title')}
      </Text>
      <Hours />
      <View style={styles.progressBarWrapper}>
        <ProgressBar />
        <UpdateBarButtons />
      </View>
    </OnboardingContainer>
  )
};

const styles = StyleSheet.create({
  title: {
    fontSize: RFValue(36, SCREEN_HEIGHT),
    fontWeight: '700',
    lineHeight: RFValue(46.8, SCREEN_HEIGHT),
    textAlign: 'center',
    fontFamily: 'Catamaran',
  },
  hourContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginVertical: hp('4%'),
    gap: wp('2%')
  },
  hourLetter: {
    fontSize: RFValue(40, SCREEN_HEIGHT),
    fontWeight: '400',
    lineHeight: RFValue(52, SCREEN_HEIGHT),
    fontFamily: 'Catamaran',
    paddingTop: 5
  },
  hourNumber: {
    fontSize: RFValue(50, SCREEN_HEIGHT),
    fontWeight: '700',
    lineHeight: RFValue(65, SCREEN_HEIGHT),
    fontFamily: 'Catamaran'
  },
  progressBarWrapper: {
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    marginTop: hp('10%')
  },
  progressBarContainer: {
    borderWidth: 1,
    width: wp('25%'),
    height: hp('35%'),
    backgroundColor: '#FDE047',
    borderRadius: 6
  },
  progressBar: {
    backgroundColor: 'white',
    width: '100%',
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
  },
  updateButtonsContainer: {
    position: 'absolute',
    right: 50,
    justifyContent: 'center',
    alignItems: 'center'
  }
});
