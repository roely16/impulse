import { useTranslation } from "react-i18next";
import { CardUsageTime } from "../CardUsageTime";

export const WeeklyUsageTime = () => {

  const { t } = useTranslation();

  return (
    <CardUsageTime 
      sectionTitle={t('usageReportScreen.weeklyUsageTime.title')} 
      title={t('usageReportScreen.weeklyUsageTime.cardLabel')}
      averageTime="3h 45m"
      percentageChange={15}
    />
  );
};