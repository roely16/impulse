import { useRef, useEffect, useState, useLayoutEffect, useCallback } from 'react';
import { StyleSheet, NativeModules, View, SectionList } from 'react-native';
import { Button } from 'react-native-paper';
import { BottomSheetNewBlock } from '@/components/BottomSheet';
import { ListBlocks, BlockType } from '@/components/ListBlocks';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetModalProvider } from '@gorhom/bottom-sheet';
import { CardTimeHome } from '@/components/CardTimeHome';
import { useTranslation } from 'react-i18next';
import { MixpanelService } from '@/SDK/Mixpanel';
import useTimeOnScreen from '@/hooks/useTimeOnScreen';
import { useFocusEffect } from 'expo-router';
import { HeaderLimits } from '@/components/HeaderLimits';
import { HeaderBlocks } from '@/components/HeaderBlocks';
import { BlockCard } from '@/components/BlockCard';
import { LimitCard, ListType } from '@/components/LimitCard';

export default function HomeScreen() {

  const { t } = useTranslation();

  const bottomSheetRef = useRef<BottomSheet>(null);
  const [blocks, setBlocks] = useState<BlockType[]>([]);
  const [limits, setLimits] = useState<ListType[]>([]);
  const [bottomSheetVisible, setBottomSheetVisible] = useState(false);
  const [bottomSheetForm, setBottomSheetForm] = useState<string>('config-block');
  const [loading, setLoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [blockId, setBlockId] = useState<string | null>(null);
  const [isEmptyBlock, setIsEmptyBlock] = useState(false);

  const getTimeOnScreen = useTimeOnScreen();

  const { ScreenTimeModule } = NativeModules;
  const openBottonSheet = () => {
    bottomSheetRef.current?.expand();
    setBottomSheetForm('config-block');
    setBottomSheetVisible(true);
    setIsEditing(false);
    setBlockId(null);
    setIsEmptyBlock(true);
  };

  const openNewBlockForm = () => {
    setBottomSheetForm('new-block');
    setIsEditing(false);
    setBlockId(null);
    setIsEmptyBlock(true);
    bottomSheetRef.current?.expand();
    setBottomSheetVisible(true);
  };

  const closedBottomSheet = () => {
    setBottomSheetVisible(false);
    setIsEditing(false);
    setBlockId(null);
    setIsEmptyBlock(true);
  };

  const openEditBlockForm = (blockId: string) => {
    setBlockId(blockId);
    setIsEditing(true);
    setBottomSheetForm('new-block');
    bottomSheetRef.current?.expand();
    setBottomSheetVisible(true);
  };

  const getBlocks = async (isRefreshing: boolean = false) => {
    setLoading(true);
    const blocks = await ScreenTimeModule.getBlocks();
    console.log(blocks);
    setBlocks(blocks.blocks);
    setLoading(false);
  };

  const getLimits = async () => {
    try {
      const limits = await ScreenTimeModule.getLimits();
      setLimits(limits.limits);
      console.log(limits);
    } catch {
      console.log('Error getting limits');
    }
  }
  
  useEffect(() => {
    getBlocks();
    getLimits();
  }, []);

  useFocusEffect(
    useCallback(() => {
      MixpanelService.trackEvent('home', {
        entry_point: 'snackbar',
        timestamp: new Date().toISOString()
      });
    }, [])
  );

  const BlockSection = () => {

    const sectionListData = [
      {
        title: <HeaderBlocks numberOfBlocks={blocks.length} showBottomShet={openNewBlockForm} />,
        type: 'block',
        data: blocks
      },
      {
        title: <HeaderLimits showBottomShet={openBottonSheet} numberOfBlocks={blocks.length} />,
        type: 'limit',
        data: limits
      }
    ];

    const getBlocksActiveAndInactive = (): { active: number, inactive: number } => {
      const active = blocks.filter((block) => block.enable).length;
      const inactive = blocks.filter((block) => !block.enable).length;
  
      return {
        active,
        inactive
      }
    }
  
    const totalOfBlocks = getBlocksActiveAndInactive();

    return (
      <SectionList
        sections={sectionListData}
        stickySectionHeadersEnabled={false}
        keyExtractor={(item) => item.id}
        renderItem={({ item, section }) => {
          if (section.type === 'block') {
            return <BlockCard total_blocks={blocks.length} total_active_limits={totalOfBlocks.active} total_inactive_limits={totalOfBlocks.inactive} editBlock={(key) => openEditBlockForm(key)} refreshBlocks={getBlocks} {...item} />
          } else if (section.type === 'limit') {
            return <LimitCard editBlock={(key) => openEditBlockForm(key)} refreshBlocks={getBlocks} {...item}></LimitCard>
          }
          return <></>;
        }}
        renderSectionHeader={({ section: { title } }) => title}
      />
    )
  }

  const AddButton = () => {
    if (bottomSheetVisible) {
      return <></>
    }

    const handleAddButon = () => {
      openBottonSheet();
      const timeSpent = getTimeOnScreen();
      MixpanelService.trackEvent('add_block_button', {
        localization: 'Home',
        type_button: 'button_principal_home',
        time_spent_before_click: timeSpent,
        existing_block_periods: blocks.length,
        existing_limit_app: 0,
        device_type: 'iOS',
        timestamp: new Date().toISOString()
      })
    };

    return (
      <View style={styles.buttonContainer}>
        <Button
          style={styles.addButton}
          labelStyle={{ color: 'black' }}
          buttonColor="#FDE047"
          mode="contained"
          icon="check"
          onPress={handleAddButon}
        >
          {t('blocksScreen.addBlockButton')}
        </Button>
      </View>
    )
  };

  return (
    <GestureHandlerRootView style={styles.container}>
      <CardTimeHome />
      <BottomSheetModalProvider>
        <BlockSection />
        <BottomSheetNewBlock totalBlocks={blocks.length} updateEmptyBlock={setIsEmptyBlock} isEmptyBlock={isEmptyBlock} blockId={blockId} isEdit={isEditing} setBottomSheetForm={setBottomSheetForm} bottomSheetForm={bottomSheetForm} onBottomSheetClosed={closedBottomSheet} refreshBlocks={getBlocks} ref={bottomSheetRef} />
      </BottomSheetModalProvider>
      <AddButton />
    </GestureHandlerRootView>
  );
}


const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  bottomContainer: {
    flex: 1,
    padding: 24,
    backgroundColor: 'grey',
  },
  contentContainer: {
    flex: 1,
    alignItems: 'center',
  },
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6,
    backgroundColor: '#FDE047'
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10
  },
  addButton: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6
  },
});