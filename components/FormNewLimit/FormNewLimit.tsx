import { useState, useRef, useLayoutEffect } from "react";
import { View, StyleSheet, TouchableOpacity, NativeModules, TextInput, Alert } from "react-native";
import { Button, Icon, Text } from "react-native-paper";
import { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import { useTranslation } from "react-i18next";
import { MixpanelService } from "@/SDK/Mixpanel";
import useTimeOnScreen from "@/hooks/useTimeOnScreen";
import { Dropdown } from 'react-native-element-dropdown';
import { styles } from "./styles";

interface FormNewLimitProps {
  changeForm: (form: string) => void;
  refreshBlocks: () => void;
  closeBottomSheet: () => void;
  isEdit?: boolean;
  blockId?: string | null;
  isEmptyBlock?: boolean;
  updateEmptyBlock?: (isEmpty: boolean) => void;
  totalBlocks?: number;
}

interface DayType {
  day: string;
  value: number;
  name: string;
  selected: boolean;
}

const data = [
  { label: '1', value: '1' },
  { label: '2', value: '2' },
  { label: '3', value: '3' },
  { label: '4', value: '4' },
  { label: '5', value: '5' },
  { label: '6', value: '6' },
  { label: '7', value: '7' },
  { label: '8', value: '8' },
  { label: '9', value: '9' },
  { label: '10', value: '10' },
];

export const FormNewLimit = (props: FormNewLimitProps) => {

  const { refreshBlocks, changeForm, closeBottomSheet, isEdit, blockId, isEmptyBlock, updateEmptyBlock, totalBlocks = 0 } = props;
  const [appsSelected, setAppsSelected] = useState(0);
  const [sitesSelected, setSitesSelected] = useState(0);
  const [blockTitle, setBlockTitle] = useState('');
  const currentTime = new Date();
  const startTimeRef = useRef(currentTime);
  const endTimeRef = useRef(new Date(new Date(currentTime.getTime() + 15 * 60000)));
  const inputRef = useRef<TextInput>(null);
  const [timeLimit, setTimeLimit] = useState<string>('');
  const [openLimit, setOpenLimit] = useState<string>('');

  const { t } = useTranslation();
  const getTimeOnScreen = useTimeOnScreen();

  const initialDays = [
    { day: t('weekdaysLetters.monday'), value: 2, name: t('weekdays.monday'), selected: false },
    { day: t('weekdaysLetters.tuesday'), value: 3, name: t('weekdays.tuesday'), selected: false },
    { day: t('weekdaysLetters.wednesday'), value: 4, name: t('weekdays.wednesday'), selected: false },
    { day: t('weekdaysLetters.thursday'), value: 5, name: t('weekdays.thursday'), selected: false },
    { day: t('weekdaysLetters.friday'), value: 6, name: t('weekdays.friday'), selected: false },
    { day: t('weekdaysLetters.saturday'), value: 7, name: t('weekdays.saturday'), selected: false },
    { day: t('weekdaysLetters.sunday'), value: 1, name: t('weekdays.sunday'), selected: false },
  ];

  const [days, setDays] = useState(initialDays);

  const { ScreenTimeModule } = NativeModules;

  const readLastLog = async () => {
    try {
      const response = await ScreenTimeModule.readLastLog();
      console.log('response last log', response);
    } catch (error) {
      console.error(error);
    }
  }

  const Frequency = (): React.ReactElement => {

    const toggleSelected = (selectedDay: DayType) => {
      const updatedDays = days.map((day) =>
        day.value === selectedDay.value ? { ...day, selected: !day.selected } : day
      );
      const selectedDays = updatedDays.filter(day => day.selected).map(day => day.day);
      setDays(updatedDays);

      const timeSpent = getTimeOnScreen();
      MixpanelService.trackEvent('block_frequency_selected', {
        type_block: 'block_period',
        selected_days: selectedDays,
        number_of_days_selected: selectedDays.length,
        time_spent_on_frequency_selection: timeSpent,
        timestamp: new Date().toISOString()
      });
    };

    return (
      <View>
        <Text style={styles.timeLabel}>
          {t('formNewLimit.frequency')}
        </Text>
        <View style={styles.daysContainer}>
          {
            days.map((day, index) => (
              <TouchableOpacity onPress={() => toggleSelected(day)} key={day.value} style={day.selected ? styles.daySelected : styles.dayButton}>
                <Text style={{ color: day.selected ? 'white' : 'black' }}>{day.day}</Text>
              </TouchableOpacity>
            ))
          }
        </View>
      </View>
    )
  };

  const convertDate = (date: Date | undefined): string => {
    if (!date) return '';
    const hours = date.getHours();
    const minutes = date.getMinutes();
    return `${hours}:${minutes}`;
  }

  const onChange = (event: DateTimePickerEvent, selectedDate: Date | undefined) => {
    if (event.type === 'set') {
      startTimeRef.current = selectedDate || startTimeRef.current;
    }
  };

  const onChangeTo = (event: DateTimePickerEvent, selectedDate: Date | undefined) => {
    if (event.type === 'set') {
      endTimeRef.current = selectedDate || endTimeRef.current;
    }
  }

  const TimeConfigurationForm = (): React.ReactElement => {
    return (
      <View style={styles.timeFormContainer}>
        <Text style={styles.timeLabel}>
          {t('formNewLimit.selectTime')}
        </Text>
        <View style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>
              {t('formNewLimit.selectTimeTitle')}
            </Text>
            <Dropdown value={timeLimit} style={styles.dropdownStyle} placeholder={t('formNewLimit.selectTimeLabel')} data={data} labelField="label" valueField="value" onChange={item => setTimeLimit(item.value)} />
          </View>
        </View>
      </View>
    )
  };

  const OpenLimitPicker = () => {
    return (
      <View style={styles.timeFormContainer}>
        <Text style={styles.timeLabel}>
          {t('formNewLimit.maxOpenDailyTitle')}
        </Text>
        <View style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>
              {t('formNewLimit.selectTimeTitle')}
            </Text>
            <Dropdown value={openLimit} style={styles.dropdownStyle} placeholder={t('formNewLimit.selectTimeLabel')} data={data} labelField="label" valueField="value" onChange={item => setOpenLimit(item.value)} />
          </View>
        </View>
      </View>
    )
  };

  const handleSelectApps = async () => {
    try {
      const result = await ScreenTimeModule.showAppPicker(isEmptyBlock, blockId);
      if (result.status === 'success') {
        setAppsSelected(result.appsSelected);
        setSitesSelected(result.sitesSelected);
        updateEmptyBlock && updateEmptyBlock(false);

        const timeSpent = getTimeOnScreen();
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
      return (
        <Text style={styles.selectLabel}>
          {t('formNewLimit.appsPlaceholder')}
        </Text>
      )
    }
    const selectedItems = [];

    if (appsSelected > 0) {
      selectedItems.push(`${appsSelected} apps`);
    }

    return (
      <Text style={styles.selectLabel}>{selectedItems.join(', ')}</Text>
    )
  };

  const handleSaveLimit = async () => {
    try {
      const haveBlockTitle = blockTitle.length > 0;
      const newBlockTitle = haveBlockTitle ? blockTitle : `${t('formNewLimit.defaultBlockName')} #${totalBlocks + 1}`;

      const weekDays = days.filter((day) => day.selected).map((day) => day.value).sort((a, b) => a - b);
      const data = {
        name: newBlockTitle,
        timeLimit,
        openLimit,
        appsSelected,
        weekDays
      }
      console.log('data', data);
      const response = await ScreenTimeModule.createLimit(data.name, data.timeLimit, data.openLimit, data.weekDays);
      console.log('response', response);
      // refreshBlocks();
      // closeBottomSheet()
      // changeForm('')
    } catch (error) {
      console.log('error', error);
    }
  };

  const handleEditBlock = async () => {
    try {
      const startTime = convertDate(startTimeRef.current);
      const endTime = convertDate(endTimeRef.current);
      const haveBlockTitle = blockTitle.length > 0;
      const newBlockTitle = haveBlockTitle ? blockTitle : `${t('formNewLimit.defaultBlockName')} #${totalBlocks + 1}`;

      const weekDays = days.filter((day) => day.selected).map((day) => day.value).sort((a, b) => a - b);

      const data = {
        id: blockId,
        name: newBlockTitle,
        startTime,
        endTime,
        appsSelected,
        weekDays
      }

      const response = await ScreenTimeModule.updateBlock(data.id, data.name, data.startTime, data.endTime, data.weekDays, !isEmptyBlock);
      refreshBlocks();
      closeBottomSheet()
      changeForm('')
    } catch (error) {
      
    }
  };

  const formFilled = !emptySelected && timeLimit && openLimit;

  const buttonBackground = formFilled ? '#FDE047' : '#C6D3DF';

  const DeleteButton = (): React.ReactElement => {

    const confirmDeleteBlock = async () => {
      try {
        await ScreenTimeModule.deleteBlock(blockId);
        refreshBlocks();
        closeBottomSheet()
      } catch (error) {
        console.log('error deleting block', error)  
      }
    }
    const handleDeleteBlock = async () => {
      try {
        Alert.alert(
          `${t('formNewLimit.deleteAlert.title')}`,
          `${t('formNewLimit.deleteAlert.message')}`,
          [
            {
              text: `${t('formNewLimit.deleteAlert.cancelButton')}`,
              style: "cancel"
            },
            {
              text: `${t('formNewLimit.deleteAlert.confirmButton')}`,
              onPress: () => {
                confirmDeleteBlock();
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
      <TouchableOpacity onPress={handleDeleteBlock}>
        <Text style={styles.deleteButton}>
          {t('formNewLimit.deleteButton')}
        </Text>
      </TouchableOpacity>
    )
  };

  function timeStringToDate(timeString) {
    const [hours, minutes] = timeString.split(':').map(Number);
    
    // Crea un objeto Date con la fecha actual
    const now = new Date();
    
    // Establece las horas y minutos
    const date = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hours, minutes);
    
    return date;
  }
  const setBlockData = (block) => {
    setBlockTitle(block.name);
    const startTime = timeStringToDate(block.startTime);
    startTimeRef.current = startTime;
    const endTime = timeStringToDate(block.endTime);
    endTimeRef.current = endTime;
    setAppsSelected(block.apps);

    const updatedDays = initialDays.map(day => {
        if (block.weekdays.includes(day.value)) {
            return { ...day, selected: true };
        }
        return day;
    });
    setDays(updatedDays);
  }

  const clearData = () => {
    setBlockTitle('');
    startTimeRef.current = currentTime;
    endTimeRef.current = new Date(currentTime.getTime() + 15 * 60000);
    setAppsSelected(0);
    setSitesSelected(0);
    setDays(initialDays);
  }

  const handleIconPress = () => {
    inputRef.current?.focus();
  }

  const handleCancel = () => {
    closeBottomSheet();
    const timeSpent = getTimeOnScreen();
    MixpanelService.trackEvent('block_period_creation_cancelled', {
      step_before_cancellation: '',
      entry_point: isEdit ? 'edit_button' : 'add_button',
      total_time_spent: timeSpent,
      timestamp: new Date().toISOString()
    });
  }

  const handleSaveButton = () => {
    if (isEdit) {
      handleEditBlock();
    } else {
      handleSaveLimit();
    }

    const timeSpent = getTimeOnScreen();
    MixpanelService.trackEvent('block_period_saved', {
      apps_selected_count: appsSelected,
      number_of_days_selected: days.filter(day => day.selected).length,
      total_block_periods_after_save: totalBlocks,
      total_time_spent: timeSpent,
      entry_point: isEdit ? 'edit_button' : 'add_button',
      error_occurred: false,
      timestamp: new Date().toISOString
    });
  }

  useLayoutEffect(() => {
    const loadBlockData = async () => {
      const result = await ScreenTimeModule.getBlock(blockId);
      if (result.status === 'success') {
        setBlockData(result.block);
      }
    };
    if (isEdit) {
      loadBlockData();
    } else {
      clearData();
    }
  }, [isEdit]);

  return (
    <View style={styles.container}>
      <View style={styles.titleContainer}>
        <TextInput ref={inputRef} value={blockTitle} onChangeText={setBlockTitle} style={styles.title} placeholderTextColor="black" placeholder={t('formNewLimit.blockName')} />
        <TouchableOpacity onPress={handleIconPress}>
          <Icon source="pencil" size={25} />
        </TouchableOpacity>
      </View>
      <TouchableOpacity onPress={handleSelectApps} style={styles.formOption}>
        <View style={styles.formOptionContent}>
          <View style={styles.labelOptionContainer}>
            <Icon source="shield" size={25} />
            <Text style={styles.label}>
              {t('formNewLimit.appsOptions')}
            </Text>
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
      <View style={styles.buttonContainer}>
        <Button onPress={readLastLog} icon="close" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: '#C6D3DF' }]} mode="contained">
          {t('formNewLimit.cancelButton')}
        </Button>
        <Button disabled={!formFilled} onPress={handleSaveButton} icon="check" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: buttonBackground }]} mode="contained">
          {t('formNewLimit.saveButton')}
        </Button>
      </View>
      <DeleteButton />
    </View>
  )
};
