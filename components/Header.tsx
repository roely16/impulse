import { View, SafeAreaView, StyleSheet } from 'react-native';
import { Text, IconButton } from 'react-native-paper';

export const Header = () => {
  return (
    <SafeAreaView>
      <View style={styles.container}>
        <Text style={styles.appName} variant="headlineSmall">impulse.</Text>
        <IconButton
          icon="account"
          iconColor={'black'}
          size={20}
          mode="contained"
        />
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
    backgroundColor: 'white'
  },
  appName: {
    fontSize: 24,
    lineHeight: 25,
    fontWeight: 600
  }
});