import { StyleSheet, Image } from "react-native";
import { Text } from "react-native-paper";
import { router } from 'expo-router';
import { MixpanelService } from '@/SDK/Mixpanel';
import { useTranslation } from "react-i18next";
import { heightPercentageToDP as hp, widthPercentageToDP as wp } from "react-native-responsive-screen";
import { RFValue } from "react-native-responsive-fontsize";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { OnboardingContainer } from "@/components/OnboardingContainer";

export default function WelcomeScreen() {

  const { t } = useTranslation();

  const redirectToHowMuchTimeScreen = () => {
    router.push('/how-much-time')
    MixpanelService.trackEvent("onboarding_step_1", {
      onboarding_step: 1,   
      device_type: "iOS",    
      timestamp: new Date().toISOString()
    });
  };

 return (
    <OnboardingContainer onPress={redirectToHowMuchTimeScreen} buttonLabel={t('welcomeScreen.startButton')}>
      <Text style={styles.title}>
        {t('welcomeScreen.title')}
      </Text>
      <Image resizeMode="contain" source={require('../assets/images/welcome.png')} style={styles.image} />
      <Text style={styles.subtitle}>
        {t('welcomeScreen.subtitle')}
      </Text>
    </OnboardingContainer>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: RFValue(36, SCREEN_HEIGHT),
    fontWeight: '700',
    lineHeight: RFValue(46.8, SCREEN_HEIGHT),
    textAlign: 'center',
    fontFamily: 'Catamaran'
  },
  image: {
    alignSelf: 'center',
    marginTop: hp('5%'),
    height: hp('30%')
  },
  subtitle: {
    fontSize: RFValue(22, SCREEN_HEIGHT),
    fontWeight: '400',
    lineHeight: RFValue(33, SCREEN_HEIGHT),
    textAlign: 'center',
    marginTop: hp('5%'),
    fontFamily: 'Mulish'
  }
});
