import { useRef, useEffect, useState, useMemo } from 'react';
import { StyleSheet, NativeModules, View } from 'react-native';
import { Blocks } from '@/components/Blocks';
import { BottomSheetNewBlock } from '@/components/BottomSheet';
import { ListBlocks, BlockType } from '@/components/ListBlocks';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetModalProvider } from '@gorhom/bottom-sheet';
import { Text, Button } from 'react-native-paper';

export default function HomeScreen() {

  const bottomSheetRef = useRef<BottomSheet>(null);
  const [blocks, setBlocks] = useState<BlockType[]>([]);

  const { ScreenTimeModule } = NativeModules;
  const openBottonSheet = () => {
    bottomSheetRef.current?.expand();
  };

  const getBlocks = useMemo(() => {
    const init = async () => {
      const blocks = await ScreenTimeModule.getBlocks();
      setBlocks(blocks.blocks);
    }
    return init;
  }, []);

  useEffect(() => {
    getBlocks();
  }, []);

  const BlockSection = () => {

    const existsBlocks = blocks.length > 0;
    if (existsBlocks) {
      return (
        <>
          <Blocks showBottomShet={openBottonSheet} />
          <ListBlocks refreshBlocks={getBlocks} blocks={blocks} />
        </>
      );
    }

    return (
      <View style={{ flex: 1, justifyContent: 'center', paddingHorizontal: 20, flexDirection: 'column', gap: 10, alignItems: 'center' }}>
        <Text style={{ textAlign: 'center' }} variant="headlineSmall">No hay bloqueos configurados</Text>
        <View style={{ flexDirection: 'row' }}>
          <Button onPress={openBottonSheet} labelStyle={{ color: 'black' }} style={styles.button} contentStyle={{ flexDirection: 'row-reverse' }} icon="plus" mode="contained">Agregar</Button>
        </View>
      </View>
    )
  }

  return (
    <GestureHandlerRootView style={styles.container}>
      <BottomSheetModalProvider>
        <BlockSection />
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
  button: {
    paddingHorizontal: 18,
    paddingVertical: 7,
    borderRadius: 6,
    backgroundColor: '#FDE047'
  }
});