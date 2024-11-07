import { StyleSheet } from "react-native";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { RFValue } from "react-native-responsive-fontsize";
import { widthPercentageToDP as wp, heightPercentageToDP as hp } from "react-native-responsive-screen";

export const styles = StyleSheet.create({
  container: {
    paddingBottom: hp('3%')
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: hp('3%'),
    gap: hp('2%')
  },
  title: {
    fontSize: RFValue(22, SCREEN_HEIGHT),
    fontWeight: '700',
    borderBottomWidth: 1,
    fontFamily: 'Catamaran'
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  button: {
    paddingHorizontal: hp('2%'),
    paddingVertical: hp('1%'),
    borderRadius: 6
  },
  formOption: {
    backgroundColor: '#FDE047',
    padding: hp('2%'),
    borderRadius: 15
  },
  formOptionContent: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  labelOptionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: hp('1%')
  },
  selectOptionContainer: {
    flexDirection: 'row',
    alignItems: 'center' 
  },
  timeFormContainer: {
    marginBottom: hp('1%'),
    marginTop: hp('2%'),
    flexDirection: 'column',
    gap: 5
  },
  timeOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  label: {
    fontSize: RFValue(20, SCREEN_HEIGHT),
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  timeLabel: {
    fontSize: RFValue(19, SCREEN_HEIGHT),
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  selectLabel: {
    color: 'rgba(0, 0, 0, 0.32)',
    fontSize: RFValue(20, SCREEN_HEIGHT),
    fontWeight: '500',
    fontFamily: 'Catamaran',
    textAlign: 'right',
    marginRight: 5
  },
  buttonLabel: {
    color: '#203B52',
    fontSize: RFValue(16, SCREEN_HEIGHT),
    fontWeight: '600' 
  },
  daysContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: hp('2%'),
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
    fontSize: RFValue(18, SCREEN_HEIGHT),
    textDecorationLine: 'underline',
    textAlign: 'center',
    marginTop: 20
  },
  dropdownStyle: {
    height: 34, 
    width: wp('40%'),
    paddingHorizontal: 8
  }
});