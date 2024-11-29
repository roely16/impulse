import { View, StyleSheet, TouchableOpacity, Switch, NativeModules } from "react-native";
import { Card, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";

interface BlockCardProps {
  id: string;
  title: string;
  subtitle: string;
  apps: number;
  sites: number;
  enable: boolean;
  weekdays: number[];
  refreshBlocks: () => void;
  editBlock: (id: string) => void;
  total_active_limits?: number;
  total_inactive_limits?: number;
  total_blocks?: number;
}

export const BlockCard = (props: BlockCardProps) => {
  const {
    id,
    title,
    subtitle,
    apps,
    sites,
    enable,
    refreshBlocks,
    editBlock,
    weekdays = [],
    total_active_limits = 0,
    total_inactive_limits = 0,
    total_blocks = 0
  } = props;

  const { BlockModule } = NativeModules;

  const { t } = useTranslation();

  const updateBlockStatus = async (status: boolean) => {
    try {
      await BlockModule.updateBlockStatus(id, status);
      MixpanelService.trackEvent('block_period_activated', {
        localizacion: "home",
        total_block_periods: total_blocks,
        active_block_periods: total_active_limits,
        inactive_block_periods: total_inactive_limits,
        device_type: 'iOS',
        time_between_warning_and_deactivation: 0,
        timestamp: new Date().toISOString()
      });
      refreshBlocks();
    } catch (error) {
      console.log('error updating block status', error)
    }
  }

  const handleEditBlock = async () => {
    editBlock(id);
    MixpanelService.trackEvent('edit_block_periods', {
      previous_state: enable ? 'active' : 'disabled',
      localization: 'home',
      total_active_limits: total_active_limits,
      total_inactive_limits: total_inactive_limits,
      timestamp: new Date().toISOString()
    });
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

  const convertDaysToText = (selectedDays: number[]): string => {

    const WEEKDAYS = [
      { day: t('weekdaysLetters.monday'), value: 2, name: t('weekdays.monday'), selected: false, position: 1 },
      { day: t('weekdaysLetters.tuesday'), value: 3, name: t('weekdays.tuesday'), selected: false, position: 2 },
      { day: t('weekdaysLetters.wednesday'), value: 4, name: t('weekdays.wednesday'), selected: false, position: 3 },
      { day: t('weekdaysLetters.thursday'), value: 5, name: t('weekdays.thursday'), selected: false, position: 4 },
      { day: t('weekdaysLetters.friday'), value: 6, name: t('weekdays.friday'), selected: false, position: 5 },
      { day: t('weekdaysLetters.saturday'), value: 7, name: t('weekdays.saturday'), selected: false, position: 6 },
      { day: t('weekdaysLetters.sunday'), value: 1, name: t('weekdays.sunday'), selected: false, position: 7 }
    ];

    const values = selectedDays.sort((a, b) => a - b);
    const allValues = WEEKDAYS.map(day => day.value);

    if (allValues.every(val => values.includes(val))) {
      return t('everyDay');
    }

    const isConsecutive = values.every((val, idx) => idx === 0 || val === values[idx - 1] + 1);
    
    if (isConsecutive) {
      const firstDay = WEEKDAYS.find(day => day.value === values[0]);
      const lastDay = WEEKDAYS.find(day => day.value === values[values.length - 1]);
      if (firstDay && lastDay) {
        return `${firstDay.name} - ${lastDay.name}`;
      }
    }
    const days = values
    .map(val => WEEKDAYS.find(day => day.value === val))
    .filter(Boolean)
    .sort((a, b) => a!.position - b!.position)
    .map(day => day!.day);
    
    return days.join(', ');
  };

  const SitesAndWebsText = () => {
    const AppsText = apps > 0 ? `${t('cardBlock.appsLabel')}: ${apps}` : null;
    const SitesText = sites > 0 ? `${t('cardBlock.sitesLabel')}: ${sites}` : null;
    return (
      <Text style={styles.subtitle}>{AppsText} {SitesText}</Text>
    )
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
        <View style={{ flexDirection: 'row' }}>
          <Text style={styles.subtitle}>{convertDaysToText(weekdays)}</Text>
          { weekdays.length > 0 && <Text style={styles.subtitle}> • </Text> }
          <Text style={styles.subtitle}>{convertTimeRange(subtitle)}</Text>
        </View>
        <View style={styles.rowContainer}>
          <SitesAndWebsText />
          <Switch onValueChange={value => updateBlockStatus(value)} value={enable} thumbColor={enable ? '#203B52' : '#f4f3f4'} trackColor={{false: '#767577', true: '#FDE047'}} />
        </View>
      </Card.Content>
    </Card>
  )
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white',
    marginHorizontal: 20,
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
    color: '#3F5B74',
    fontFamily: 'Mulish'
  }
});