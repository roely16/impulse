import { useState, useEffect } from 'react';
import { View, SafeAreaView, StyleSheet, NativeModules, ScrollView, Image } from 'react-native';
import { Button, Text } from 'react-native-paper';
import { PermissionImage } from '@/components/PermissionImage';
import { router } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function HomeScreen() {

  const { ScreenTimeModule } = NativeModules;

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

  useEffect(() => {
    const validateScreenTimeAccess = async () => {
      setIsLoading(true);
      const screenTimeAccess = await AsyncStorage.getItem('screenTimeAccess');
      if (screenTimeAccess) {
        router.replace('/(tabs)')
      }
      setIsLoading(false);
    }
    validateScreenTimeAccess();
  }, []);

  if (isLoading) {
    return <></>
  }

  return (
    <SafeAreaView style={styles.safeareaContainer}>
      <ScrollView style={styles.container}>
        <View>
          <Text style={styles.title}>Permite el acceso al Tiempo de Uso</Text>
        </View>
        <View style={{ gap: 20, marginTop: 20, marginBottom: 40 }}>
          <View style={{ flexDirection: 'row', gap: 20 }}>
            <Image source={require('../assets/images/smartphone.png')} />
            <Text style={styles.information}>Para bloquear apps & webs, necesitamos permiso.</Text>
          </View>
          <View style={{ flexDirection: 'row', gap: 20 }}>
            <Image source={require('../assets/images/password-hide.png')} />
            <Text style={styles.information}>La informacón del Tiempo de Uso está <Text style={{ fontWeight: '700' }}>protegida por Apple</Text> y estará <Text style={{ fontWeight: '700' }}>almacenada 100% en tu movil</Text>.</Text>
          </View>
        </View>
        <View style={{ alignItems: 'center' }}>
          <PermissionImage />
        </View>
      </ScrollView>
      <View style={styles.buttonContainer}>
        <Button onPress={handleScreenTimeAccess} icon="arrow-right" labelStyle={styles.labelStartButton} contentStyle={styles.containerStartButton} style={styles.startButton} mode="contained">Empezar</Button>
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
    paddingHorizontal: 30,
    flex: 1,
    paddingBottom: 20,
    paddingTop: 20
  },
  title: {
    fontSize: 32,
    textAlign: 'center',
    fontWeight: 700,
    lineHeight: 46.8
  },
  information: {
    flex: 1,
    fontSize: 16,
    fontWeight: '400',
    lineHeight: 24
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
    bottom: 20,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30
  }
});
