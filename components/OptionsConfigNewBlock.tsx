import { View, StyleSheet, TouchableOpacity } from "react-native";
import { Text, Icon } from "react-native-paper";

interface OptionsConfigNewBlockProps {
  changeForm: (form: string) => void;
}

export const OptionsConfigNewBlock = (props: OptionsConfigNewBlockProps) => {

  const { changeForm } = props;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Configurar nuevo bloqueo</Text>
      <View style={{ flexDirection: 'column', gap: 20, marginTop: 20 }}>
        <TouchableOpacity onPress={() => changeForm('new-block')} style={styles.button}>
          <View style={styles.contentButton}>
            <View style={styles.buttonLabelContainer}>
              <Icon source="timelapse" size={25} />
              <Text style={styles.buttonLabel}>Bloqueo por Horas</Text>
            </View>
            <Icon source="chevron-right" size={25} />
          </View>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button}>
          <View style={styles.contentButton}>
            <View style={styles.buttonLabelContainer}>
              <Icon source="timer-sand" size={25} />
              <Text style={styles.buttonLabel}>Limite de uso</Text>
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