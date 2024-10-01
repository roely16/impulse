import { useCallback, useRef } from 'react';
import { View, StyleSheet } from 'react-native';
import { Text } from 'react-native-paper';
import { Blocks } from '@/components/Blocks';
import { BottomSheetNewBlock } from '@/components/BottomSheet';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { Link } from 'expo-router';

export default function HomeScreen() {
  const handleSheetChanges = useCallback((index: number) => {
    console.log('handleSheetChanges', index);
  }, []);
  return (
    <GestureHandlerRootView style={styles.container}>
      <Blocks />
      <BottomSheetNewBlock />
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1
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