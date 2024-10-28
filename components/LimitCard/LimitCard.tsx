import { View, StyleSheet, TouchableOpacity, Switch, NativeModules } from "react-native";
import { Card, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";
import { styles } from "./styles";

interface LimitCardProps {
  id: string;
  title: string;
  timeLimit: string;
  openLimit: string;
  apps: number;
  enable: boolean;
  weekdays: number[];
  refreshLimits: () => void;
  editLimit: (id: string) => void;
  total_active_limits?: number;
  total_inactive_limits?: number;
  total_blocks?: number;
}

export interface LimitType {
  id: string;
  title: string;
  timeLimit: string;
  openLimit: string;
  apps: number;
  enable: boolean;
  weekdays: number[];
}

export const LimitCard = (props: LimitCardProps) => {
  const { id, title, timeLimit, openLimit, apps, enable, refreshLimits, editLimit , weekdays = [], total_active_limits = 0, total_inactive_limits = 0, total_blocks = 0} = props;

  const { ScreenTimeModule } = NativeModules;

  const { t } = useTranslation();

  const updateLimitStatus = async (status: boolean) => {
    try {
      const response = await ScreenTimeModule.updateLimitStatus(id, status);
      console.log('response', response);
      // TODO: Update Mixpanel event
      MixpanelService.trackEvent('block_period_activated', {
        localizacion: "home",
        total_block_periods: total_blocks,
        active_block_periods: total_active_limits,
        inactive_block_periods: total_inactive_limits,
        device_type: 'iOS',
        time_between_warning_and_deactivation: 0,
        timestamp: new Date().toISOString()
      });
      refreshLimits();
    } catch (error) {
      console.log('error updating block status', error)
    }
  }

  const handleEditBlock = async () => {
    editLimit(id);
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
          <Text style={styles.subtitle}>{`${timeLimit}${t('cardLimit.timeLabel')} • ${openLimit} ${t('cardLimit.maxOpenLabel')}`}</Text>
        </View>
        <View style={styles.rowContainer}>
          <Text style={styles.subtitle}>{t('cardBlock.appsLabel')}: {apps}</Text>
          <Switch onValueChange={value => updateLimitStatus(value)} value={enable} thumbColor={enable ? '#203B52' : '#f4f3f4'} trackColor={{false: '#767577', true: '#FDE047'}} />
        </View>
      </Card.Content>
    </Card>
  )
};
