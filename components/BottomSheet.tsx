import React, { forwardRef, useCallback, useMemo, useState } from 'react';
import { StyleSheet } from 'react-native';
import BottomSheet, { BottomSheetScrollView, BottomSheetBackdrop } from "@gorhom/bottom-sheet";
import { OptionsConfigNewBlock } from './OptionsConfigNewBlock';
import { FormNewBlock } from './FormNewBlock';
import { BottomSheetDefaultBackdropProps } from '@gorhom/bottom-sheet/lib/typescript/components/bottomSheetBackdrop/types';

interface BottomSheetNewBlockProps {
  refreshBlocks: () => void;
}

export const BottomSheetNewBlock = forwardRef<BottomSheet, BottomSheetNewBlockProps>((_props, ref) => {

  const { refreshBlocks } = _props

  const [bottomSheetForm, setBottomSheetForm] = useState<string>('');

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

  const renderBottomSheetContent = () => {
    if (bottomSheetForm === 'new-block') {
      return <FormNewBlock closeBottomSheet={closeBottomSheet} refreshBlocks={refreshBlocks} changeForm={setBottomSheetForm} />;
    }

    return <OptionsConfigNewBlock changeForm={setBottomSheetForm} />;
  };

  const closeBottomSheet = () => {
    if (ref && 'current' in ref && ref.current) {
      ref.current.close();
    }
  };
  return (
    <BottomSheet
      ref={ref}
      backdropComponent={renderBackdrop}
      index={-1}
      enablePanDownToClose={true}
      enableDynamicSizing={true}
    >
      <BottomSheetScrollView style={styles.contentContainer}>
        {renderBottomSheetContent()}
      </BottomSheetScrollView>
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
    paddingHorizontal: 20,
    marginTop: 10
  },
});
