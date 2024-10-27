import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  container: {
    paddingBottom: 30
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    gap: 10
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    borderBottomWidth: 1,
    fontFamily: 'Catamaran'
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
  formOption: {
    backgroundColor: '#FDE047',
    padding: 18,
    borderRadius: 15
  },
  formOptionContent: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  labelOptionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10
  },
  selectOptionContainer: {
    flexDirection: 'row',
    alignItems: 'center' 
  },
  timeFormContainer: {
    marginVertical: 10,
    flexDirection: 'column',
    gap: 5
  },
  timeOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  label: {
    fontSize: 20,
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  timeLabel: {
    fontSize: 19,
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  selectLabel: {
    color: 'rgba(0, 0, 0, 0.32)',
    fontSize: 20,
    fontWeight: '500',
    fontFamily: 'Catamaran'
  },
  buttonLabel: {
    color: '#203B52',
    fontSize: 16,
    fontWeight: '600' 
  },
  daysContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 20
  },
  dayButton: {
    backgroundColor: '#F2F2F5',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 24,
    fontFamily: 'Mulish'
  },
  daySelected: {
    backgroundColor: '#3F5B74',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 24,
    fontFamily: 'Mulish'
  },
  deleteButton: {
    fontFamily: 'Catamaran',
    color: '#FF3B3B',
    fontSize: 18,
    textDecorationLine: 'underline',
    textAlign: 'center',
    marginTop: 20
  },
  dropdownStyle: {
    height: 34, 
    width: 150,
    borderColor: 'gray',
    borderWidth: 0.2,
    borderRadius: 8,
    paddingHorizontal: 8 
  }
});