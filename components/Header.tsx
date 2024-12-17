import { View, SafeAreaView, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { Feather } from '@expo/vector-icons';
import { getVersion, getBuildNumber } from 'react-native-device-info';

export const Header = () => {
  return (
    <SafeAreaView>
      <View style={styles.container}>
        <View>
          <Text style={styles.appName} variant="headlineSmall">impulse.</Text>
          <Text style={{ fontSize: 12, color: 'gray' }}>{`${getVersion()} (${getBuildNumber()})`}</Text>
        </View>
        <View style={styles.iconWrapper}>
          <Feather name='user' size={20} color='black' />
        </View>
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