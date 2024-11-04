import { StyleSheet } from 'react-native';
import { SCREEN_HEIGHT } from "@/constants/Device";
import { RFValue } from "react-native-responsive-fontsize";
import { widthPercentageToDP as wp } from "react-native-responsive-screen";

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  messageContainer: {
    paddingHorizontal: wp('6%'),
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center'
  },
  title: {
    fontFamily: 'Catamaran',
    fontWeight: '700',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    lineHeight: RFValue(28.6, SCREEN_HEIGHT)
  },
  message: {
    fontFamily: 'Mulish',
    fontWeight: '400',
    fontSize: RFValue(14, SCREEN_HEIGHT),
    lineHeight: RFValue(21, SCREEN_HEIGHT),
    textAlign: 'center'
  },
  messageBold: {
    fontFamily: 'Mulish',
    fontWeight: '700',
    fontSize: RFValue(14, SCREEN_HEIGHT),
    lineHeight: RFValue(21, SCREEN_HEIGHT),
    textAlign: 'center'
  }
});