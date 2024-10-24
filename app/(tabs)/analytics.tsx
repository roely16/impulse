import { useCallback } from "react";
import { useFocusEffect } from "expo-router";
import { StyleSheet } from 'react-native';
import { MixpanelService } from "@/SDK/Mixpanel";

export default function TabTwoScreen() {

  useFocusEffect(
    useCallback(() => {
      MixpanelService.trackEvent('metrics_page', {
        entry_point: 'snackbar',
        timestamp: new Date().toISOString()
      });
    }, [])
  );

  return (
    <></>
  );
}

const styles = StyleSheet.create({
});
