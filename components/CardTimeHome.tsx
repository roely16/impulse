import { View, StyleSheet, Image } from "react-native";
import { Card, Text } from "react-native-paper";
import { Feather } from '@expo/vector-icons';
import { useTranslation } from "react-i18next";

export const CardTimeHome = () => {

  const { t } = useTranslation();

  return (
    <View style={styles.container}>
      <Card style={styles.card}>
        <Card.Content>
          <View style={styles.cardContentContainer}>
            <View style={styles.infoContainer}>
              <View style={styles.useTimeContainer}>
                <Text style={styles.useTimeText}>
                  {t('cardTime.title')}
                </Text>
                <Text style={styles.timeText}>2h 35min</Text>
              </View>
              <View style={styles.percentageContainer}>
                <Text style={styles.percentageText}>36%</Text>
                <Feather name="arrow-up" size={10} color="#46BD84" />
              </View>
            </View>
            <View style={{ flex: 1, justifyContent: 'center' }}>
              <Image style={{ width: '100%', height: 50 }} source={require('../assets/images/demo-chart.png')} resizeMode="contain" />
            </View>
          </View>
        </Card.Content>
      </Card>
    </View>
  )
};

const styles = StyleSheet.create({
  container: {
    padding: 20
  },
  card: {
    backgroundColor: 'white'
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
})