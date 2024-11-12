import { View, FlatList } from "react-native"
import { Text } from "react-native-paper";
import { HeaderLimits } from "../HeaderLimits";
import { styles } from "./styles"
import { useTranslation } from "react-i18next";
import { LimitType, LimitCard } from "../LimitCard";

export interface ImpulseControlProps {
  limits: LimitType[],
  configNewImpulse: () => void
  openEditLimit: (key: string) => void
  getLimits: () => void
};

export const ImpulseControl = (props: ImpulseControlProps) => {

  const { limits, configNewImpulse, openEditLimit, getLimits } = props;
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
        <HeaderLimits showBottomShet={configNewImpulse} numberOfLimits={0} />
      </View>
    )
  };

  return (
    <View style={styles.container}>
      <FlatList
        ListHeaderComponent={<Header />}
        renderItem={({ item }) => (
          <LimitCard
            refreshLimits={getLimits}
            editLimit={key => openEditLimit(key)}
            total_limits={limits.length}
            {...item}
          />
        )}
        data={limits}
        keyExtractor={item => item.id}
      />
    </View>
  );
}