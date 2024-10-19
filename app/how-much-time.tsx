import { router } from "expo-router";
import { useState } from "react";
import { SafeAreaView, ScrollView, StyleSheet, View } from "react-native";
import { Button, IconButton, Text } from "react-native-paper";
import { PanResponder } from "react-native";

const DAYS_IN_A_YEAR = 365;
const HOURS_IN_A_DAY = 24;
const YEAR_IN_A_LIFE = 70;

export default function HowMuchTime() {

  const [hours, setHours] = useState(3);

  const Hours = () => {
    return <Text style={styles.hourLetter}><Text style={styles.hourNumber}>{hours}</Text> h</Text>
  };

  const ProgressBar = () => {

    const panResponder = PanResponder.create({
      onMoveShouldSetPanResponder: (evt, gestureState) => true,
      onPanResponderMove: (evt, gestureState) => {
        // Detecta si el usuario desliza hacia arriba o hacia abajo
        if (gestureState.dy < -10) {
          updateHours('increase');
        } else if (gestureState.dy > 10) {
          updateHours('decrease');
        }
      },
    });

    const getPercentage = () => {
      const barHeight = 100 - (hours * 100) / 10;

      return { height: `${barHeight}%` };
    }

    const barHeight = getPercentage();

    const zeroBorderRadius = hours === 0 ? { borderBottomLeftRadius: 6, borderBottomRightRadius: 6 } : {};
    return (
      <View style={styles.progressBarContainer} {...panResponder.panHandlers}>
        <View style={[styles.progressBar, barHeight, zeroBorderRadius]}></View>
      </View>
    )
  };

  const updateHours = (type: string) => {
    if (type === 'increase' && hours < 10) {
      setHours(hours + 1);
    } else if (type === 'decrease' && hours >= 1) {
      setHours(hours - 1);
    }
  }

  const UpdateBarButtons = () => {
    return (
      <View style={styles.updateButtonsContainer}>
        <IconButton onPress={() => updateHours('increase')} icon="arrow-up" />
        <IconButton onPress={() => updateHours('decrease')} icon="arrow-down" />
      </View>
    )
  };

  const redirect = () => {
    const days = Math.round((hours * DAYS_IN_A_YEAR) / HOURS_IN_A_DAY);
    const years = Math.round((hours * DAYS_IN_A_YEAR * YEAR_IN_A_LIFE) / (HOURS_IN_A_DAY * DAYS_IN_A_YEAR));
    router.push({ pathname: '/save-time-screen', params: { days, years } });
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.contentContainer}>
        <Text style={styles.title}>
          ¿Cuanto tiempo usas el móvil al día?
        </Text>
        <Hours />
        <View style={styles.progressBarWrapper}>
          <ProgressBar />
          <UpdateBarButtons />
        </View>
      </View>
      <View style={styles.buttonContainer}>
        <Button
          style={styles.button}
          labelStyle={{ color: 'black' }}
          buttonColor="#FDE047"
          mode="contained"
          contentStyle={{ flexDirection: 'row-reverse' }}
          icon="arrow-right"
          onPress={redirect}
        >
          Continuar
        </Button>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  contentContainer: {
    paddingHorizontal: 20,
    paddingVertical: 40,
    flexDirection: 'column',
    gap: 50,
    justifyContent: 'center',
    alignItems: 'center'
  },
  title: {
    fontSize: 36,
    fontWeight: '700',
    lineHeight: 46.8,
    textAlign: 'center',
    fontFamily: 'Catamaran'
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
  hourLetter: {
    fontSize: 40,
    fontWeight: '400',
    lineHeight: 52,
    fontFamily: 'Catamaran'
  },
  hourNumber: {
    fontSize: 50,
    fontWeight: '700',
    lineHeight: 65,
    fontFamily: 'Catamaran'
  },
  progressBarWrapper: {
    width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative'
  },
  progressBarContainer: {
    borderWidth: 1,
    width: 100,
    height: 300,
    backgroundColor: '#FDE047',
    borderRadius: 6
  },
  progressBar: {
    backgroundColor: 'white',
    width: '100%',
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
  },
  updateButtonsContainer: {
    position: 'absolute',
    right: 50,
    justifyContent: 'center',
    alignItems: 'center'
  }
});
