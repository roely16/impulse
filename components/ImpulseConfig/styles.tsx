import { StyleSheet } from "react-native";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { RFValue } from "react-native-responsive-fontsize";
import { widthPercentageToDP as wp, heightPercentageToDP as hp } from "react-native-responsive-screen";

export const styles = StyleSheet.create({
  container: {
    marginBottom: hp('3%'),
    marginTop: hp('2%'),
    gap: hp('1%')
  },
  title: {
    fontFamily: 'Catamaran',
    fontWeight: '700',
    fontSize: RFValue(20, SCREEN_HEIGHT),
    lineHeight: RFValue(26, SCREEN_HEIGHT),
    color: '#3A3A3C'
  },
  optionTitle: {
    fontFamily: 'Catamaran',
    fontWeight: '700',
    fontSize: RFValue(19, SCREEN_HEIGHT),
    lineHeight: RFValue(24.7, SCREEN_HEIGHT),
    color: '#3A3A3C',
    marginTop: hp('1%')
  },
  optionMessage: {
    fontFamily: 'Catamaran',
    fontWeight: '500',
    fontSize: RFValue(14, SCREEN_HEIGHT),
    lineHeight: RFValue(20, SCREEN_HEIGHT),
    color: '#203B52'
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
  label: {
    fontSize: RFValue(20, SCREEN_HEIGHT),
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  dropdownStyle: {
    // height: 34, 
    width: wp('40%'),
    paddingHorizontal: 8,
  },
  selectLabel: {
    color: 'rgba(0, 0, 0, 0.32)',
    fontSize: 20,
    fontWeight: '500',
    fontFamily: 'Catamaran',
    textAlign: 'right',
    marginRight: 5
  },
  dropDownText: {
    color: 'black',
    fontSize: 20,
    fontWeight: '500',
    fontFamily: 'Catamaran',
    textAlign: 'right',
    marginRight: 5,
    marginLeft: 5
  },
  dropdownButtonStyle: {
    width: 200,
    height: 50,
    backgroundColor: '#E9ECEF',
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 12,
  },
  dropdownMenuStyle: {
    backgroundColor: '#E9ECEF',
    borderRadius: 8,
  },
  dropdownItemStyle: {
    width: '100%',
    flexDirection: 'row',
    paddingHorizontal: 12,
    justifyContent: 'flex-start',
    alignItems: 'center',
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderColor: '#E9ECEF',
    paddingVertical: 5
  }
});