import { useState, useEffect } from "react";
import { View, NativeModules } from "react-native";
import { Card, Text } from "react-native-paper";
import { styles } from "./styles";
import { Feather } from "@expo/vector-icons";
import { LineChart } from "react-native-gifted-charts"

export interface CardUsageTimeProps {
  sectionTitle: string;
  title?: string;
  averageTime?: string;
  percentageChange?: number;
};

export const CardUsageTime = (props: CardUsageTimeProps) => {

  const [data, setData] = useState([])
  const [dailyAverage, setDailyAverage] = useState(0)
  const { sectionTitle, title, percentageChange = 0 } = props;
  const { ChartModule } = NativeModules;

  const fetchChartData = async () => {
    try {
      const response = await ChartModule.fetchOpenAttemptsData()
      setData(response.data)
      setDailyAverage(response.dailyAverage)
    } catch (error) {
      console.log('Error fetching chart data', error)      
    }
  }

  useEffect(() => {
    fetchChartData()
  }, [])

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
                <Text style={styles.timeText}>{dailyAverage}</Text>
              </View>
              
            </View>
            <View style={{ flex: 1, justifyContent: 'center', flexDirection: 'row' }}>
              <View style={styles.percentageContainer}>
                <Text style={styles.percentageText}>{`${percentageChange}%`}</Text>
                <Feather name="arrow-up" size={10} color="#46BD84" />
              </View>
              <LineChart
                startFillColor={'#FFF9C4'}
                hideYAxisText
                initialSpacing={0}
                curved
                hideRules
                hideDataPoints 
                height={80}
                width={140}
                data={data} 
                spacing={140 / data.length}
                disableScroll
                color={'#FAE885'}
                areaChart
                xAxisLabelsHeight={0}
                maxValue={0}
                yAxisThickness={0}
                xAxisThickness={0}
              />
            </View>
          </View>
        </Card.Content>
      </Card>
    </View>
  )
};