import { View, TouchableOpacity, Switch, NativeModules } from "react-native";
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
  sites: number;
  enable: boolean;
  weekdays: number[];
  refreshLimits: () => void;
  editLimit: (id: string) => void;
  total_active_limits?: number;
  total_inactive_limits?: number;
  total_limits?: number;
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
  const {
    id,
    title,
    timeLimit,
    openLimit,
    apps,
    sites,
    enable,
    refreshLimits,
    editLimit,
    weekdays = [],
    total_active_limits = 0,
    total_inactive_limits = 0,
    total_limits = 0
  } = props;

  const { LimitModule } = NativeModules;

  const { t } = useTranslation();

  const updateLimitStatus = async (status: boolean) => {
    try {
      await LimitModule.updateLimitStatus(id, status);

      MixpanelService.trackEvent('limit_app_activated', {
        localizacion: "home",
        total_block_periods: total_limits,
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
    MixpanelService.trackEvent('edit_limit_app', {
      previous_state: enable ? 'active' : 'disabled',
      localization: 'home',
      total_active_limits: total_active_limits,
      total_inactive_limits: total_inactive_limits,
      timestamp: new Date().toISOString()
    });
  }

  const openLimitText = () => {
    if (!openLimit) {
      return '';
    }
    return `• ${openLimit} ${t('cardLimit.maxOpenLabel')}`;
  }

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
            <Text style={styles.subtitle}>{t('cardBlock.editButton')}</Text>
          </TouchableOpacity>
        </View>
        <View style={{ flexDirection: 'row' }}>
          <Text style={styles.subtitle}>{`${timeLimit}${t(
            'cardLimit.timeLabel'
          )} ${openLimitText()}`}</Text>
        </View>
        <View style={styles.rowContainer}>
          <SitesAndWebsText />
          <Switch
            onValueChange={value => updateLimitStatus(value)}
            value={enable}
            thumbColor={enable ? '#203B52' : '#f4f3f4'}
            trackColor={{ false: '#767577', true: '#FDE047' }}
          />
        </View>
      </Card.Content>
    </Card>
  );
};
