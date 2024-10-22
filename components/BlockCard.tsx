import { View, StyleSheet, TouchableOpacity, Switch, NativeModules } from "react-native";
import { Card, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";

interface BlockCardProps {
  id: string;
  title: string;
  subtitle: string;
  apps: number;
  enable: boolean;
  refreshBlocks: () => void;
  editBlock: (id: string) => void;
}

export const BlockCard = (props: BlockCardProps) => {
  const { id, title, subtitle, apps, enable, refreshBlocks, editBlock } = props;

  const { ScreenTimeModule } = NativeModules;

  const { t } = useTranslation();

  const updateBlockStatus = async (status: boolean) => {
    try {
      const response = await ScreenTimeModule.updateBlockStatus(id, status);
      console.log('update block status response', response)
      refreshBlocks();
    } catch (error) {
      console.log('error updating block status', error)
    }
  }

  const handleEditBlock = async () => {
    editBlock(id);
  }

  const convertTo12HourFormat = (time: string): string | null => {
    const [hoursStr, minutesStr] = time.split(':');
    let hours = parseInt(hoursStr, 10);
    const minutes = parseInt(minutesStr, 10);
  
    if (isNaN(hours) || isNaN(minutes)) {
        return null;
    }

    const period = hours >= 12 ? 'PM' : 'AM';

    hours = hours % 12;
    hours = hours ? hours : 12;

    const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;

    return `${hours}:${formattedMinutes} ${period}`;
}

  const convertTimeRange = (input: string): string | null => {
    const times = input.split('-');
    if (times.length !== 2) {
        return null;
    }

    const formattedStartTime = convertTo12HourFormat(times[0]);
    const formattedEndTime = convertTo12HourFormat(times[1]);

    if (formattedStartTime && formattedEndTime) {
        return `${formattedStartTime} - ${formattedEndTime}`;
    }

    return null;
}

  return (
    <Card style={styles.card} mode="elevated" elevation={1}>
      <Card.Content style={styles.cardContent}>
        <View style={styles.rowContainer}>
          <Text style={styles.title}>{title}</Text>
          <TouchableOpacity onPress={handleEditBlock}>
            <Text style={styles.subtitle}>
              {t('cardBlock.editButton')}
            </Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.subtitle}>{convertTimeRange(subtitle)}</Text>
        <View style={styles.rowContainer}>
          <Text style={styles.subtitle}>{t('cardBlock.appsLabel')}: {apps}</Text>
          <Switch onValueChange={value => updateBlockStatus(value)} value={enable} thumbColor={enable ? '#203B52' : '#f4f3f4'} trackColor={{false: '#767577', true: '#FDE047'}} />
        </View>
      </Card.Content>
    </Card>
  )
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    marginBottom: 20
  },
  cardContent: {
    gap: 5
  },
  rowContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  title: {
    fontSize: 19,
    fontWeight: '700',
    color: '#3A3A3C',
    fontFamily: 'Catamaran'
  },
  subtitle: {
    fontSize: 12,
    fontWeight: '400',
    lineHeight: 20.4,
    color: '#C6D3DF',
    fontFamily: 'Mulish'
  }
});