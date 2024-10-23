import { useState } from 'react';
import { View, StyleSheet, NativeModules, Image } from 'react-native';
import { Text } from 'react-native-paper';
import { PermissionImage } from '@/components/PermissionImage';
import { router } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useTranslation } from 'react-i18next';
import { OnboardingContainer } from '@/components/OnboardingContainer';
import { RFValue } from "react-native-responsive-fontsize";
import { heightPercentageToDP as hp } from "react-native-responsive-screen";
import { SCREEN_HEIGHT } from "@/constants/Device";

export default function HomeScreen() {

  const { ScreenTimeModule } = NativeModules;

  const { t } = useTranslation();
  const [isLoading, setIsLoading] = useState(false);

  const handleScreenTimeAccess = async () => {
    try {
      const response = await ScreenTimeModule.requestAuthorization();
      if (response?.status === 'success') {
        router.replace('/(tabs)')
        await saveScreenTimeAccess();
      }
    } catch (error) {
      console.error(error);
    }
  }
  
  const saveScreenTimeAccess = async () => {
    try {
      await AsyncStorage.setItem('screenTimeAccess', 'true');
    } catch (error) {
      console.error(error);
    }
  }

  if (isLoading) {
    return <></>
  }

  return (
    <OnboardingContainer onPress={handleScreenTimeAccess} buttonLabel={t('screenTimeAccess.startButton')}>
      <Text style={styles.title}>
        {t('screenTimeAccess.title')}
      </Text>
      <View style={{ gap: hp('2%'), marginTop: hp('2%'), marginBottom: hp('6%') }}>
        <View style={{ flexDirection: 'row', gap: hp('2%'), alignItems: 'center' }}>
          <Image source={require('../assets/images/smartphone.png')} />
          <Text style={styles.information}>
            {t('screenTimeAccess.infoOne')}
          </Text>
        </View>
        <View style={{ flexDirection: 'row', gap: hp('2%'), alignItems: 'center' }}>
          <Image source={require('../assets/images/password-hide.png')} />
          <Text style={styles.information}>{t('screenTimeAccess.infoTwo.first')}<Text style={{ fontWeight: '700' }}>{t('screenTimeAccess.infoTwo.second')}</Text>{t('screenTimeAccess.infoTwo.third')}<Text style={{ fontWeight: '700' }}>{t('screenTimeAccess.infoTwo.fourth')}</Text>.</Text>
        </View>
      </View>
      <View style={{ alignItems: 'center' }}>
        <PermissionImage />
      </View>
    </OnboardingContainer>
  );
}

const styles = StyleSheet.create({
  title: {
    fontSize: RFValue(36, SCREEN_HEIGHT),
    textAlign: 'center',
    fontWeight: '700',
    lineHeight: RFValue(46.8, SCREEN_HEIGHT),
    fontFamily: 'Catamaran'
  },
  information: {
    flex: 1,
    fontSize: RFValue(16, SCREEN_HEIGHT),
    fontWeight: '400',
    lineHeight: RFValue(24, SCREEN_HEIGHT),
    fontFamily: 'Mulish'
  }
});
