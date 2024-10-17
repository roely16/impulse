import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { useEffect } from 'react';
import 'react-native-reanimated';
import { Header } from '@/components/Header';
import { MixpanelService } from '@/SDK/Mixpanel';

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  });

  MixpanelService.init();
  
  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync();
    }
  }, [loaded]);

  if (!loaded) {
    return null;
  }

  return (
    <Stack initialRouteName="index">
      <Stack.Screen name="index" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="impulse-functionalities" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="how-much-time" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="save-time-screen" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="access-screen-time" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="(tabs)" options={{ header: () => <Header /> }} />
    </Stack>
  );
}
