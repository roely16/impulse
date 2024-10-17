import { View, StyleSheet, SafeAreaView, Image, ScrollView } from "react-native";
import { Text, Button } from "react-native-paper";
import { router } from 'expo-router';
import { MixpanelService } from '@/SDK/Mixpanel';

export default function WelcomeScreen() {

  const redirectToHowMuchTimeScreen = () => {
    router.push('/how-much-time')
    MixpanelService.trackEvent("onboarding_step_1", {
      onboarding_step: 1,   
      device_type: "iOS",    
      timestamp: new Date().toISOString()
    });
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.contentContainer}>
        <Text style={styles.title}>
          Ayudate a controlar los impulsos y gana horas en tu día a día
        </Text>
        <Image source={require('../assets/images/welcome.png')} style={styles.image} />
        <Text style={styles.subtitle}>
          Los usuarios ya han conseguido ahorrar más de 5000 horas controlando el uso del móvil
        </Text>
      </ScrollView>
      <View style={styles.buttonContainer}>
        <Button
          style={styles.button}
          labelStyle={{ color: 'black' }}
          buttonColor="#FDE047"
          mode="contained"
          onPress={redirectToHowMuchTimeScreen}
          contentStyle={{ flexDirection: 'row-reverse' }}
          icon="arrow-right"
        >
          Empezar
        </Button>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  contentContainer: {
    paddingHorizontal: 30,
    paddingVertical: 10
  },
  title: {
    fontSize: 36,
    fontWeight: '700',
    lineHeight: 46.8,
    textAlign: 'center'
  },
  image: {
    alignSelf: 'center',
    marginTop: 20
  },
  subtitle: {
    fontSize: 22,
    fontWeight: '400',
    lineHeight: 33,
    textAlign: 'center',
    marginTop: 20
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 20,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
});
