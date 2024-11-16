import { SafeAreaView, ScrollView, StyleSheet, View } from "react-native"
import { Button } from "react-native-paper";
import { heightPercentageToDP as hp, widthPercentageToDP as wp } from "react-native-responsive-screen";

interface OnboardingContainerProps {
  children: React.ReactNode;
  onPress: () => void;
  buttonLabel: string;
  scrollEnabled?: boolean;
  isLoading?: boolean;
}  

export const OnboardingContainer = (props: OnboardingContainerProps) => {

  const { children, onPress, buttonLabel, scrollEnabled = true, isLoading = false } = props;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView scrollEnabled={scrollEnabled} style={styles.contentContainer}>
        {children}
      </ScrollView>
      <View style={styles.buttonContainer}>
          <Button
            style={styles.button}
            labelStyle={{ color: 'black' }}
            buttonColor="#FDE047"
            mode="contained"
            onPress={onPress}
            contentStyle={{ flexDirection: 'row-reverse' }}
            icon="arrow-right"
            loading={isLoading}
            disabled={isLoading}
          >
            {buttonLabel}
          </Button>
        </View>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  contentContainer: {
    paddingHorizontal: wp('6%'),
    paddingVertical: hp('4%')
  },
  buttonContainer: {
    position: 'absolute',
    bottom: hp('4%'),
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: hp('3%')
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  }
});