import { View, SafeAreaView, StyleSheet, NativeModules } from 'react-native';
import { Button, Text } from 'react-native-paper';
import { PermissionImage } from '@/components/PermissionImage';
import { Link } from 'expo-router';

export default function HomeScreen() {

  const { CalendarModule } = NativeModules;

  const handleScreenTimeAccess = async () => {
    try {
      await CalendarModule.addEvent(
        "Meeting", 
        "Office", 
        new Date().getTime(), 
        new Date().getTime() + 60 * 60 * 1000
      );
    } catch (error) {
      console.error(error);
    }
  }
  
  return (
    <SafeAreaView style={styles.safeareaContainer}>
      <View style={styles.container}>
        <View>
          <Text style={styles.title}>Permite el acceso al Tiempo de Uso</Text>
        </View>
        <PermissionImage />
        <View>
          <Text style={styles.informationMessage}>
            Tu información está protegida por Apple y estará almacenada 100% en tu movil.
          </Text>
          <View style={styles.buttonContainer}>
            {/* <Link href="/(tabs)/">
              
            </Link> */}
            <Button onPress={handleScreenTimeAccess} icon="arrow-right" labelStyle={styles.labelStartButton} contentStyle={styles.containerStartButton} style={styles.startButton} mode="contained">Empezar</Button>
          </View>
        </View>
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
    alignItems: 'center',
    flex: 1,
    justifyContent: 'space-between',
    paddingBottom: 20,
    paddingTop: 20
  },
  title: {
    fontSize: 32,
    textAlign: 'center',
    fontWeight: 700,
    lineHeight: 46.8
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
  informationMessage: {
    fontSize: 16,
    fontWeight: 400,
    lineHeight: 24,
    textAlign: 'center',
    marginBottom: 30
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'center'
  }
});
