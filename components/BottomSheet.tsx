import React, { forwardRef, useCallback } from 'react';
import { StyleSheet } from 'react-native';
import BottomSheet, { BottomSheetScrollView, BottomSheetBackdrop } from "@gorhom/bottom-sheet";
import { OptionsConfigNewBlock } from './OptionsConfigNewBlock';
import { FormNewBlock } from './FormNewBlock';
import { FormNewLimit } from './FormNewLimit';
import { BottomSheetDefaultBackdropProps } from '@gorhom/bottom-sheet/lib/typescript/components/bottomSheetBackdrop/types';

interface BottomSheetNewBlockProps {
  refreshBlocks: () => void;
  refreshLimits: () => void;
  onBottomSheetClosed: () => void;
  bottomSheetForm?: string;
  setBottomSheetForm: (form: string) => void;
  isEdit?: boolean;
  blockId?: string | null;
  limitId?: string | null;
  isEmptyBlock?: boolean;
  isEmptyLimit?: boolean;
  updateEmptyBlock?: (isEmpty: boolean) => void;
  updateEmptyLimit?: (isEmpty: boolean) => void;
  totalBlocks?: number;
  totalLimits?: number;
}

export const BottomSheetBlockAndLimit = forwardRef<BottomSheet, BottomSheetNewBlockProps>((_props, ref) => {

  const { refreshBlocks, refreshLimits, onBottomSheetClosed, bottomSheetForm, setBottomSheetForm, isEdit, blockId, limitId, isEmptyBlock, isEmptyLimit, updateEmptyBlock, updateEmptyLimit, totalBlocks = 0, totalLimits = 0 } = _props

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
      return <FormNewBlock totalBlocks={totalBlocks} updateEmptyBlock={updateEmptyBlock} isEmptyBlock={isEmptyBlock} blockId={blockId} isEdit={isEdit} closeBottomSheet={closeBottomSheet} refreshBlocks={refreshBlocks} changeForm={setBottomSheetForm} />;
    } else if (bottomSheetForm === 'new-limit') {
      return <FormNewLimit totalLimits={totalLimits} updateEmptyLimit={updateEmptyLimit} isEmptyLimit={isEmptyLimit} limitId={limitId} isEdit={isEdit} closeBottomSheet={closeBottomSheet} refreshLimits={refreshLimits} changeForm={setBottomSheetForm} />;
    }

    return <OptionsConfigNewBlock totalBlocks={totalBlocks} changeForm={setBottomSheetForm} />;
  };

  const closeBottomSheet = () => {
    if (ref && 'current' in ref && ref.current) {
      ref.current.close();
      updateEmptyBlock && updateEmptyBlock(true);
    }
  };

  const handleOnChange = (index: number) => {
    if (index === -1) {
      onBottomSheetClosed();
    }
  };

  return (
    <BottomSheet
      ref={ref}
      backdropComponent={renderBackdrop}
      index={-1}
      enablePanDownToClose={true}
      enableDynamicSizing={true}
      onChange={handleOnChange}
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
