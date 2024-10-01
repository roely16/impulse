import { View, StyleSheet, Pressable } from "react-native";
import { Text, Icon } from "react-native-paper";

export const Blocks = () => {
  return (
    <View style={styles.container}>
      <View style={styles.headerContainer}>
        <Text style={styles.headerTitle}>Bloqueos</Text>
        <Pressable style={styles.addButton}>
          <Icon source="plus-circle-outline" size={15} />
          <Text>Añadir</Text>
        </Pressable>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: 20,
    paddingHorizontal: 20
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 700,
    lineHeight: 26
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 0.2,
    padding: 5,
    borderRadius: 10,
    gap: 5
  }
});