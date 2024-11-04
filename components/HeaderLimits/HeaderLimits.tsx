import { View, StyleSheet, TouchableOpacity } from "react-native";
import { Text, Icon } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";
import useTimeOnScreen from "@/hooks/useTimeOnScreen";
import { styles } from "./styles";

interface HeaderLimitsProps {
  showBottomShet: () => void;
  numberOfLimits: number;
}

export const HeaderLimits = (props: HeaderLimitsProps) => {
  const { showBottomShet, numberOfLimits = 0 } = props;

  const { t } = useTranslation();
  const getTimeOnScreen = useTimeOnScreen();
  
  const handleAddButon = () => {
    showBottomShet();

    const timeSpent = getTimeOnScreen();

    MixpanelService.trackEvent('add_limit_app_button_card', {
      localization: 'impulse_page',
      type_button: 'add_limit_app_button',
      time_spent_before_click: timeSpent,
      existing_block_periods: numberOfLimits,
      device_type: 'iOS',
      timestamp: new Date().toISOString()
    });
  }

  return (
    <View style={styles.container}>
      <View style={styles.headerContainer}>
        <Text style={styles.headerTitle}>
          {t('limitsSection.title')}
        </Text>
          <TouchableOpacity onPress={handleAddButon} style={styles.addButton}>
            <View style={{flexDirection:'row', gap: 5}}>
              <Icon source="plus-circle-outline" size={15} />
              <Text style={styles.addLabel}>
                {t('limitsSection.addButton')}
              </Text>
            </View>
          </TouchableOpacity>
      </View>
    </View>
  );
};
