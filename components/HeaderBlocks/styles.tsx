import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  container: {
    marginTop: 20,
    paddingHorizontal: 20,
    marginBottom: 10
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 700,
    fontFamily: 'Catamaran'
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 0.2,
    padding: 5,
    borderRadius: 30,
    paddingHorizontal: 10,
    gap: 5
  },
  addLabel: {
    fontFamily: 'Mulish',
    fontWeight: '500',
    fontSize: 12
  }
});