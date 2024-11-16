import { useState } from "react";
import { View, StyleSheet, NativeModules } from "react-native";
import { Text } from "react-native-paper";
import { router } from 'expo-router';
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useTranslation } from "react-i18next";
import { RFValue } from "react-native-responsive-fontsize";
import { heightPercentageToDP as hp, widthPercentageToDP as wp } from "react-native-responsive-screen";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { MixpanelService } from "@/SDK/Mixpanel";
import useTimeOnScreen from "@/hooks/useTimeOnScreen";

interface PermissionImageProps {
  updateIsLoading: (value: boolean) => void;
}

export const PermissionImage = (props: PermissionImageProps) => {
  
  const { updateIsLoading } = props;

  const { ScreenTimeModule } = NativeModules;
  const { t } = useTranslation();
  const [isLoading, setIsLoading] = useState(false);
  const getTimeOnScreen = useTimeOnScreen();

  const handleScreenTimeAccess = async () => {
    try {
      setIsLoading(true);
      updateIsLoading(true);
      const testBlockName = t('testBlockName');
      const response = await ScreenTimeModule.requestAuthorization(testBlockName);
      const timeSpent = getTimeOnScreen();
      if (response?.status === 'success') {
        MixpanelService.trackEvent('onboarding_complete', {
          onboarding_step: 5,
          device_type: 'iOS',
          did_allow_usage_access: true,
          time_spend_in_step: timeSpent,
          timestamp: new Date().toISOString()
        });
        router.replace('/(tabs)')
        await saveScreenTimeAccess();
        setIsLoading(false);
        updateIsLoading(false);
        return;
      }

      MixpanelService.trackEvent('onboarding_complete', {
        onboarding_step: 5,
        device_type: 'iOS',
        did_allow_usage_access: false,
        time_spend_in_step: timeSpent,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      console.error(error);
      setIsLoading(false);
      updateIsLoading(false);
    }
  }

  const saveScreenTimeAccess = async () => {
    try {
      await AsyncStorage.setItem('screenTimeAccess', 'true');
    } catch (error) {
      console.error(error);
    }
  }
  return (
    <View style={styles.container}>
      <View style={styles.contentContainer}>
        <View style={styles.darkContainer}>
          <Text variant="titleSmall" style={styles.title}>
            {t('screenTimeAccess.permissionButton.title')}
          </Text>
          <Text variant="bodySmall" style={styles.message}>
            {t('screenTimeAccess.permissionButton.message')}
          </Text>
        </View>
        <View style={styles.buttonContainer}>
          <Text onPress={handleScreenTimeAccess} disabled={isLoading} style={styles.buttonText}>
            {t('screenTimeAccess.permissionButton.allowButton')}
          </Text>
          <View style={styles.verticalDivider} />
          <Text style={styles.buttonText}>
            {t('screenTimeAccess.permissionButton.denyButton')}
          </Text>
        </View>
      </View>
    </View>
  )

};

const styles = StyleSheet.create({
  contentContainer: {
    borderWidth: 1,
    padding: hp('1%'),
    borderRadius: 10
  },
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    width: wp('75%'),
  },
  darkContainer: {
    backgroundColor: 'black',
    borderTopLeftRadius: 5,
    borderTopRightRadius: 5,
    paddingTop: 20,
    paddingBottom: 20,
    paddingHorizontal: 10
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: 'black',
    borderBottomLeftRadius: 5,
    borderBottomRightRadius: 5,
    borderWidth: 0.2,
    borderColor: 'gray',
  },
  title: {
    color: 'white',
    textAlign: 'center',
    fontSize: RFValue(14, SCREEN_HEIGHT)
  },
  message: {
    color: 'white',
    textAlign: 'center',
    marginTop: 5,
    fontSize: RFValue(12, SCREEN_HEIGHT),
    lineHeight: RFValue(14, SCREEN_HEIGHT)
  },
  buttonText: {
    color: '#375cb1',
    textAlign: 'center',
    fontSize: RFValue(16, SCREEN_HEIGHT),
    padding: 20,
    width: '48%'
  },
  iconContainer: {
    marginLeft: 30
  },
  verticalDivider: {
    width: 1,
    height: '100%',
    backgroundColor: 'gray',
    marginHorizontal: 0,
  },
});