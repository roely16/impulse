import { useCallback, useEffect, useRef, useState } from "react";
import { View, StyleSheet, ScrollView, ActivityIndicator } from "react-native";
import { Button, Text } from "react-native-paper";
import { useFocusEffect } from "expo-router";
import { MixpanelService } from "@/SDK/Mixpanel";
import { useTranslation } from "react-i18next";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { RFValue } from "react-native-responsive-fontsize";
import { widthPercentageToDP as wp, heightPercentageToDP as hp } from "react-native-responsive-screen";
import { ImpulseControl } from "@/components/ImpulseControl/ImpulseControl";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import BottomSheet, { BottomSheetModalProvider } from '@gorhom/bottom-sheet';
import { LimitType } from "@/components/LimitCard";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { BottomSheetBlockAndLimit } from '@/components/BottomSheet';


export default function ImpulseScreen() {

  const bottomSheetRef = useRef<BottomSheet>(null);
  const [loading, setLoading] = useState(false);
  const [limits, setLimits] = useState<LimitType[]>([]);
  const [alreadyConfigured, setAlreadyConfigured] = useState(false);
  const { t } = useTranslation();

  const handleConfigure = async () => {
    await AsyncStorage.setItem('seeImpulseConfigScreen', 'true');
    setAlreadyConfigured(true);
  };

  useFocusEffect(
    useCallback(() => {
      MixpanelService.trackEvent('view_impulse_page', {
        entry_point: 'snackbar',
        timestamp: new Date().toISOString()
      });
    }, [])
  );

  useEffect(() => {
    setLoading(true);
    // Check if user has already configured impulse
    const checkUserConfig = async () => {
      const seeImpulseConfigScreen = await AsyncStorage.getItem('seeImpulseConfigScreen');
      if (seeImpulseConfigScreen) {
        // Load limits 
        setAlreadyConfigured(true);
      }
      setLoading(false);
    };
    checkUserConfig();
  }, []);

  if (loading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: 'white' }}>
        <ActivityIndicator animating={loading} color={'#FDE047'} size="large" />
      </View>
    )
  }

  const ScreenContent = () => {

    const handleNewImpulse = () => {
      bottomSheetRef.current?.expand();
    };

    if (!loading && alreadyConfigured) {
      return <ImpulseControl configNewImpulse={handleNewImpulse} limits={limits} />
    }

    return (
      <ScrollView style={styles.container}>
        <View>
          <Text style={styles.title}>{t('impulseWelcomeScreen.title')}</Text>
        </View>
        <View style={styles.messageContainer}>
          <Text style={styles.firstText}>{t('impulseWelcomeScreen.firstText')}</Text>
          <Text style={styles.secondtText}>{t('impulseWelcomeScreen.secondText')}</Text>
          <Text>
            <Text style={styles.thirdText}>{t('impulseWelcomeScreen.thirdText.first')}</Text>
            <Text style={styles.thirdTextBold}>{t('impulseWelcomeScreen.thirdText.second')}</Text>
            <Text style={styles.thirdText}>{t('impulseWelcomeScreen.thirdText.third')}</Text>
          </Text>
        </View>
        <View style={styles.buttonContainer}>
          <Button 
            style={styles.button} 
            buttonColor="#FDE047"
            contentStyle={{ flexDirection: 'row-reverse' }}
            icon="arrow-right"
            labelStyle={{ color: 'black' }}
            onPress={handleConfigure}
          >
            {t('impulseWelcomeScreen.configureButton')}
          </Button>
        </View>
      </ScrollView>
    )
  };

  const closedBottomSheet = () => {

  };
  
  return (
    <GestureHandlerRootView>
      <BottomSheetModalProvider>
        <ScreenContent />
        <BottomSheetBlockAndLimit bottomSheetForm="new-limit" onBottomSheetClosed={closedBottomSheet} ref={bottomSheetRef} />
      </BottomSheetModalProvider>
    </GestureHandlerRootView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
    paddingHorizontal: wp('6%'),
    paddingVertical: hp('2%')
  },
  title: {
    fontFamily: 'Catamaran',
    fontWeight: '700',
    fontSize: RFValue(36, SCREEN_HEIGHT),
    lineHeight: RFValue(46.8, SCREEN_HEIGHT),
    textAlign: 'center',
    marginBottom: hp('2%')
  },
  messageContainer: {
   gap: hp('3%')
  },
  firstText: {
    fontFamily: 'Mulish',
    fontWeight: '700',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    lineHeight: RFValue(33, SCREEN_HEIGHT),
    textAlign: 'center'
  },
  secondtText: {
    fontFamily: 'Mulish',
    fontWeight: '400',
    fontSize: RFValue(20, SCREEN_HEIGHT),
    lineHeight: RFValue(30, SCREEN_HEIGHT),
    textAlign: 'center',
    fontStyle: 'italic'
  },
  thirdText: {
    fontFamily: 'Mulish',
    fontWeight: '400',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    lineHeight: RFValue(33, SCREEN_HEIGHT),
    textAlign: 'center'
  },
  thirdTextBold: {
    fontFamily: 'Mulish',
    fontWeight: '700',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    lineHeight: RFValue(33, SCREEN_HEIGHT),
    textAlign: 'center'
  },
  buttonContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: hp('3%')
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  }
});