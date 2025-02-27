import React, { forwardRef, useCallback, useRef } from 'react';
import { StyleSheet } from 'react-native';
import BottomSheet, { BottomSheetScrollView, BottomSheetBackdrop } from "@gorhom/bottom-sheet";
import { OptionsConfigNewBlock } from './OptionsConfigNewBlock';
import { FormNewBlock, FormNewBlockRef } from './FormNewBlock';
import { FormNewLimit } from './FormNewLimit';
import { BottomSheetDefaultBackdropProps } from '@gorhom/bottom-sheet/lib/typescript/components/bottomSheetBackdrop/types';
import { FormNewLimitRef } from './FormNewLimit/FormNewLimit';
import { heightPercentageToDP as hp } from 'react-native-responsive-screen';

interface BottomSheetNewBlockProps {
  refreshBlocks?: () => void;
  refreshLimits?: () => void;
  onBottomSheetClosed?: () => void;
  bottomSheetForm?: string;
  setBottomSheetForm?: (form: string) => void;
  isEdit?: boolean;
  blockId?: string | null;
  limitId?: string | null;
  isEmptyBlock?: boolean;
  isEmptyLimit?: boolean;
  updateEmptyBlock?: (isEmpty: boolean) => void;
  updateEmptyLimit?: (isEmpty: boolean) => void;
  totalBlocks?: number;
  totalLimits?: number;
  enableImpulseConfig?: boolean;
}

export const BottomSheetBlockAndLimit = forwardRef<BottomSheet, BottomSheetNewBlockProps>((_props, ref) => {

  const {
    refreshBlocks,
    refreshLimits,
    onBottomSheetClosed,
    bottomSheetForm,
    setBottomSheetForm,
    isEdit,
    blockId,
    limitId,
    isEmptyBlock,
    isEmptyLimit,
    updateEmptyBlock,
    updateEmptyLimit,
    totalBlocks = 0,
    totalLimits = 0,
    enableImpulseConfig = false
  } = _props;

  const formNewBlockRef = useRef<FormNewBlockRef>(null);
  const formNewLimitRef = useRef<FormNewLimitRef>(null);
  
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
      return (
        <FormNewBlock
          ref={formNewBlockRef}
          totalBlocks={totalBlocks}
          updateEmptyBlock={updateEmptyBlock}
          isEmptyBlock={isEmptyBlock}
          blockId={blockId}
          isEdit={isEdit}
          closeBottomSheet={closeBottomSheet}
          refreshBlocks={refreshBlocks}
          changeForm={setBottomSheetForm}
        />
      );
    } else if (bottomSheetForm === 'new-limit') {
      return (
        <FormNewLimit
          enableImpulseConfig={enableImpulseConfig}
          ref={formNewLimitRef}
          totalLimits={totalLimits}
          updateEmptyLimit={updateEmptyLimit}
          isEmptyLimit={isEmptyLimit}
          limitId={limitId}
          isEdit={isEdit}
          closeBottomSheet={closeBottomSheet}
          refreshLimits={refreshLimits}
          changeForm={setBottomSheetForm}
        />
      );
    }

    return <OptionsConfigNewBlock totalBlocks={totalBlocks} changeForm={setBottomSheetForm} />;
  };

  const closeBottomSheet = () => {
    if (ref && 'current' in ref && ref.current) {
      ref.current.close();
      formNewBlockRef.current?.clearForm();
      formNewLimitRef.current?.clearForm();
      updateEmptyBlock && updateEmptyBlock(true);
    }
  };

  const handleOnChange = (index: number) => {
    if (index === -1) {
      formNewBlockRef.current?.clearForm();
      formNewLimitRef.current?.clearForm();
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
      maxDynamicContentSize={hp('75%')}
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
    height: '80%',
  },
  contentContainer: {
    paddingHorizontal: 20,
    marginTop: 10,
    height: '80%',
  },
});
