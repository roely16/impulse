import { useCallback } from "react";
import { useFocusEffect } from "expo-router";
import { MixpanelService } from "@/SDK/Mixpanel";

export default function ImpulseScreen() {

  useFocusEffect(
    useCallback(() => {
      MixpanelService.trackEvent('view_impulse_page', {
        entry_point: 'snackbar',
        timestamp: new Date().toISOString()
      });
    }, [])
  );
  
  return (
    <></>
  )
}