import { TouchableOpacity, View } from "react-native";
import { Icon, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { styles } from "./styles";

export const ImpulseConfig = () => {

  const { t } = useTranslation();

  const InputDuration = () => {
    return (
      <View style={{ gap: 5 }}>
        <Text style={styles.optionTitle}>{t('impulseConfigForm.impulseControlDuration.title')}</Text>
        <Text style={styles.optionMessage}>{t('impulseConfigForm.impulseControlDuration.message')}</Text>
        <TouchableOpacity onPress={() => null} style={styles.formOption}>
          <View style={styles.formOptionContent}>
            <View style={styles.labelOptionContainer}>
              <Text style={styles.label}>
                {t('impulseConfigForm.impulseControlDuration.buttonLabel')}
              </Text>
            </View>
            <View style={styles.selectOptionContainer}>
              <Text>
                {t('impulseConfigForm.impulseControlDuration.buttonPlaceholder')}
              </Text>
              <Icon source="chevron-right" size={25} />
            </View>
          </View>
        </TouchableOpacity>
      </View>
    )
  };

  const InputUsageWarning = () => {
    return (
      <View style={{ gap: 5 }}>
        <Text style={styles.optionTitle}>{t('impulseConfigForm.usageWarning.title')}</Text>
        <Text style={styles.optionMessage}>{t('impulseConfigForm.usageWarning.message')}</Text>
        <TouchableOpacity onPress={() => null} style={styles.formOption}>
          <View style={styles.formOptionContent}>
            <View style={styles.labelOptionContainer}>
              <Text style={styles.label}>
                {t('impulseConfigForm.usageWarning.buttonLabel')}
              </Text>
            </View>
            <View style={styles.selectOptionContainer}>
              <Text>
                {t('impulseConfigForm.usageWarning.buttonPlaceholder')}
              </Text>
              <Icon source="chevron-right" size={25} />
            </View>
          </View>
        </TouchableOpacity>
      </View>
    )
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{t('impulseConfigForm.title')}</Text>
      <InputDuration />
      <InputUsageWarning />
    </View>
  )
};