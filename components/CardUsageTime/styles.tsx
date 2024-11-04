import { StyleSheet } from 'react-native';
import { SCREEN_HEIGHT } from "@/constants/Device";
import { RFValue } from "react-native-responsive-fontsize";
import { widthPercentageToDP as wp, heightPercentageToDP as hp } from "react-native-responsive-screen";

export const styles = StyleSheet.create({
  container: {
    gap: hp('1%')
  },
  card: {
    backgroundColor: 'white',
    borderWidth: 0.3,
    borderColor: "#C6D3DF",
    borderRadius: 10
  },
  title: {
    fontFamily: 'Catamaran',
    fontWeight: '700',
    fontSize: RFValue(19, SCREEN_HEIGHT),
    lineHeight: RFValue(24.7, SCREEN_HEIGHT)
  },
  cardContentContainer: {
    flexDirection: 'row',
    gap: 20
  },
  infoContainer: {
    flexDirection: 'row',
    gap: 10
  },
  useTimeContainer: {
    alignItems: 'center'
  },
  percentageContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  },
  useTimeText: {
    color: '#203B52',
    fontFamily: 'Catamaran',
    fontSize: 14,
    fontWeight: '500'
  },
  timeText: {
    color: '#222222',
    fontFamily: 'Mulish',
    fontSize: 17.5,
    fontWeight: '700'
  },
  percentageText: {
    fontSize: 10.5,
    fontWeight: '700',
    color: '#46BD84'
  }
});