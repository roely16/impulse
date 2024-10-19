import { View, StyleSheet, SafeAreaView, Image, ScrollView } from "react-native";
import { Text, Button } from "react-native-paper";
import { router } from 'expo-router';

export default function ImpulseFunctionalities() {

  const redirectToHowMuchTimeScreen = () => {
    router.push('/access-screen-time')
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.contentContainer}>
        <Text style={styles.header}>Las dos funcionalidades que harán que recuperes tu tiempo</Text>
        <View style={{ marginTop: 40, gap: 50 }}>
          <View style={{ flexDirection: 'row', gap: 10 }}>
            <Image source={require('../assets/images/sand-timer.png')} />
            <View style={{ flex: 1, gap: 5, flexDirection: 'column' }}>
              <Text style={styles.title}>Bloqueo de Apps</Text>
              <Text style={styles.subtitle}>Programa horas específicas en las que bloquear esas aplicaciones que te distraen, permitiéndote enfocarte en lo que realmente importa. </Text>
            </View>
          </View>
          <View style={{ flexDirection: 'row', gap: 10 }}>
            <Image source={require('../assets/images/pulse.png')} />
            <View style={{ flex: 1, gap: 5, flexDirection: 'column' }}>
              <Text style={styles.title}>Modo Impulsos</Text>
              <Text style={styles.subtitle}>¿Sientes la tentación constante de revisar tus aplicaciones sin motivo alguno? Te ayudaremos a controlar esos impulsos.</Text>
            </View>
          </View>
        </View>
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
          Continuar
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
    paddingHorizontal: 40,
    paddingVertical: 40
  },
  header: {
    fontSize: 30,
    fontWeight: '700',
    lineHeight: 39,
    fontFamily: 'Catamaran'
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    lineHeight: 31.2,
    fontFamily: 'Catamaran'
  },
  subtitle: {
    fontSize: 16,
    fontWeight: '400',
    lineHeight: 24,
    flexShrink: 1,
    fontFamily: 'Mulish'
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 40,
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
