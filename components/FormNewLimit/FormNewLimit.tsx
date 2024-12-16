import { useState, useRef, useLayoutEffect, forwardRef, useImperativeHandle } from 'react';
import { View, TouchableOpacity, NativeModules, TextInput, Alert, Switch } from 'react-native';
import { Button, Icon, Text } from 'react-native-paper';
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import { useTranslation } from 'react-i18next';
import { MixpanelService } from '@/SDK/Mixpanel';
import useTimeOnScreen from '@/hooks/useTimeOnScreen';
import { format, toZonedTime } from 'date-fns-tz';
import { ImpulseConfig } from '../ImpulseConfig';
import { styles } from './styles';
import { widthPercentageToDP as wp } from 'react-native-responsive-screen';
import { Picker } from '@react-native-picker/picker';

interface FormNewLimitProps {
  changeForm: (form: string) => void;
  refreshLimits: () => void;
  closeBottomSheet: () => void;
  isEdit?: boolean;
  limitId?: string | null;
  isEmptyLimit?: boolean;
  updateEmptyLimit?: (isEmpty: boolean) => void;
  totalLimits?: number;
  enableImpulseConfig?: boolean;
}

interface DayType {
  day: string;
  value: number;
  name: string;
  selected: boolean;
}

export interface FormNewLimitRef {
  clearForm: () => void;
}

const data = [
  { label: 'No', value: '' },
  { label: '1', value: '1' },
  { label: '2', value: '2' },
  { label: '3', value: '3' },
  { label: '4', value: '4' },
  { label: '5', value: '5' },
  { label: '6', value: '6' },
  { label: '7', value: '7' },
  { label: '8', value: '8' },
  { label: '9', value: '9' },
  { label: '10', value: '10' }
];

