import { View, StyleSheet, TouchableOpacity } from "react-native";
import { Text, Icon } from "react-native-paper";
import { useTranslation } from "react-i18next";

interface BlocksProps {
  showBottomShet: () => void;
}

export const Blocks = (props: BlocksProps) => {
  const { showBottomShet } = props;

  const { t } = useTranslation();

  return (
    <View style={styles.container}>
      <View style={styles.headerContainer}>
        <Text style={styles.headerTitle}>
          {t('blocksSection.title')}
        </Text>
          <TouchableOpacity onPress={showBottomShet} style={styles.addButton}>
            <View style={{flexDirection:'row', gap: 5}}>
              <Icon source="plus-circle-outline" size={15} />
              <Text style={styles.addLabel}>
                {t('blocksSection.addButton')}
              </Text>
            </View>
          </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: 20,
    paddingHorizontal: 20
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 700,
    fontFamily: 'Catamaran'
  },
  addButton: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 0.2,
    padding: 5,
    borderRadius: 30,
    paddingHorizontal: 10,
    gap: 5
  },
  addLabel: {
    fontFamily: 'Mulish',
    fontWeight: '500',
    fontSize: 12
  }
});