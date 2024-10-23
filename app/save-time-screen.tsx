import { View, StyleSheet } from "react-native";
import { Text } from "react-native-paper";
import { router, useLocalSearchParams } from 'expo-router';
import { useTranslation } from "react-i18next";
import { RFValue } from "react-native-responsive-fontsize";
import { heightPercentageToDP as hp } from "react-native-responsive-screen";
import { OnboardingContainer } from "@/components/OnboardingContainer";
import { SCREEN_HEIGHT } from "@/constants/Device";

export default function SaveTime() {

  const { t } = useTranslation();
  const local = useLocalSearchParams();

  const redirectToHowMuchTimeScreen = () => {
    router.push('/impulse-functionalities')
  };

  return (
    <OnboardingContainer onPress={redirectToHowMuchTimeScreen} buttonLabel={t('saveTimeScreen.startButton')}>
      <View>
        <View>
          <Text style={styles.firstText}>
            {t('saveTimeScreen.firstText')}
          </Text>
        </View>
        <Text style={styles.title}>
          { local.days } {t('saveTimeScreen.days')}
        </Text>
        <Text style={styles.subtitle}>
          {t('saveTimeScreen.secondText')}
        </Text>
        <Text style={[styles.subtitle, { marginBottom: hp('3%') }]}>
          {t('saveTimeScreen.thirdText')}
        </Text>
      </View>
      <View>
        <Text style={[styles.subtitle, { marginBottom: hp('3%') }]}>
          {t('saveTimeScreen.fourthText')}
        </Text>
        <Text style={styles.title}>
          { local.years } {t('saveTimeScreen.years')}
        </Text>
        <Text style={[styles.subtitle, { fontWeight: '700', marginTop: hp('3%') }]}>
          {t('saveTimeScreen.fifthText')}
        </Text>
      </View>
    </OnboardingContainer>
  )
}

const styles = StyleSheet.create({
  firstText: {
    fontFamily: 'Mulish',
    fontWeight: '700',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    lineHeight: RFValue(33, SCREEN_HEIGHT),
    textAlign: 'center',
    marginBottom: hp('4%')
  },
  title: {
    fontSize: RFValue(50, SCREEN_HEIGHT),
    fontWeight: '700',
    lineHeight: RFValue(65, SCREEN_HEIGHT),
    textAlign: 'center',
    fontFamily: 'Catamaran'
  },
  subtitle: {
    fontSize: RFValue(22, SCREEN_HEIGHT),
    fontWeight: '400',
    lineHeight: RFValue(33, SCREEN_HEIGHT),
    textAlign: 'center',
    marginTop: hp('2%'),
    fontFamily: 'Mulish'
  }
});
