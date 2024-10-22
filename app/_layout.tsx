import { useState, useEffect } from 'react';
import { useFonts } from 'expo-font';
import { Stack, router } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import 'react-native-reanimated';
import { Header } from '@/components/Header';
import { MixpanelService } from '@/SDK/Mixpanel';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { I18nextProvider } from 'react-i18next';
import i18n from '@/locales/i18n';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {

  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loadingAuth, setLoadingAuth] = useState(true);

  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
    Catamaran: require('../assets/fonts/Catamaran-VariableFont_wght.ttf'),
    Mulish: require('../assets/fonts/Mulish-VariableFont_wght.ttf')
  });

  MixpanelService.init();

  useEffect(() => {
    const validateScreenTimeAccess = async () => {
      const screenTimeAccess = await AsyncStorage.getItem('screenTimeAccess');
      const userIsAuthenticated = !!screenTimeAccess;
      setIsAuthenticated(userIsAuthenticated);
      setLoadingAuth(false);
      if (userIsAuthenticated) {
        router.replace('/(tabs)');
      }
    }
    validateScreenTimeAccess();
  }, []);

  useEffect(() => {
    if (loaded && !loadingAuth) {
      SplashScreen.hideAsync();
    }
  }, [loaded, loadingAuth, isAuthenticated]);

  return (
    <I18nextProvider i18n={i18n}>
      <Stack>
        <Stack.Screen name="index" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="impulse-functionalities" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="how-much-time" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="save-time-screen" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="access-screen-time" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="(tabs)" options={{ header: () => <Header /> }} />
      </Stack>
    </I18nextProvider>
  );
}
