import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import 'react-native-reanimated';
import { Header } from '@/components/Header';
import { MixpanelService } from '@/SDK/Mixpanel';
import { I18nextProvider } from 'react-i18next';
import i18n from '@/locales/i18n';

export default function RootLayout() {

  useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
    Catamaran: require('../assets/fonts/Catamaran-VariableFont_wght.ttf'),
    Mulish: require('../assets/fonts/Mulish-VariableFont_wght.ttf')
  });

  MixpanelService.init();

  return (
    <I18nextProvider i18n={i18n}>
      <Stack>
        <Stack.Screen name="index" options={{ headerShown: false}}></Stack.Screen>
        <Stack.Screen name="impulse-functionalities" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="how-much-time" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="save-time-screen" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen name="access-screen-time" options={{ headerShown: false }}></Stack.Screen>
        <Stack.Screen
          name="(tabs)"
          options={{
            header: () => <Header />,
            animation: 'none'
          }}
        />
      </Stack>
    </I18nextProvider>
  );
}
