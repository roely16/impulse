import { View, StyleSheet, Image } from "react-native";
import { Text } from "react-native-paper";
import { router } from 'expo-router';
import { useTranslation } from "react-i18next";
import { OnboardingContainer } from "@/components/OnboardingContainer";
import { RFValue } from "react-native-responsive-fontsize";
import { heightPercentageToDP as hp, widthPercentageToDP as wp } from "react-native-responsive-screen";
import { SCREEN_HEIGHT } from "@/constants/Device";

export default function ImpulseFunctionalities() {

  const { t } = useTranslation();
  const redirectToHowMuchTimeScreen = () => {
    router.push('/access-screen-time')
  };

  return (
    <OnboardingContainer onPress={redirectToHowMuchTimeScreen} buttonLabel={t('impulseFunctionalities.continueButton')}>
      <Text style={styles.header}>{t('impulseFunctionalities.title')}</Text>
        <View style={{ marginTop: hp('4%'), gap: hp('8%') }}>
          <View style={{ flexDirection: 'row', gap: wp('3%') }}>
            <Image source={require('../assets/images/sand-timer.png')} />
            <View style={{ flex: 1, gap: hp('1%'), flexDirection: 'column', paddingTop: 5 }}>
              <Text style={styles.title}>
                {t('impulseFunctionalities.blockAppsTitle')}
              </Text>
              <Text style={styles.subtitle}>
                {t('impulseFunctionalities.blockAppsSubtitle')}
              </Text>
            </View>
          </View>
          <View style={{ flexDirection: 'row', gap: wp('3%') }}>
            <Image source={require('../assets/images/pulse.png')} />
            <View style={{ flex: 1, gap: hp('1%'), flexDirection: 'column', paddingTop: 5 }}>
              <Text style={styles.title}>
                {t('impulseFunctionalities.impulseModeTitle')}
              </Text>
              <Text style={styles.subtitle}>
                {t('impulseFunctionalities.impulseModeSubtitle')}
              </Text>
            </View>
          </View>
        </View>
    </OnboardingContainer>
  )
}

const styles = StyleSheet.create({
  header: {
    fontSize: RFValue(30, SCREEN_HEIGHT),
    fontWeight: '700',
    lineHeight: RFValue(39, SCREEN_HEIGHT),
    fontFamily: 'Catamaran'
  },
  title: {
    fontSize: RFValue(24, SCREEN_HEIGHT),
    fontWeight: '700',
    lineHeight: RFValue(31.2, SCREEN_HEIGHT),
    fontFamily: 'Catamaran'
  },
  subtitle: {
    fontSize: RFValue(16, SCREEN_HEIGHT),
    fontWeight: '400',
    lineHeight: RFValue(24, SCREEN_HEIGHT),
    flexShrink: 1,
    fontFamily: 'Mulish'
  }
});
