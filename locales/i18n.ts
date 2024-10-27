import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import { getLocales } from "react-native-localize";
import en from './en.json';
import es from './es.json';
import de from './de.json';
import fr from './fr.json';

console.log(getLocales());

const languages = getLocales().map(locale => locale.languageCode);
const defaultLanguage = languages.length > 0 ? languages[0] : 'es';

i18n
  .use(initReactI18next)
  .init({
    lng: 'es',
    compatibilityJSON: 'v3',
    fallbackLng: 'es',
    interpolation: {
      escapeValue: false,
    },
    resources: {
      es: {
        translation: es
      },
      en: {
        translation: en
      },
      fr: {
        translation: fr
      },
      de: {
        translation: de
      }
    },
    debug: false
  });

export default i18n;