import { useTranslation } from "react-i18next";
import { CardUsageTime } from "../CardUsageTime";
import { getLocales } from "react-native-localize";

export const DailyUsageTime = () => {

  const { t } = useTranslation();
  const languages = getLocales().map(locale => locale.languageTag);
  
  const getTodayDate = () => {
    const today = new Date();
    const options = { day: 'numeric', month: 'short' };
    return today.toLocaleDateString(languages[0], options);
  }

  return (
    <CardUsageTime 
      sectionTitle={t('usageReportScreen.dailyUsageTime.title')} 
      title={getTodayDate()}
      averageTime="3h 45m"
      percentageChange={15}
    />
  );
};