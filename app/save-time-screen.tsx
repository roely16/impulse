import { View, StyleSheet, SafeAreaView, Image, ScrollView } from "react-native";
import { Text, Button } from "react-native-paper";
import { router, useLocalSearchParams } from 'expo-router';

export default function SaveTime() {

  const local = useLocalSearchParams();

  const redirectToHowMuchTimeScreen = () => {
    router.push('/impulse-functionalities')
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.contentContainer}>
        <View>
          <Text style={styles.title}>
            { local.days } días
          </Text>
          <Text style={styles.subtitle}>
            al año perdidos frente a la pantalla...
          </Text>
          <Text style={styles.subtitle}>
            Piensa lo que podrías hacer con ese tiempo si cambias tus hábitos hoy.
          </Text>
        </View>
        <View>
          <Text style={styles.subtitle}>
            En una vida, eso suma
          </Text>
          <Text style={styles.title}>
            { local.years } años
          </Text>
          <Text style={[styles.subtitle, { fontWeight: '700' }]}>
            ¿Estás listo para aprovechar tu tiempo al máximo?
          </Text>
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
    paddingHorizontal: 30,
    paddingVertical: 50,
    gap: 50
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
