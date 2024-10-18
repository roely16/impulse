import { useState, useRef } from "react";
import { View, StyleSheet, TouchableHighlight, TouchableOpacity, NativeModules, TextInput } from "react-native";
import { Button, Icon, Text } from "react-native-paper";
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
interface FormNewBlockProps {
  changeForm: (form: string) => void;
  refreshBlocks: () => void;
  closeBottomSheet: () => void;
}

export const FormNewBlock = (props: FormNewBlockProps) => {

  const { refreshBlocks, changeForm, closeBottomSheet } = props;
  const [appsSelected, setAppsSelected] = useState(0);
  const [blockTitle, setBlockTitle] = useState('');
  const currentTime = new Date();
  const startTimeRef = useRef(currentTime);
  const endTimeRef = useRef(new Date(new Date(currentTime.getTime() + 15 * 60000)));

  const { ScreenTimeModule } = NativeModules;

  const Frequency = (): React.ReactElement => {

    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return (
      <View>
        <Text style={styles.timeLabel}>Frecuencia</Text>
        <View style={styles.daysContainer}>
          {
            days.map((day, index) => (
              <TouchableOpacity key={index} style={styles.dayButton}>
                <Text>{day}</Text>
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
        <TouchableHighlight style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>Desde</Text>
            <DateTimePicker
              value={startTimeRef.current}
              mode="time"
              onChange={onChange}
              display="default"
            />
          </View>
        </TouchableHighlight>
        <TouchableHighlight style={styles.formOption}>
          <View style={styles.timeOption}>
            <Text style={styles.label}>Hasta</Text>
            <DateTimePicker
              value={endTimeRef.current}
              mode="time"
              onChange={onChangeTo}
              display="default"
            />
          </View>
        </TouchableHighlight>
      </View>
    )
  };

  const handleSelectApps = async () => {
    try {
      const result = await ScreenTimeModule.showAppPicker();
      if (result.status === 'success') {
        setAppsSelected(result.totalSelected);
      }
    } catch (error) {
      console.error(error);
    }
  };

  const TextAppsSelected = (): React.ReactElement => {
    if (appsSelected === 0) {
      return (
        <Text style={styles.selectLabel}>Seleccionar</Text>
      )
    }
    return (
      <Text style={styles.selectLabel}>{appsSelected} apps seleccionadas</Text>
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

  const formFilled = blockTitle && appsSelected > 0 && startTimeRef && endTimeRef;

  const buttonBackground = formFilled ? '#FDE047' : '#C6D3DF';

  return (
    <View style={styles.container}>
      <View style={styles.titleContainer}>
        <TextInput value={blockTitle} onChangeText={setBlockTitle} style={styles.title} placeholderTextColor="black" placeholder="Añadir Nombre del Bloqueo" />
        <Icon source="pencil" size={25} />
      </View>
      <TouchableHighlight onPress={handleSelectApps} style={styles.formOption}>
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
      </TouchableHighlight>
      <TimeConfigurationForm />
      <Frequency />
      <View style={styles.buttonContainer}>
        <Button onPress={closeBottomSheet} icon="close" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: '#C6D3DF' }]} mode="contained">Cancelar</Button>
        <Button onPress={handleSaveBlock} icon="check" labelStyle={styles.buttonLabel} contentStyle={{ flexDirection: 'row-reverse' }} style={[styles.button, { backgroundColor: buttonBackground }]} mode="contained">Guardar</Button>
      </View>
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
    fontWeight: 700,
    lineHeight: 28.6,
    borderBottomWidth: 1
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
    fontWeight: 700,
    lineHeight: 26
  },
  timeLabel: {
    fontSize: 19,
    fontWeight: 700,
    lineHeight: 24.7
  },
  selectLabel: {
    color: 'rgba(0, 0, 0, 0.32)',
    fontSize: 20,
    fontWeight: 500,
    lineHeight: 26
  },
  buttonLabel: {
    color: '#203B52',
    fontSize: 16,
    fontWeight: 600 
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
    borderRadius: 24
  }
});