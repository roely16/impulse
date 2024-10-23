
import i18n from 'i18next';

interface Weekday {
  day: string;
  value: number;
  name: string;
  selected: boolean;
}

export const WEEKDAYS: Weekday[] = [
  { day: i18n.t('weekdaysLetters.monday'), value: 2, name: i18n.t('weekdays.monday'), selected: false },
  { day: i18n.t('weekdaysLetters.tuesday'), value: 3, name: i18n.t('weekdays.tuesday'), selected: false },
  { day: i18n.t('weekdaysLetters.wednesday'), value: 4, name: i18n.t('weekdays.wednesday'), selected: false },
  { day: i18n.t('weekdaysLetters.thursday'), value: 5, name: i18n.t('weekdays.thursday'), selected: false },
  { day: i18n.t('weekdaysLetters.friday'), value: 6, name: i18n.t('weekdays.friday'), selected: false },
  { day: i18n.t('weekdaysLetters.saturday'), value: 7, name: i18n.t('weekdays.saturday'), selected: false },
  { day: i18n.t('weekdaysLetters.sunday'), value: 1, name: i18n.t('weekdays.sunday'), selected: false }
];
