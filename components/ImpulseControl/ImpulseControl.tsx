import { View, FlatList } from "react-native"
import { Text } from "react-native-paper";
import { HeaderLimits } from "../HeaderLimits";
import { styles } from "./styles"
import { useTranslation } from "react-i18next";
import { LimitType } from "../LimitCard";

export interface ImpulseControlProps {
  limits: LimitType[]
};

export const ImpulseControl = (props: ImpulseControlProps) => {

  const { limits } = props;
  const { t } = useTranslation();

  const Header = () => {
    return (
      <View>
        <View style={styles.messageContainer}>
          <Text style={styles.title}>{t('impulseControlScreen.title')}</Text>
          <Text style={styles.message}>
            {t('impulseControlScreen.message.first')}
            <Text style={styles.messageBold}>{t('impulseControlScreen.message.second')}</Text>
            {t('impulseControlScreen.message.third')}
          </Text>
        </View>
        <HeaderLimits showBottomShet={() => null} numberOfLimits={0} />
      </View>
    )
  };

  return (
    <View style={styles.container}>
      <FlatList ListHeaderComponent={<Header />} renderItem={() => <></>} data={limits} keyExtractor={item => item.id} />
    </View>
  )
}