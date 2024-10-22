import { useState, useRef, useEffect, useLayoutEffect } from "react";
import { View, StyleSheet, TouchableOpacity, NativeModules, TextInput, Alert } from "react-native";
import { Button, Icon, Text } from "react-native-paper";
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import { useTranslation } from "react-i18next";
interface FormNewBlockProps {
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
  selected: boolean;
}

export const FormNewBlock = (props: FormNewBlockProps) => {

  const { refreshBlocks, changeForm, closeBottomSheet, isEdit, blockId, isEmptyBlock, updateEmptyBlock, totalBlocks = 0 } = props;
  const [appsSelected, setAppsSelected] = useState(0);
  const [sitesSelected, setSitesSelected] = useState(0);
  const [blockTitle, setBlockTitle] = useState('');
  const currentTime = new Date();
  const startTimeRef = useRef(currentTime);
  const endTimeRef = useRef(new Date(new Date(currentTime.getTime() + 15 * 60000)));

  const { t } = useTranslation();

  const initialDays = [
    { day: 'L', value: 2, selected: false },
    { day: 'M', value: 3, selected: false },
    { day: 'X', value: 4, selected: false },
    { day: 'J', value: 5, selected: false },
    { day: 'V', value: 6, selected: false },
    { day: 'S', value: 7, selected: false },
    { day: 'D', value: 1, selected: false },
  ];

  const [days, setDays] = useState(initialDays);

  const { ScreenTimeModule } = NativeModules;

  const readLastLog = () => {
    try {
      const response = ScreenTimeModule.readLastLog();
    } catch (error) {
      console.error(error);
    }
  }

  const Frequency = (): React.ReactElement => {

    const toggleSelected = (selectedDay: DayType) => {
      const updatedDays = days.map((day) =>
        day.day === selectedDay.day ? { ...day, selected: !day.selected } : day
      );
      setDays(updatedDays);
    };

    return (
      <View>
        <Text style={styles.timeLabel}>
          {t('formNewBlock.frequency')}
        </Text>
        <View style={styles.daysContainer}>
          {
            days.map((day, index) => (
              <TouchableOpacity onPress={() => toggleSelected(day)} key={day.day} style={day.selected ? styles.daySelected : styles.dayButton}>
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
          {t('formNewBlock.selectTime')}
        </Text>
        <View style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>
              {t('formNewBlock.from')}
            </Text>
            <DateTimePicker
              value={startTimeRef.current}
              mode="time"
              onChange={onChange}
              display="default"
            />
          </View>
        </View>
        <View style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>
              {t('formNewBlock.to')}
            </Text>
            <DateTimePicker
              value={endTimeRef.current}
              mode="time"
              onChange={onChangeTo}
              display="default"
            />
          </View>
        </View>
      </View>
    )
  };

  const handleSelectApps = async () => {
    try {
      const result = await ScreenTimeModule.showAppPicker(isEmptyBlock);
      if (result.status === 'success') {
        setAppsSelected(result.appsSelected);
        setSitesSelected(result.sitesSelected);
        updateEmptyBlock && updateEmptyBlock(false);
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
          {t('formNewBlock.appsPlaceholder')}
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

  const handleSaveBlock = async () => {
    try {

      const startTime = convertDate(startTimeRef.current);
      const endTime = convertDate(endTimeRef.current);
      const haveBlockTitle = blockTitle.length > 0;
      const newBlockTitle = haveBlockTitle ? blockTitle : `${t('formNewBlock.defaultBlockName')} #${totalBlocks + 1}`;

      const weekDays = days.filter((day) => day.selected).map((day) => day.value).sort((a, b) => a - b);
      const data = {
        name: newBlockTitle,
        startTime,
        endTime,
        appsSelected,
        weekDays
      }
      console.log('save data', data);
      const response = await ScreenTimeModule.createBlock(data.name, data.startTime, data.endTime, data.weekDays);
      console.log('response', response);
      refreshBlocks();
      closeBottomSheet()
      changeForm('')
    } catch (error) {
      console.log('error', error);
    }
  };

  const formFilled = !emptySelected && startTimeRef && endTimeRef;

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
          `${t('formNewBlock.deleteAlert.title')}`,
          `${t('formNewBlock.deleteAlert.message')}`,
          [
            {
              text: `${t('formNewBlock.deleteAlert.cancelButton')}`,
              style: "cancel"
            },
            {
              text: `${t('formNewBlock.deleteAlert.confirmButton')}`,
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
          {t('formNewBlock.deleteButton')}
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
    console.log('block', block);
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
        <TextInput value={blockTitle} onChangeText={setBlockTitle} style={styles.title} placeholderTextColor="black" placeholder={t('formNewBlock.blockName')} />
        <Icon source="pencil" size={25} />
      </View>
      <TouchableOpacity onPress={handleSelectApps} style={styles.formOption}>
        <View style={styles.formOptionContent}>
          <View style={styles.labelOptionContainer}>
            <Icon source="shield" size={25} />
            <Text style={styles.label}>
              {t('formNewBlock.appsOptions')}
            </Text>
          </View>
          <View style={styles.selectOptionContainer}>
            <TextAppsSelected />
            <Icon source="chevron-right" size={25} />
          </View>
        </View>
      </TouchableOpacity>
      <TimeConfigurationForm />
      <Frequency />
      <View style={styles.buttonContainer}>
        <Button onPress={closeBottomSheet} icon="close" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: '#C6D3DF' }]} mode="contained">
          {t('formNewBlock.cancelButton')}
        </Button>
        <Button disabled={!formFilled} onPress={handleSaveBlock} icon="check" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: buttonBackground }]} mode="contained">
          {t('formNewBlock.saveButton')}
        </Button>
      </View>
      <DeleteButton />
    </View>
  )
};

const styles = StyleSheet.create({
  container: {
    paddingBottom: 30
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    gap: 10
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    borderBottomWidth: 1,
    fontFamily: 'Catamaran'
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
  formOption: {
    backgroundColor: '#FDE047',
    padding: 18,
    borderRadius: 15
  },
  formOptionContent: {
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  labelOptionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10
  },
  selectOptionContainer: {
    flexDirection: 'row',
    alignItems: 'center' 
  },
  timeFormContainer: {
    marginVertical: 20,
    flexDirection: 'column',
    gap: 20
  },
  timeOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  label: {
    fontSize: 20,
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  timeLabel: {
    fontSize: 19,
    fontWeight: '700',
    fontFamily: 'Catamaran'
  },
  selectLabel: {
    color: 'rgba(0, 0, 0, 0.32)',
    fontSize: 20,
    fontWeight: '500',
    fontFamily: 'Catamaran'
  },
  buttonLabel: {
    color: '#203B52',
    fontSize: 16,
    fontWeight: '600' 
  },
  daysContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 20
  },
  dayButton: {
    backgroundColor: '#F2F2F5',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 24,
    fontFamily: 'Mulish'
  },
  daySelected: {
    backgroundColor: '#3F5B74',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 24,
    fontFamily: 'Mulish'
  },
  deleteButton: {
    fontFamily: 'Catamaran',
    color: '#FF3B3B',
    fontSize: 18,
    textDecorationLine: 'underline',
    textAlign: 'center',
    marginTop: 20
  }
});