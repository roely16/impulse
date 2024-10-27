import { View, StyleSheet, TouchableOpacity } from "react-native";
import { Text, Icon } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";
import useTimeOnScreen from "@/hooks/useTimeOnScreen";
import { styles } from "./styles";

interface HeaderBlocksProps {
  showBottomShet: () => void;
  numberOfBlocks: number;
}

export const HeaderBlocks = (props: HeaderBlocksProps) => {
  const { showBottomShet, numberOfBlocks = 0 } = props;

  const { t } = useTranslation();
  const getTimeOnScreen = useTimeOnScreen();
  
  const handleAddButon = () => {
    showBottomShet();

    const timeSpent = getTimeOnScreen();
    MixpanelService.trackEvent('add_block_period_button_card', {
      localization: 'Home',
      type_button: 'add_block_period_button',
      time_spent_before_click: timeSpent,
      existing_block_periods: numberOfBlocks,
      device_type: 'iOS',
      timestamp: new Date().toISOString()
    });
  }

  return (
    <View style={styles.container}>
      <View style={styles.headerContainer}>
        <Text style={styles.headerTitle}>
          {t('blocksSection.title')}
        </Text>
          <TouchableOpacity onPress={handleAddButon} style={styles.addButton}>
            <View style={{flexDirection:'row', gap: 5}}>
              <Icon source="plus-circle-outline" size={15} />
              <Text style={styles.addLabel}>
                {t('blocksSection.addButton')}
              </Text>
            </View>
          </TouchableOpacity>
      </View>
    </View>
  );
};
