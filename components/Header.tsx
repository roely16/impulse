import { View, SafeAreaView, StyleSheet, TouchableOpacity } from 'react-native';
import { Text } from 'react-native-paper';
import { Feather } from '@expo/vector-icons';
import { router } from "expo-router";

export const Header = () => {

  const goSettings = () => {
    router.push('/settings')
  } 

  return (
    <SafeAreaView>
      <View style={styles.container}>
        <View>
          <Text style={styles.appName} variant="headlineSmall">impulse.</Text>
        </View>
        <TouchableOpacity onPress={goSettings} style={styles.iconWrapper}>
          <Feather name='settings' size={20} color='black' />
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  )
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingBottom: 10,
    alignItems: 'center',
    backgroundColor: 'white',
  },
  appName: {
    fontSize: 24,
    fontWeight: 600,
    fontFamily: 'Catamaran'
  },
  iconWrapper: {
    backgroundColor: '#F6F6F6',
    padding: 10,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  }
});