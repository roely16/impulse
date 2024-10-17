import { View, StyleSheet } from "react-native";
import { Text, Icon } from "react-native-paper";

export const PermissionImage = () => {
  return (
    <View style={styles.container}>
      <View style={styles.contentContainer}>
        <View style={styles.darkContainer}>
          <Text variant="titleSmall" style={styles.title}>"Impulse" Would Like to Access Screen Time</Text>
          <Text variant="bodySmall" style={styles.message}>Providing "Impulse" access to Screen Time may allow it to see your activity data, restrict content, and limit the usage of apps and websites.</Text>
        </View>
        <View style={styles.buttonContainer}>
          <Text style={styles.buttonText}>Continue</Text>
          <View style={styles.verticalDivider} />
          <Text style={styles.buttonText}>Don't allow</Text>
        </View>
      </View>
    </View>
  )

};

const styles = StyleSheet.create({
  contentContainer: {
    borderWidth: 1,
    padding: 10,
    borderRadius: 10
  },
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    width: '85%'
  },
  darkContainer: {
    backgroundColor: 'black',
    borderTopLeftRadius: 5,
    borderTopRightRadius: 5,
    paddingTop: 20,
    paddingBottom: 20,
    paddingHorizontal: 10
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: 'black',
    borderBottomLeftRadius: 5,
    borderBottomRightRadius: 5,
    borderWidth: 0.2,
    borderColor: 'gray',
  },
  title: {
    color: 'white',
    textAlign: 'center'
  },
  message: {
    color: 'white',
    textAlign: 'center',
    marginTop: 5
  },
  buttonText: {
    color: 'blue',
    textAlign: 'center',
    fontSize: 16,
    padding: 20
  },
  iconContainer: {
    marginLeft: 30
  },
  verticalDivider: {
    width: 1,
    height: '100%',
    backgroundColor: 'gray',
    marginHorizontal: 10,
  },
});