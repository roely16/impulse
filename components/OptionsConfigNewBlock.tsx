import { View, StyleSheet, TouchableOpacity } from "react-native";
import { Text, Icon } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";
import useTimeOnScreen from "@/hooks/useTimeOnScreen";

interface OptionsConfigNewBlockProps {
  changeForm: (form: string) => void;
  totalBlocks?: number;
}

export const OptionsConfigNewBlock = (props: OptionsConfigNewBlockProps) => {

  const { t } = useTranslation();
  const { changeForm, totalBlocks = 0 } = props;
  const getTimeOnScreen = useTimeOnScreen();

  const handleNewBlock = () => {
    changeForm('new-block');
    const timeSpent = getTimeOnScreen();
    MixpanelService.trackEvent('add_block_period_modal', {
      localization: 'add_block_modal',
      type_button: 'add_block_period_button',
      time_spent_before_click: timeSpent,
      existing_block_periods: totalBlocks,
      device_type: 'iOS',
      timestamp: new Date().toISOString()
    });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>
        {t('optionsConfigNewBlock.title')}
      </Text>
      <View style={{ flexDirection: 'column', gap: 20, marginTop: 20 }}>
        <TouchableOpacity onPress={handleNewBlock} style={styles.button}>
          <View style={styles.contentButton}>
            <View style={styles.buttonLabelContainer}>
              <Icon source="timelapse" size={25} />
              <Text style={styles.buttonLabel}>
                {t('optionsConfigNewBlock.newBlock')}
              </Text>
            </View>
            <Icon source="chevron-right" size={25} />
          </View>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button}>
          <View style={styles.contentButton}>
            <View style={styles.buttonLabelContainer}>
              <Icon source="timer-sand" size={25} />
              <Text style={styles.buttonLabel}>
                {t('optionsConfigNewBlock.newLimit')}
              </Text>
            </View>
            <Icon source="chevron-right" size={25} />
          </View>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingBottom: 30
  },
  title: {
    fontSize: 22,
    fontWeight: 700,
    lineHeight: 28.6,
    fontFamily: 'Catamaran'
  },
  button: {
    backgroundColor: '#FDE047',
    padding: 24,
    borderRadius: 15
  },
  buttonLabel: {
    fontSize: 20,
    fontWeight: 700,
    fontFamily: 'Catamaran'
  },
  contentButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  buttonLabelContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10
  }
});