import { useState, useRef, useEffect, useLayoutEffect } from "react";
import { View, StyleSheet, TouchableOpacity, NativeModules, TextInput, Alert } from "react-native";
import { Button, Icon, Text } from "react-native-paper";
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
interface FormNewBlockProps {
  changeForm: (form: string) => void;
  refreshBlocks: () => void;
  closeBottomSheet: () => void;
  isEdit?: boolean;
  blockId?: string | null;
  isEmptyBlock?: boolean;
  updateEmptyBlock?: (isEmpty: boolean) => void;
}

interface DayType {
  day: string;
  selected: boolean;
}

export const FormNewBlock = (props: FormNewBlockProps) => {

  const { refreshBlocks, changeForm, closeBottomSheet, isEdit, blockId, isEmptyBlock, updateEmptyBlock } = props;
  const [appsSelected, setAppsSelected] = useState(0);
  const [categoriesSelected, setCategoriesSelected] = useState(0);
  const [sitesSelected, setSitesSelected] = useState(0);
  const [blockTitle, setBlockTitle] = useState('');
  const currentTime = new Date();
  const startTimeRef = useRef(currentTime);
  const endTimeRef = useRef(new Date(new Date(currentTime.getTime() + 15 * 60000)));

  const initialDays = [
    { day: 'L', selected: false },
    { day: 'M', selected: false },
    { day: 'X', selected: false },
    { day: 'J', selected: false },
    { day: 'V', selected: false },
    { day: 'S', selected: false },
    { day: 'D', selected: false },
  ];

  const [days, setDays] = useState(initialDays);

  const { ScreenTimeModule } = NativeModules;

  const Frequency = (): React.ReactElement => {

    const toggleSelected = (selectedDay: DayType) => {
      const updatedDays = days.map((day) =>
        day.day === selectedDay.day ? { ...day, selected: !day.selected } : day
      );
      setDays(updatedDays);
    };

    return (
      <View>
        <Text style={styles.timeLabel}>Frecuencia</Text>
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
        <Text style={styles.timeLabel}>Seleccionar hora</Text>
        <View style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>Desde</Text>
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
            <Text style={styles.label}>Hasta</Text>
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
        setCategoriesSelected(result.categoriesSelected);
        setSitesSelected(result.sitesSelected);
        updateEmptyBlock && updateEmptyBlock(false);
      }
    } catch (error) {
      console.error(error);
    }
  };

  const emptySelected = appsSelected === 0 && categoriesSelected === 0 && sitesSelected === 0;

  const TextAppsSelected = (): React.ReactElement => {
    if (emptySelected) {
      return (
        <Text style={styles.selectLabel}>Seleccionar</Text>
      )
    }
    const selectedItems = [];

    if (appsSelected > 0) {
      selectedItems.push(`${appsSelected} apps`);
    }
    if (categoriesSelected > 0) {
      selectedItems.push(`${categoriesSelected} categorías`);
    }
    if (sitesSelected > 0) {
      selectedItems.push(`${sitesSelected} sitios`);
    }

    return (
      <Text style={styles.selectLabel}>{selectedItems.join(', ')}</Text>
    )
  };

  const handleSaveBlock = async () => {
    try {

      const startTime = convertDate(startTimeRef.current);
      const endTime = convertDate(endTimeRef.current);
      const data = {
        name: blockTitle,
        startTime,
        endTime,
        appsSelected
      }
      await ScreenTimeModule.createBlock(data.name, data.startTime, data.endTime);
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
          "Confirmación",
          "¿Estás seguro de que deseas eliminar el bloqueo?",
          [
            {
              text: "Cancelar",
              style: "cancel"
            },
            {
              text: "OK",
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
        <Text style={styles.deleteButton}>Eliminar bloqueo</Text>
      </TouchableOpacity>
    )
  };

  useLayoutEffect(() => {
    console.log('isEmptyBlock', isEmptyBlock);
  }, [isEmptyBlock]);

  return (
    <View style={styles.container}>
      <View style={styles.titleContainer}>
        <TextInput value={blockTitle} onChangeText={setBlockTitle} style={styles.title} placeholderTextColor="black" placeholder="Añadir Nombre del Bloqueo" />
        <Icon source="pencil" size={25} />
      </View>
      <TouchableOpacity onPress={handleSelectApps} style={styles.formOption}>
        <View style={styles.formOptionContent}>
          <View style={styles.labelOptionContainer}>
            <Icon source="shield" size={25} />
            <Text style={styles.label}>Apps</Text>
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
        <Button onPress={closeBottomSheet} icon="close" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: '#C6D3DF' }]} mode="contained">Cancelar</Button>
        <Button disabled={!formFilled} onPress={handleSaveBlock} icon="check" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: buttonBackground }]} mode="contained">Guardar</Button>
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