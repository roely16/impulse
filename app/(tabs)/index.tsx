import { useRef } from 'react';
import { StyleSheet } from 'react-native';
import { Blocks } from '@/components/Blocks';
import { BottomSheetNewBlock } from '@/components/BottomSheet';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetModalProvider } from '@gorhom/bottom-sheet';

export default function HomeScreen() {

  const bottomSheetRef = useRef<BottomSheet>(null);

  const openBottonSheet = () => {
    bottomSheetRef.current?.expand();
  };
  return (
    <GestureHandlerRootView style={styles.container}>
      <BottomSheetModalProvider>
        <Blocks showBottomShet={openBottonSheet} />
        <BottomSheetNewBlock ref={bottomSheetRef} />
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