import { useRef, useEffect, useState, useMemo } from 'react';
import { StyleSheet, NativeModules } from 'react-native';
import { Blocks } from '@/components/Blocks';
import { BottomSheetNewBlock } from '@/components/BottomSheet';
import { ListBlocks, BlockType } from '@/components/ListBlocks';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetModalProvider } from '@gorhom/bottom-sheet';

export default function HomeScreen() {

  const bottomSheetRef = useRef<BottomSheet>(null);
  const [blocks, setBlocks] = useState<BlockType[]>([]);

  const { ScreenTimeModule } = NativeModules;
  const openBottonSheet = () => {
    bottomSheetRef.current?.expand();
  };

  const getBlocks = useMemo(() => {
    const init = async () => {
      console.log('getBlocks')
      const blocks = await ScreenTimeModule.getBlocks();
      console.log('blocks', blocks)
      setBlocks(blocks.blocks);
    }
    return init;
  }, []);

  useEffect(() => {
    getBlocks();
  }, []);

  return (
    <GestureHandlerRootView style={styles.container}>
      <BottomSheetModalProvider>
        <Blocks showBottomShet={openBottonSheet} />
        <ListBlocks refreshBlocks={getBlocks} blocks={blocks} />
        <BottomSheetNewBlock refreshBlocks={getBlocks} ref={bottomSheetRef} />
      </BottomSheetModalProvider>
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
});