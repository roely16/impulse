import { View } from "react-native";
import { Icon, Text } from "react-native-paper";
import { useTranslation } from "react-i18next";
import { styles } from "./styles";
import { widthPercentageToDP as wp } from "react-native-responsive-screen";
import SelectDropdown from 'react-native-select-dropdown'
import { Picker } from '@react-native-picker/picker';

interface ImpulseConfigProps {
  impulseDuration: string;
  onChangeDuration: (duration: string) => void;
  onChangeUsageWarning: (usageWarning: string) => void;
  usageWarning: string;
}

export const ImpulseConfig = (props: ImpulseConfigProps) => {

  const { impulseDuration, onChangeDuration, usageWarning, onChangeUsageWarning } = props;

  const { t } = useTranslation();

  const InputDuration = () => {
    
    const data = [
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

    return (
      <View style={{ gap: 5 }}>
        <Text style={styles.optionTitle}>{t('impulseConfigForm.impulseControlDuration.title')}</Text>
        <Text style={styles.optionMessage}>{t('impulseConfigForm.impulseControlDuration.message')}</Text>
        <View style={[styles.formOption, { paddingVertical: 0 }]}>
          <View style={styles.formOptionContent}>
            <View style={styles.labelOptionContainer}>
              <Text style={styles.label}>
                {t('impulseConfigForm.impulseControlDuration.buttonLabel')}
              </Text>
            </View>
            <View style={styles.selectOptionContainer}>
              <Picker 
                itemStyle={{ paddingHorizontal: 0, height: 120, width: 150 }}
                onValueChange={(itemValue: string) => onChangeDuration(itemValue)}
                selectedValue={impulseDuration}
              >
                {
                  updatedData.map((item, index) => {
                    return <Picker.Item label={item.label} value={item.value} key={index} />
                  })
                }
              </Picker>
              {/* <SelectDropdown
                data={updatedData}
                renderButton={(selectedItem) => {
                  return (
                    <View style={[styles.selectOptionContainer, { width: wp('35%'), justifyContent: 'flex-end' }]}>
                      <Text style={styles.selectLabel}>
                        {selectedItem ? selectedItem.label : t('impulseConfigForm.impulseControlDuration.buttonPlaceholder')}
                      </Text>
                      <Icon source="chevron-right" size={25} />
                    </View>
                  )
                }}
                renderItem={(item, _, isSelected) => {
                  return (
                    <View style={[styles.dropdownItemStyle, isSelected && { backgroundColor: '#D2D9DF' }]}>
                      { isSelected ? <Icon source="check" size={20} /> : <View style={{ paddingLeft: wp('5%') }}></View> }
                      <Text style={styles.dropDownText}>{item.label}</Text>
                    </View>
                  )
                }}
                onSelect={(selectedItem, index) => {
                  onChangeDuration(selectedItem.value);
                }}
                dropdownStyle={styles.dropdownMenuStyle}
                defaultValue={{ value: impulseDuration, label: `${impulseDuration} seg` }}
              /> */}
            </View>
          </View>
        </View>
      </View>
    )
  };

  const InputUsageWarning = () => {
    
    const data = [
      { label: '1', value: '1' },
      { label: '2', value: '2' },
      { label: '3', value: '3' },
      { label: '5', value: '5' },
      { label: '7', value: '7' },
      { label: '10', value: '10' },
      { label: '15', value: '15' },
      { label: '20', value: '20' },
      { label: '25', value: '25' },
      { label: '30', value: '30' },
      { label: '45', value: '45' },
      { label: '60', value: '60' },
      { label: '90', value: '90' },
      { label: '120', value: '120' }
    ];

    const updatedData = data.map(item => ({
      ...item,
      label: `${item.label} min`
    }));

    return (
      <View style={{ gap: 5 }}>
        <Text style={styles.optionTitle}>{t('impulseConfigForm.usageWarning.title')}</Text>
        <Text style={styles.optionMessage}>{t('impulseConfigForm.usageWarning.message')}</Text>
        <View style={[styles.formOption, { paddingVertical: 0 }]}>
          <View style={styles.formOptionContent}>
            <View style={styles.labelOptionContainer}>
              <Text style={styles.label}>{t('impulseConfigForm.usageWarning.buttonLabel')}</Text>
            </View>
            <View style={styles.selectOptionContainer}>
              <Picker 
                itemStyle={{ paddingHorizontal: 0, height: 120, width: 150 }}
                onValueChange={(itemValue: string) => onChangeUsageWarning(itemValue)}
                selectedValue={usageWarning}
              >
                {
                  updatedData.map((item, index) => {
                    return <Picker.Item label={item.label} value={item.value} key={index} />
                  })
                }
              </Picker>
              {/* <SelectDropdown
                data={updatedData}
                renderButton={(selectedItem) => {
                  return (
                    <View style={[styles.selectOptionContainer, { width: wp('35%'), justifyContent: 'flex-end' }]}>
                      <Text style={styles.selectLabel}>
                        {selectedItem ? selectedItem.label : t('impulseConfigForm.impulseControlDuration.buttonPlaceholder')}
                      </Text>
                      <Icon source="chevron-right" size={25} />
                    </View>
                  )
                }}
                renderItem={(item, _, isSelected) => {
                  return (
                    <View style={[styles.dropdownItemStyle, isSelected && { backgroundColor: '#D2D9DF' }]}>
                      { isSelected ? <Icon source="check" size={20} /> : <View style={{ paddingLeft: wp('5%') }}></View> }
                      <Text style={styles.dropDownText}>{item.label}</Text>
                    </View>
                  )
                }}
                onSelect={(selectedItem) => {
                  onChangeUsageWarning(selectedItem.value);
                }}
                dropdownStyle={styles.dropdownMenuStyle}
                defaultValue={{ value: usageWarning, label: `${usageWarning} min` }}
              /> */}
            </View>
          </View>
        </View>
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