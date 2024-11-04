import { View, Image } from "react-native";
import { Card, Text } from "react-native-paper";
import { styles } from "./styles";
import { Feather } from "@expo/vector-icons";

export interface CardUsageTimeProps {
  sectionTitle: string;
  title?: string;
  averageTime?: string;
  percentageChange?: number;
  chartData?: [];
};

export const CardUsageTime = (props: CardUsageTimeProps) => {

  const { sectionTitle, title, averageTime, percentageChange = 0 } = props;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{sectionTitle}</Text>
      <Card style={styles.card} mode="outlined">
        <Card.Content>
          <View style={styles.cardContentContainer}>
            <View style={styles.infoContainer}>
              <View style={styles.useTimeContainer}>
                <Text style={styles.useTimeText}>
                  {title}
                </Text>
                <Text style={styles.timeText}>{averageTime}</Text>
              </View>
              <View style={styles.percentageContainer}>
                <Text style={styles.percentageText}>{`${percentageChange}%`}</Text>
                <Feather name="arrow-up" size={10} color="#46BD84" />
              </View>
            </View>
            <View style={{ flex: 1, justifyContent: 'center' }}>
                <Image style={{ width: '100%', height: 50 }} source={require('@/assets/images/demo-chart.png')} resizeMode="contain" />
              </View>
            </View>
        </Card.Content>
      </Card>
    </View>
  )
};