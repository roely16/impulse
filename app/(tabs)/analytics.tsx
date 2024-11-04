import { useCallback } from "react";
import { ScrollView, View } from "react-native";
import { Text } from "react-native-paper";
import { useFocusEffect } from "expo-router";
import { StyleSheet } from 'react-native';
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { RFValue } from "react-native-responsive-fontsize";
import { widthPercentageToDP as wp, heightPercentageToDP as hp } from "react-native-responsive-screen";
import { WeeklyUsageTime } from "@/components/WeeklyUsageTime";
import { DailyUsageTime } from "@/components/DailyUsageTime";
import { OpeningAttempts } from "@/components/OpeningAttempts";

export default function TabTwoScreen() {

  const { t } = useTranslation();

  useFocusEffect(
    useCallback(() => {
      MixpanelService.trackEvent('metrics_page', {
        entry_point: 'snackbar',
        timestamp: new Date().toISOString()
      });
    }, [])
  );

  return (
    <ScrollView style={styles.container}>
      <View style={{ gap: hp('2%') }}>
        <Text style={styles.title}>{t('usageReportScreen.title')}</Text>
        <View style={{ gap: hp('3%') }}>
          <WeeklyUsageTime />
          <DailyUsageTime />
          <OpeningAttempts />
        </View>
      </View>
      
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    flex: 1,
    paddingHorizontal: wp('6%'),
    paddingVertical: hp('2%')
  },
  title: {
    fontFamily: 'Catamaran',
    fontWeight: '700',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    lineHeight: RFValue(28.6, SCREEN_HEIGHT),
    textAlign: 'center'
  }
});
