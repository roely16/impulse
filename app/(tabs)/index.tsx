import { useRef, useEffect, useState } from 'react';
import { StyleSheet, NativeModules, View } from 'react-native';
import { Button } from 'react-native-paper';
import { Blocks } from '@/components/Blocks';
import { BottomSheetNewBlock } from '@/components/BottomSheet';
import { ListBlocks, BlockType } from '@/components/ListBlocks';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetModalProvider } from '@gorhom/bottom-sheet';

export default function HomeScreen() {

  const bottomSheetRef = useRef<BottomSheet>(null);
  const [blocks, setBlocks] = useState<BlockType[]>([]);
  const [bottomSheetVisible, setBottomSheetVisible] = useState(false);
  const [bottomSheetForm, setBottomSheetForm] = useState<string>('config-block');
  const [loading, setLoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [blockId, setBlockId] = useState<string | null>(null);

  const { ScreenTimeModule } = NativeModules;
  const openBottonSheet = () => {
    bottomSheetRef.current?.expand();
    setBottomSheetForm('config-block');
    setBottomSheetVisible(true);
  };

  const openNewBlockForm = () => {
    setBottomSheetForm('new-block');
    bottomSheetRef.current?.expand();
    setBottomSheetVisible(true);
  };

  const closedBottomSheet = () => {
    setBottomSheetVisible(false);
  };

  const openEditBlockForm = (blockId: string) => {
    console.log('blockId', blockId)
    setBlockId(blockId);
    setIsEditing(true);
    setBottomSheetForm('new-block');
    bottomSheetRef.current?.expand();
    setBottomSheetVisible(true);
  };

  const getBlocks = async (isRefreshing: boolean = false) => {
    setLoading(true);
    const blocks = await ScreenTimeModule.getBlocks();
    console.log('blocks', blocks)
    setBlocks(blocks.blocks);
    setLoading(false);
  };

  useEffect(() => {
    getBlocks();
  }, []);

  const BlockSection = () => {

    const existsBlocks = blocks.length > 0;
    if (existsBlocks) {
      return (
        <>
          <Blocks showBottomShet={openNewBlockForm} />
          <ListBlocks editBlock={openEditBlockForm} isLoading={loading} refreshBlocks={getBlocks} blocks={blocks} />
        </>
      );
    }

    return (
      <></>
    )
  }

  const AddButton = () => {
    if (bottomSheetVisible) {
      return <></>
    }

    return (
      <View style={styles.buttonContainer}>
        <Button
          style={styles.addButton}
          labelStyle={{ color: 'black' }}
          buttonColor="#FDE047"
          mode="contained"
          icon="check"
          onPress={openBottonSheet}
        >
          Añadir bloqueo
        </Button>
      </View>
    )
  };

  return (
    <GestureHandlerRootView style={styles.container}>
      <BottomSheetModalProvider>
        <BlockSection />
        <BottomSheetNewBlock blockId={blockId} isEdit={isEditing} setBottomSheetForm={setBottomSheetForm} bottomSheetForm={bottomSheetForm} onBottomSheetClosed={closedBottomSheet} refreshBlocks={getBlocks} ref={bottomSheetRef} />
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