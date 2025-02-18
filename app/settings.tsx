import { useEffect, useState } from "react";
import { View, Text, StyleSheet, TouchableOpacity, Share, Linking, Alert } from "react-native";
import { IconButton } from "react-native-paper";
import { heightPercentageToDP as hp, widthPercentageToDP as wp } from "react-native-responsive-screen";
import { RFValue } from "react-native-responsive-fontsize";
import { SCREEN_HEIGHT } from "@/constants/Device";
import { useTranslation } from "react-i18next";
import { Feather } from '@expo/vector-icons';
import { openComposer } from "react-native-email-link";
import { router } from "expo-router";
import { getVersion, getBuildNumber, getUniqueId } from 'react-native-device-info';
import Clipboard from '@react-native-clipboard/clipboard';

interface OptionProps {
  text: string;
  icon: string;
  onPress?: () => void;
}

export default function Settings() {

  const { t } = useTranslation();
  
  const handleSendMail = async (subject: string) => {
    openComposer({
      to: "pablogranados93@gmail.com",
      subject: subject
    });
  }

  const handleShare = async () => {
    try {
      await Share.share({
        message: t('settings.share.shareMessage'),
      });
    } catch (error: any) {
      console.error(error.message);
    }
  };

  const handleOpenFAQ = () => {
    Linking.openURL('https://impulsecontrolapp.com/');
  }

  const Header = () => {

    const goBack = () => {
      router.back();
    }

    return (
      <View style={styles.header}>
        <View style={{ position: 'absolute', left: 10 }}>
          <IconButton onPress={goBack} icon="close" />
        </View>
        <Text style={styles.headerText}>
          {t('settings.title')}
        </Text>
      </View>
    )
  }

  const Option = (props: OptionProps) => {

    const { text, icon, onPress } = props;
    return (
      <TouchableOpacity onPress={onPress} style={styles.option}>
        <Text style={styles.optionText}>{text}</Text>
        <Feather name={icon} size={24} color='black' />
      </TouchableOpacity>
    )
  }

  const ShareComponent = () => {
    return (
      <View style={styles.optionContainer}>
        <Text style={styles.title}>{t('settings.share.title')}</Text>
        <Option onPress={handleShare} text={t('settings.share.button')} icon="share-2" />
      </View>
    )
  }

  const Feedback = () => {
    return (
      <View style={styles.optionContainer}>
        <Text style={styles.title}>{t('settings.feedback.title')}</Text>
        <Option onPress={() => handleSendMail(t('settings.feedback.sendFeedback'))} text={t('settings.feedback.sendFeedback')} icon="send" />
        <Option onPress={() => handleSendMail(t('settings.feedback.recommendImprovement'))} text={t('settings.feedback.recommendImprovement')} icon="send" />
      </View>
    )
  }

  const About = () => {
    return (
      <View style={styles.optionContainer}>
        <Text style={styles.title}>{t('settings.about.title')}</Text>
        <Option onPress={handleOpenFAQ} text={t('settings.about.faq')} icon="help-circle" />
        <Option onPress={() => handleSendMail(t('settings.about.contact'))} text={t('settings.about.contact')} icon="send" />
      </View>
    )
  }

  const VersionNumber = () => {

    const [uniqueId, setUniqueId] = useState('');

    useEffect(() => {
      async function init() {
        const uniqueId = await getUniqueId();
        setUniqueId(uniqueId);
      }
      init();
    }, [])

    const copyToClipboard = () => {
      Clipboard.setString(uniqueId);
    }

    const showUniqueId = () => {
      Alert.alert('User ID', `${uniqueId}`, [
        { text: "Copy", onPress: copyToClipboard, style: "cancel" },
        { text: "Close", onPress: () => console.log("Aceptado") }
      ]);
    }

    return (
      <Text onPress={showUniqueId} style={styles.version}>{`${t('settings.version')} ${getVersion()} (${getBuildNumber()})`}</Text>
    )
  }

  return (
    <View style={{ flex: 1 }}>
      <Header/>
      <View style={styles.container}>
        <ShareComponent />
        <Feedback />
        <About />
      </View>
      <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'center' }}>
        <VersionNumber />
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
    padding: wp('5%'),
    gap: hp('3%')
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: wp('2%'),
    justifyContent: 'center'
  },
  headerText: {
    fontFamily: 'Catamaran',
    fontSize: RFValue(22, SCREEN_HEIGHT),
    fontWeight: '700'
  },
  title: {
    fontFamily: 'Catamaran',
    fontSize: RFValue(19, SCREEN_HEIGHT),
    fontWeight: '700'
  },
  optionContainer: {
    gap: hp('1.5%')
  },
  option: {
    backgroundColor: '#FDE047',
    paddingVertical: wp('3%'),
    paddingHorizontal: wp('4%'),
    borderRadius: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between'
  },
  optionText: {
    fontFamily: 'Catamaran',
    fontSize: RFValue(19, SCREEN_HEIGHT),
    fontWeight: '700'
  },
  version: {
    fontFamily: 'Mulish',
    fontSize: RFValue(16, SCREEN_HEIGHT),
    fontWeight: '600',
    lineHeight: RFValue(24, SCREEN_HEIGHT),
    color: '#203B52',
    textAlign: 'center',
    position: 'absolute',
    bottom: hp('5%')
  }
});