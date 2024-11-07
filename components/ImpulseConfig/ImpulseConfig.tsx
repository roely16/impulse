import { Switch, TouchableOpacity, View } from "react-native";
import { Icon, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { Dropdown } from 'react-native-element-dropdown';
import { styles } from "./styles";
import { useState } from "react";
import { heightPercentageToDP as hp } from "react-native-responsive-screen";

interface ImpulseConfigProps {
  impulseDuration: string;
  onChangeDuration: (duration: string) => void;
  onChangeUsageWarning: (usageWarning: boolean) => void;
  usageWarning: boolean;
}

export const ImpulseConfig = (props: ImpulseConfigProps) => {

  const { impulseDuration, onChangeDuration, usageWarning, onChangeUsageWarning } = props;

  const { t } = useTranslation();

  const InputDuration = () => {
    
    const data = [
      { label: '0', value: '0' },
      { label: '5', value: '5' },
      { label: '10', value: '10' },
      { label: '15', value: '15' },
      { label: '20', value: '20' },
      { label: '25', value: '25' },
      { label: '35', value: '35' },
      { label: '45', value: '45' },
      { label: '60', value: '60' },
    ];

    const updatedData = data.map(item => ({
      ...item,
      label: `${item.label} seg`
    }));

    const handleSetDuration = (item: {value: string}) => {
      onChangeDuration(item.value);
    };

    return (
      <View style={{ gap: 5 }}>
        <Text style={styles.optionTitle}>{t('impulseConfigForm.impulseControlDuration.title')}</Text>
        <Text style={styles.optionMessage}>{t('impulseConfigForm.impulseControlDuration.message')}</Text>
        <View style={styles.formOption}>
          <View style={styles.formOptionContent}>
            <View style={styles.labelOptionContainer}>
              <Text style={styles.label}>
                {t('impulseConfigForm.impulseControlDuration.buttonLabel')}
              </Text>
            </View>
            <View style={styles.selectOptionContainer}>
              <Dropdown 
                renderRightIcon={() => <Icon source="chevron-right" 
                size={25} />} 
                placeholder={t('impulseConfigForm.impulseControlDuration.buttonPlaceholder')} 
                data={updatedData} 
                labelField="label" 
                valueField="value" 
                onChange={handleSetDuration}
                style={styles.dropdownStyle}
                placeholderStyle={styles.selectLabel}
                selectedTextStyle={styles.selectLabel}
                maxHeight={hp('30%')}
                value={impulseDuration}
              />
            </View>
          </View>
        </View>
      </View>
    )
  };

  const InputUsageWarning = () => {
    
    const handleSetUsageWarning = (value: boolean) => {
      onChangeUsageWarning(value);
    };

    return (
      <View style={{ gap: 5 }}>
        <Text style={styles.optionTitle}>{t('impulseConfigForm.usageWarning.title')}</Text>
        <Text style={styles.optionMessage}>{t('impulseConfigForm.usageWarning.message')}</Text>
        <TouchableOpacity onPress={() => null} style={styles.formOption}>
          <View style={styles.formOptionContent}>
            <View style={styles.labelOptionContainer}>
              <Text style={styles.label}>{t('impulseConfigForm.usageWarning.buttonLabel')}</Text>
            </View>
            <View style={styles.selectOptionContainer}>
              <Switch
                onValueChange={handleSetUsageWarning}
                value={usageWarning}
                thumbColor={usageWarning ? '#203B52' : '#f4f3f4'}
                trackColor={{ false: '#767577', true: '#8F90A6' }}
              />
            </View>
          </View>
        </TouchableOpacity>
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{t('impulseConfigForm.title')}</Text>
      <InputDuration />
      <InputUsageWarning />
    </View>
  )
};