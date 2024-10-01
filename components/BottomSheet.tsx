import React, { useCallback, useMemo, useRef } from 'react';
import { Text, StyleSheet } from 'react-native';
import BottomSheet, { BottomSheetView } from "@gorhom/bottom-sheet";
import { OptionsConfigNewBlock } from './OptionsConfigNewBlock';

export const BottomSheetNewBlock = () => {
  const snapPoints = useMemo(() => ['25%', '50%'], []);

  const bottomSheetRef = useRef<BottomSheet>(null);

  const handleSheetChanges = useCallback((index: number) => {
    console.log('handleSheetChanges', index);
  }, []);
  
  const handleOpenBottomSheet = () => {
    bottomSheetRef.current?.expand();
  };

  return (
    <BottomSheet
      ref={bottomSheetRef}
      onChange={handleSheetChanges}
      snapPoints={snapPoints}
    >
      <BottomSheetView style={styles.contentContainer}>
        <OptionsConfigNewBlock />
      </BottomSheetView>
    </BottomSheet>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 24,
    justifyContent: 'center',
    backgroundColor: 'grey',
  },
  contentContainer: {
    flex: 1,
    paddingHorizontal: 20,
    marginTop: 10
  },
});
