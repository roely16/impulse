import { View, StyleSheet, SafeAreaView, ScrollView } from "react-native";
import { Text, Button } from "react-native-paper";
import { router, useLocalSearchParams } from 'expo-router';
import { useTranslation } from "react-i18next";

export default function SaveTime() {

  const { t } = useTranslation();
  const local = useLocalSearchParams();

  const redirectToHowMuchTimeScreen = () => {
    router.push('/impulse-functionalities')
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.contentContainer}>
        <View>
          <View>
            <Text style={{ fontFamily: 'Mulish', fontWeight: '700', fontSize: 22, lineHeight: 33, textAlign: 'center', marginBottom: 40 }}>
              {t('saveTimeScreen.firstText')}
            </Text>
          </View>
          <Text style={styles.title}>
            { local.days } {t('saveTimeScreen.days')}
          </Text>
          <Text style={styles.subtitle}>
            {t('saveTimeScreen.secondText')}
          </Text>
          <Text style={styles.subtitle}>
            {t('saveTimeScreen.thirdText')}
          </Text>
        </View>
        <View>
          <Text style={[styles.subtitle, { marginBottom: 40 }]}>
            {t('saveTimeScreen.fourthText')}
          </Text>
          <Text style={styles.title}>
            { local.years } {t('saveTimeScreen.years')}
          </Text>
          <Text style={[styles.subtitle, { fontWeight: '700', marginTop: 40 }]}>
            {t('saveTimeScreen.fifthText')}
          </Text>
        </View>
      </ScrollView>
      <View style={styles.buttonContainer}>
        <Button
          style={styles.button}
          labelStyle={{ color: 'black' }}
          buttonColor="#FDE047"
          mode="contained"
          onPress={redirectToHowMuchTimeScreen}
          contentStyle={{ flexDirection: 'row-reverse' }}
          icon="arrow-right"
        >
          {t('saveTimeScreen.startButton')}
        </Button>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  contentContainer: {
    paddingHorizontal: 55,
    paddingVertical: 40,
    gap: 50
  },
  title: {
    fontSize: 50,
    fontWeight: '700',
    lineHeight: 65,
    textAlign: 'center',
    fontFamily: 'Catamaran'
  },
  image: {
    alignSelf: 'center',
    marginTop: 20
  },
  subtitle: {
    fontSize: 22,
    fontWeight: '400',
    lineHeight: 33,
    textAlign: 'center',
    marginTop: 20,
    fontFamily: 'Mulish'
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 20,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 40
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
});
