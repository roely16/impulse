import { useState } from "react";
import { View, StyleSheet, TouchableWithoutFeedback, Switch, NativeModules, Alert } from "react-native";
import { Card, Text } from "react-native-paper";

interface BlockCardProps {
  id: string;
  title: string;
  subtitle: string;
  apps: number;
  enable: boolean;
  refreshBlocks: () => void;
}

export const BlockCard = (props: BlockCardProps) => {
  const { id, title, subtitle, apps, enable, refreshBlocks } = props;
  const [isEnabled, setIsEnabled] = useState(false);

  const { ScreenTimeModule } = NativeModules;

  const handleDeleteBlock = async () => {
    try {
      const response = await ScreenTimeModule.deleteBlock(id);
      refreshBlocks();
    } catch (error) {
      console.log('error deleting block', error)
    }
  }

  const updateBlockStatus = async (status: boolean) => {
    try {
      const response = await ScreenTimeModule.updateBlockStatus(id, status);
      console.log('update block status response', response)
      refreshBlocks();
    } catch (error) {
      console.log('error updating block status', error)
    }
  }

  const deleteBlock = async () => {
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
              handleDeleteBlock();
            }
          }
        ]
      );
    } catch (error) {
      console.log(error);
    }
  }
  return (
    <Card style={styles.card} mode="elevated" elevation={1}>
      <Card.Content style={styles.cardContent}>
        <View style={styles.rowContainer}>
          <Text style={styles.title}>{title}</Text>
          <TouchableWithoutFeedback onPress={deleteBlock}>
            <Text style={styles.subtitle}>Eliminar</Text>
          </TouchableWithoutFeedback>
        </View>
        <Text style={styles.subtitle}>{subtitle}</Text>
        <View style={styles.rowContainer}>
          <Text style={styles.subtitle}>Aplicaciones: {apps}</Text>
          <Switch onValueChange={value => updateBlockStatus(value)} value={enable} thumbColor={isEnabled ? '#203B52' : '#f4f3f4'} trackColor={{false: '#767577', true: '#FDE047'}} />
        </View>
      </Card.Content>
    </Card>
  )
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: 'white'
  },
  cardContent: {
    gap: 5
  },
  rowContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  title: {
    fontSize: 19,
    lineHeight: 24.7,
    fontWeight: 700,
    color: '#3A3A3C'
  },
  subtitle: {
    fontSize: 12,
    fontWeight: 400,
    lineHeight: 20.4,
    color: '#C6D3DF'
  }
});