import React, { forwardRef, useCallback, useEffect, useMemo, useRef } from 'react';
import { Text, StyleSheet, View } from 'react-native';
import BottomSheet, { BottomSheetView, BottomSheetModal, BottomSheetBackdrop } from "@gorhom/bottom-sheet";
import { OptionsConfigNewBlock } from './OptionsConfigNewBlock';
import { BottomSheetDefaultBackdropProps } from '@gorhom/bottom-sheet/lib/typescript/components/bottomSheetBackdrop/types';


export const BottomSheetNewBlock = forwardRef<BottomSheet, {}>((_props, ref) => {

  const snapPoints = useMemo(() => ['25%', '50%'], []);
  
  const renderBackdrop = useCallback(
		(props: React.JSX.IntrinsicAttributes & BottomSheetDefaultBackdropProps) => (
			<BottomSheetBackdrop
				{...props}
				disappearsOnIndex={-1}
				appearsOnIndex={0}
			/>
		),
		[]
	);

  return (
    <BottomSheet
      ref={ref}
      snapPoints={snapPoints}
      backdropComponent={renderBackdrop}
      index={-1}
      enablePanDownToClose={true}
    >
      <BottomSheetView style={styles.contentContainer}>
        <OptionsConfigNewBlock />
      </BottomSheetView>
    </BottomSheet>
  );
});

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
