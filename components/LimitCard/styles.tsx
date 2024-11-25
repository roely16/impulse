import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    marginHorizontal: 20,
    marginBottom: 20
  },
  cardContent: {
    gap: 5
  },
  rowContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  title: {
    fontSize: 19,
    fontWeight: '700',
    color: '#3A3A3C',
    fontFamily: 'Catamaran'
  },
  subtitle: {
    fontSize: 12,
    fontWeight: '400',
    lineHeight: 20.4,
    color: '#3F5B74',
    fontFamily: 'Mulish'
  }
});