export const FormNewLimit = forwardRef<FormNewLimitRef, FormNewLimitProps>((props, ref) => {
  const {
    refreshLimits,
    changeForm,
    closeBottomSheet,
    isEdit,
    limitId,
    isEmptyLimit,
    updateEmptyLimit,
    totalLimits = 0,
    enableImpulseConfig = false
  } = props;

  const [appsSelected, setAppsSelected] = useState(0);
  const [sitesSelected, setSitesSelected] = useState(0);
  const [limitTitle, setLimitTitle] = useState('');
  const currentTime = new Date();
  currentTime.setHours(0, 0, 0, 0);
  const startTimeRef = useRef(currentTime);
  const endTimeRef = useRef(new Date(new Date(currentTime.getTime() + 15 * 60000)));
  const [openLimit, setOpenLimit] = useState<string>('');
  const [impulseDuration, setImpulseDuration] = useState<string>('5');
  const [usageWarning, setUsageWarning] = useState<string>('5');
  const [enableTimeConfiguration, setEnableTimeConfiguration] = useState(true);

  const limitTimeRef = useRef(currentTime);
  const limitTimeString = useRef<string>('');
  const inputRef = useRef<TextInput>(null);
  const openLimitRef = useRef<string>('');
  const [isLoading, setIsLoading] = useState(false);
  const isSavingRef = useRef<boolean>(false);

  const { t } = useTranslation();
  const getTimeOnScreen = useTimeOnScreen();

  useImperativeHandle(ref, () => ({
    clearForm: () => {
      clearData();
    }
  }));

  const initialDays = [
    { day: t('weekdaysLetters.monday'), value: 2, name: t('weekdays.monday'), selected: false },
    { day: t('weekdaysLetters.tuesday'), value: 3, name: t('weekdays.tuesday'), selected: false },
    {
      day: t('weekdaysLetters.wednesday'),
      value: 4,
      name: t('weekdays.wednesday'),
      selected: false
    },
    { day: t('weekdaysLetters.thursday'), value: 5, name: t('weekdays.thursday'), selected: false },
    { day: t('weekdaysLetters.friday'), value: 6, name: t('weekdays.friday'), selected: false },
    { day: t('weekdaysLetters.saturday'), value: 7, name: t('weekdays.saturday'), selected: false },
    { day: t('weekdaysLetters.sunday'), value: 1, name: t('weekdays.sunday'), selected: false }
  ];

  const [days, setDays] = useState(initialDays);

  const { ScreenTimeModule, LimitModule } = NativeModules;

  const Frequency = (): React.ReactElement => {
    const toggleSelected = (selectedDay: DayType) => {
      const updatedDays = days.map(day =>
        day.value === selectedDay.value ? { ...day, selected: !day.selected } : day
      );
      const selectedDays = updatedDays.filter(day => day.selected).map(day => day.day);
      setDays(updatedDays);

      // TODO Update Mixpanel event
      const timeSpent = getTimeOnScreen();
      MixpanelService.trackEvent('block_frequency_selected', {
        type_block: 'limit_app',
        selected_days: selectedDays,
        number_of_days_selected: selectedDays.length,
        time_spent_on_frequency_selection: timeSpent,
        timestamp: new Date().toISOString()
      });
    };

    return (
      <View>
        <Text style={styles.timeLabel}>{t('formNewLimit.frequency')}</Text>
        <View style={styles.daysContainer}>
          {days.map((day, index) => (
            <TouchableOpacity
              onPress={() => toggleSelected(day)}
              key={day.value}
              style={day.selected ? styles.daySelected : styles.dayButton}>
              <Text style={{ color: day.selected ? 'white' : 'black' }}>{day.day}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>
    );
  };

  const onChangeLimitTime = (event: DateTimePickerEvent, selectedDate: Date | undefined) => {
    if (event.type === 'set') {
      const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;

      if (selectedDate === undefined) {
        return;
      }

      const guatemalaTime = toZonedTime(selectedDate, timeZone);

      const formatted = format(guatemalaTime, 'HH:mm', { timeZone });
      limitTimeString.current = formatted;
      limitTimeRef.current = selectedDate || limitTimeRef.current;

      const timeSpent = getTimeOnScreen();

      MixpanelService.trackEvent('limit_time_selected', {
        time_limit_added: true,
        type_block: 'limit_app',
        limit_time: limitTimeString.current,
        default_time_used: false,
        time_spent_on_time_selection: timeSpent,
        error_occurred: false,
        timestamp: new Date().toISOString()
      });
    }
  };

  const TimeConfigurationForm = (): React.ReactElement => {

    return (
      <View style={styles.timeFormContainer}>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
          <Text style={[styles.timeLabel, !enableTimeConfiguration && { color: 'gray' }]}>{t('formNewLimit.selectTime')}</Text>
          <Switch value={enableTimeConfiguration} onValueChange={setEnableTimeConfiguration}></Switch>
        </View>
        <View style={[styles.formOption, { paddingVertical: 0 }, !enableTimeConfiguration && styles.timeConfigurationDisable]}>
          <View style={styles.timeOption}>
            <Text style={[styles.label, !enableTimeConfiguration && { color: 'gray' }]}>{t('formNewLimit.selectTimeTitle')}</Text>
            {isLoading ? (
              <></>
            ) : (
              <DateTimePicker
                value={limitTimeRef.current}
                mode="countdown"
                onChange={onChangeLimitTime}
                display="spinner"
                style={{ height: 120, width: wp('60%') }}
                disabled={!enableTimeConfiguration}
              />
            )}
          </View>
        </View>
      </View>
    );
  };

  const OpenLimitPicker = () => {
    const handleOnChange = (value: string ) => {
      setOpenLimit(value);
      const timeSpent = getTimeOnScreen();
      MixpanelService.trackEvent('max_open_daily_selected', {
        type_block: 'limit_app',
        opening_limit_added: true,
        limit_openings: value,
        default_openings_used: false,
        time_spent_on_openings_selection: timeSpent,
        error_occurred: false,
        timeStamp: new Date().toISOString()
      });
    };

    return (
      <View style={styles.timeFormContainer}>
        <Text style={styles.timeLabel}>{t('formNewLimit.maxOpenDailyTitle')}</Text>
        <View style={[styles.formOption, { paddingVertical: 0 }]}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>{t('formNewLimit.maxOpenDaily')}</Text>
            <Picker 
              itemStyle={{ paddingHorizontal: 0, height: 120, width: 150 }}
              onValueChange={(itemValue: string) => handleOnChange(itemValue)}
              selectedValue={openLimit}
            >
              {
                data.map((item, index) => {
                  return <Picker.Item label={item.label} value={item.value} key={index} />
                })
              }
            </Picker>
          </View>
        </View>
      </View>
    );
  };

  const handleSelectApps = async () => {
    try {
      const buttonText = t('appPicker.saveButton');
      const titleText = t('appPicker.title');
      const result = await ScreenTimeModule.showAppPicker(
        isEmptyLimit,
        null,
        limitId,
        buttonText,
        titleText
      );
      if (result.status === 'success') {
        setAppsSelected(result.appsSelected);
        setSitesSelected(result.sitesSelected);
        updateEmptyLimit && updateEmptyLimit(false);

        const timeSpent = getTimeOnScreen();

        // TODO Update Mixpanel event
        MixpanelService.trackEvent('block_apps_selected', {
          type_block: 'block_period',
          apps_selected_count: result.appsSelected,
          time_spent_on_app_selection: timeSpent,
          timestamp: new Date().toISOString()
        });
      }
    } catch (error) {
      console.error(error);
    }
  };

  const emptySelected = appsSelected === 0 && sitesSelected === 0;

  const TextAppsSelected = (): React.ReactElement => {
    if (emptySelected) {
      return <Text style={styles.selectLabel}>{t('formNewLimit.appsPlaceholder')}</Text>;
    }
    const selectedItems = [];

    if (appsSelected > 0) {
      selectedItems.push(`${appsSelected} app${appsSelected > 1 ? 's' : ''}`);
    }

    if (sitesSelected > 0) {
      selectedItems.push(`${sitesSelected} ${t('formNewLimit.sitesLabel')}${sitesSelected > 1 ? 's' : ''}`);
    }

    return <Text style={styles.selectLabel}>{selectedItems.join(', ')}</Text>;
  };

  const handleSaveLimit = async () => {
    try {

      isSavingRef.current = true;
      const haveLimitTitle = limitTitle.length > 0;
      const newLimitTitle = haveLimitTitle
        ? limitTitle
        : `${t('formNewLimit.defaultBlockName')} #${totalLimits + 1}`;

      const weekDays = days
        .filter(day => day.selected)
        .map(day => day.value)
        .sort((a, b) => a - b);

      const impulseTime = parseInt(impulseDuration);
      const warningTime = parseInt(usageWarning);

      const data = {
        name: newLimitTitle,
        timeLimit: limitTimeString.current,
        appsSelected,
        weekDays,
        enableImpulseMode: enableImpulseConfig,
        impulseTime,
        warningTime
      };

      const response = await ScreenTimeModule.createLimit(
        data.name,
        data.timeLimit,
        openLimit,
        data.weekDays,
        data.enableImpulseMode,
        impulseTime,
        warningTime,
        enableTimeConfiguration
      );
      if (response.status === 'success') {
        refreshLimits();
        closeBottomSheet();
        changeForm('');
      }
      isSavingRef.current = false;
    } catch (error) {
      isSavingRef.current = false;
    }
  };

  const handleEditBlock = async () => {
    try {
      isSavingRef.current = true;
      const haveLimitTitle = limitTitle.length > 0;
      const newLimitTitle = haveLimitTitle
        ? limitTitle
        : `${t('formNewLimit.defaultBlockName')} #${totalLimits + 1}`;

      const weekDays = days
        .filter(day => day.selected)
        .map(day => day.value)
        .sort((a, b) => a - b);

      const data = {
        id: limitId,
        name: newLimitTitle,
        timeLimit: limitTimeString.current,
        appsSelected,
        weekDays
      };
      const impulseTime = parseInt(impulseDuration);
      const warningTime = parseInt(usageWarning);

      await ScreenTimeModule.updateLimit(
        data.id,
        data.name,
        data.timeLimit,
        openLimit,
        data.weekDays,
        !isEmptyLimit,
        impulseTime,
        warningTime,
        enableTimeConfiguration
      );
      refreshLimits();
      closeBottomSheet();
      changeForm('');
      isSavingRef.current = false;
    } catch (error) {
      isSavingRef.current = false;
    }
  };

  const daysSelected = days
    .filter(day => day.selected)
    .map(day => day.value)
    .sort((a, b) => a - b);

  const formFilled = !emptySelected && limitTimeRef && daysSelected.length > 0;

  const buttonBackground = formFilled ? '#FDE047' : '#C6D3DF';

  const DeleteButton = (): React.ReactElement => {
    const confirmDeleteLimit = async () => {
      try {
        await LimitModule.deleteLimit(limitId);
        refreshLimits();
        closeBottomSheet();
      } catch (error) {
        console.log('error deleting block', error);
      }
    };
    const handleDeleteLimit = async () => {
      try {
        Alert.alert(
          `${t('formNewLimit.deleteAlert.title')}`,
          `${t('formNewLimit.deleteAlert.message')}`,
          [
            {
              text: `${t('formNewLimit.deleteAlert.cancelButton')}`,
              style: 'cancel'
            },
            {
              text: `${t('formNewLimit.deleteAlert.confirmButton')}`,
              onPress: () => {
                confirmDeleteLimit();
              }
            }
          ]
        );
      } catch (error) {
        console.log(error);
      }
    };

    if (!isEdit) return <></>;
    return (
      <TouchableOpacity onPress={() => handleDeleteLimit()}>
        <Text style={styles.deleteButton}>{t('formNewLimit.deleteButton')}</Text>
      </TouchableOpacity>
    );
  };

  const setLimitData = limit => {
    setLimitTitle(limit.name);
    const [hours, minutes] = limit.timeLimit.split(':').map(Number);
    const date = new Date();
    date.setUTCHours(hours);
    date.setMinutes(minutes);
    date.setSeconds(0);
    date.setMilliseconds(0);

    const guatemalaTime = toZonedTime(date, 'Europe/Lisbon');

    limitTimeRef.current = new Date(guatemalaTime);
    setAppsSelected(limit.apps);
    setSitesSelected(limit.sites);
    setOpenLimit(limit.openTime);
    setEnableTimeConfiguration(limit.enableTimeConfiguration);
    limitTimeString.current = limit.timeLimit;
    const updatedDays = initialDays.map(day => {
      if (limit.weekdays.includes(day.value)) {
        return { ...day, selected: true };
      }
      return day;
    });
    setDays(updatedDays);

    setImpulseDuration(limit.impulseTime.toString());
    setUsageWarning(limit.usageWarning.toString());

  };

  const clearData = () => {
    setLimitTitle('');
    startTimeRef.current = currentTime;
    endTimeRef.current = new Date(currentTime.getTime() + 15 * 60000);
    setAppsSelected(0);
    setSitesSelected(0);
    setDays(initialDays);
    openLimitRef.current = '';
    setImpulseDuration('5');
    setUsageWarning('5');
  };

  const handleIconPress = () => {
    inputRef.current?.focus();
  };

  const handleCancel = () => {
    closeBottomSheet();
    const timeSpent = getTimeOnScreen();
    MixpanelService.trackEvent('limit_creation_cancelled', {
      step_before_cancellation: '',
      entry_point: isEdit ? 'edit_button' : 'add_button',
      total_time_spent: timeSpent,
      timestamp: new Date().toISOString()
    });
  };

  const handleSaveButton = () => {
    if (isEdit) {
      handleEditBlock();
    } else {
      handleSaveLimit();
    }

    const timeSpent = getTimeOnScreen();

    // TODO Update Mixpanel event
    MixpanelService.trackEvent('limit_period_saved', {
      apps_selected_count: appsSelected,
      number_of_days_selected: days.filter(day => day.selected).length,
      total_block_periods_after_save: totalLimits,
      total_time_spent: timeSpent,
      entry_point: isEdit ? 'edit_button' : 'add_button',
      error_occurred: false,
      timestamp: new Date().toISOString
    });
  };

  useLayoutEffect(() => {
    const localLimitData = async () => {
      setIsLoading(true);
      const result = await LimitModule.getLimitDetail(limitId);
      console.log('result', result);
      if (result.status === 'success') {
        setLimitData(result.limit);
      }
      setIsLoading(false);
    };
    if (isEdit) {
      localLimitData();
    } else {
      clearData();
    }
  }, [isEdit]);

  if (isLoading) {
    return <></>;
  }

  return (
    <View style={styles.container}>
      <View style={styles.titleContainer}>
        <TextInput
          ref={inputRef}
          value={limitTitle}
          onChangeText={setLimitTitle}
          style={styles.title}
          placeholderTextColor="black"
          placeholder={t('formNewLimit.blockName')}
          autoComplete='off'
          autoCorrect={false}
        />
        <TouchableOpacity onPress={handleIconPress}>
          <Icon source="pencil" size={25} />
        </TouchableOpacity>
      </View>
      <TouchableOpacity onPress={handleSelectApps} style={styles.formOption}>
        <View style={styles.formOptionContent}>
          <View style={styles.labelOptionContainer}>
            <Icon source="shield" size={25} />
            <Text style={styles.label}>{t('formNewLimit.appsOptions')}</Text>
          </View>
          <View style={styles.selectOptionContainer}>
            <TextAppsSelected />
            <Icon source="chevron-right" size={25} />
          </View>
        </View>
      </TouchableOpacity>
      <TimeConfigurationForm />
      <OpenLimitPicker />
      <Frequency />
      <ImpulseConfig
        impulseDuration={impulseDuration}
        onChangeDuration={setImpulseDuration}
        onChangeUsageWarning={setUsageWarning}
        usageWarning={usageWarning}
      />
      <View style={styles.buttonContainer}>
        <Button
          onPress={handleCancel}
          icon="close"
          labelStyle={styles.buttonLabel}
          contentStyle={{ flexDirection: 'row-reverse' }}
          style={[styles.button, { backgroundColor: '#C6D3DF' }]}
          mode="contained">
          {t('formNewLimit.cancelButton')}
        </Button>
        <Button
          loading={isSavingRef.current}
          disabled={!formFilled || isSavingRef.current}
          onPress={handleSaveButton}
          icon="check"
          labelStyle={styles.buttonLabel}
          contentStyle={{ flexDirection: 'row-reverse' }}
          style={[styles.button, { backgroundColor: buttonBackground }]}
          mode="contained">
          {t('formNewLimit.saveButton')}
        </Button>
      </View>
      <DeleteButton />
    </View>
  );
});
