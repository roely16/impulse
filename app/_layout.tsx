import { useState, useEffect } from 'react';
import { useFonts } from 'expo-font';
import { Stack, router } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import 'react-native-reanimated';
import { Header } from '@/components/Header';
import { MixpanelService } from '@/SDK/Mixpanel';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {

  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loadingAuth, setLoadingAuth] = useState(true);

  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  });

  MixpanelService.init();

  useEffect(() => {
    const validateScreenTimeAccess = async () => {
      const screenTimeAccess = await AsyncStorage.getItem('screenTimeAccess');
      const userIsAuthenticated = !!screenTimeAccess;
      setIsAuthenticated(userIsAuthenticated);
      setLoadingAuth(false);
      if (userIsAuthenticated) {
        // Espera a que el layout se haya montado y luego redirige
        router.replace('/(tabs)'); // Ajusta la ruta según tu estructura de rutas
      }
    }
    validateScreenTimeAccess();
  }, []);

  useEffect(() => {
    if (loaded && !loadingAuth) {
      // SplashScreen.hideAsync();
    }
  }, [loaded, loadingAuth, isAuthenticated]);

  return (
    <Stack>
      <Stack.Screen name="index" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="impulse-functionalities" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="how-much-time" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="save-time-screen" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="access-screen-time" options={{ headerShown: false }}></Stack.Screen>
      <Stack.Screen name="(tabs)" options={{ header: () => <Header /> }} />
    </Stack>
  );
}
