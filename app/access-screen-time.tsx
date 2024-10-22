import { useState } from 'react';
import { View, SafeAreaView, StyleSheet, NativeModules, ScrollView, Image } from 'react-native';
import { Button, Text } from 'react-native-paper';
import { PermissionImage } from '@/components/PermissionImage';
import { router } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useTranslation } from 'react-i18next';

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
    <SafeAreaView style={styles.safeareaContainer}>
      <ScrollView style={styles.container}>
        <View>
          <Text style={styles.title}>
            {t('screenTimeAccess.title')}
          </Text>
        </View>
        <View style={{ gap: 20, marginTop: 20, marginBottom: 40 }}>
          <View style={{ flexDirection: 'row', gap: 20, alignItems: 'center' }}>
            <Image source={require('../assets/images/smartphone.png')} />
            <Text style={styles.information}>
              {t('screenTimeAccess.infoOne')}
            </Text>
          </View>
          <View style={{ flexDirection: 'row', gap: 20, alignItems: 'center' }}>
            <Image source={require('../assets/images/password-hide.png')} />
            <Text style={styles.information}>{t('screenTimeAccess.infoTwo.first')}<Text style={{ fontWeight: '700' }}>{t('screenTimeAccess.infoTwo.second')}</Text>{t('screenTimeAccess.infoTwo.third')}<Text style={{ fontWeight: '700' }}>{t('screenTimeAccess.infoTwo.fourth')}</Text>.</Text>
          </View>
        </View>
        <View style={{ alignItems: 'center' }}>
          <PermissionImage />
        </View>
      </ScrollView>
      <View style={styles.buttonContainer}>
        <Button onPress={handleScreenTimeAccess} icon="arrow-right" labelStyle={styles.labelStartButton} contentStyle={styles.containerStartButton} style={styles.startButton} mode="contained">{t('screenTimeAccess.startButton')}</Button>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeareaContainer: {
    flex: 1,
    backgroundColor: 'white'
  },
  container: {
    paddingHorizontal: 40,
    flex: 1,
    paddingVertical: 40,
  },
  title: {
    fontSize: 36,
    textAlign: 'center',
    fontWeight: '700',
    lineHeight: 46.8,
    fontFamily: 'Catamaran'
  },
  information: {
    flex: 1,
    fontSize: 16,
    fontWeight: '400',
    lineHeight: 24,
    fontFamily: 'Mulish'
  },
  startButton: {
    borderRadius: 6
  },
  containerStartButton: {
    backgroundColor: '#FDE047',
    paddingVertical: 7,
    paddingHorizontal: 16,
    flexDirection: 'row-reverse',
    gap: 8
  },
  labelStartButton: {
    color: 'back',
    fontSize: 16,
    fontWeight: 600,
    lineHeight: 24,
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30
  }
});
