import { useTranslation } from "react-i18next";
import { CardUsageTime } from "../CardUsageTime";

export const OpeningAttempts = () => {

  const { t } = useTranslation();

  return (
    <CardUsageTime 
      sectionTitle={t('usageReportScreen.openingAttemps.title')} 
      title={t('usageReportScreen.openingAttemps.cardLabel')}
      averageTime="250"
      percentageChange={15}
    />
  );
};