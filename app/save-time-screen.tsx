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
          <View>
            <Text style={{ fontFamily: 'Mulish', fontWeight: '700', fontSize: 22, lineHeight: 33, textAlign: 'center', marginBottom: 40 }}>
              Según tu uso diario, pasas...
            </Text>
          </View>
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
          <Text style={[styles.subtitle, { marginBottom: 40 }]}>
            En una vida, eso suma
          </Text>
          <Text style={styles.title}>
            { local.years } años
          </Text>
          <Text style={[styles.subtitle, { fontWeight: '700', marginTop: 40 }]}>
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
          Empezar el cambio
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
    paddingHorizontal: 55,
    paddingVertical: 40,
    gap: 50
  },
  title: {
    fontSize: 50,
    fontWeight: '700',
    lineHeight: 65,
    textAlign: 'center',
    fontFamily: 'Catamaran'
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
    marginTop: 20,
    fontFamily: 'Mulish'
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 20,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 40
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
});
