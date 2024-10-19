import { StyleSheet, FlatList, RefreshControl } from "react-native";
import { BlockCard } from "./BlockCard";

export interface BlockType {
  id: string;
  title: string;
  subtitle: string;
  apps: number;
  enable: boolean;
}

interface ListBlocksProps {
  blocks: Array<BlockType>;
  refreshBlocks: () => void;
  isLoading: boolean;
  editBlock: (id: string) => void;
}

export const ListBlocks = (_props: ListBlocksProps) => {

  const { blocks, refreshBlocks, isLoading, editBlock } = _props;

  return (
    <FlatList refreshControl={
      <RefreshControl
        refreshing={isLoading}
        onRefresh={refreshBlocks}
      />
    } style={styles.container} data={blocks} renderItem={({item}) => <BlockCard editBlock={(key) => editBlock(key)} refreshBlocks={refreshBlocks} {...item} />} keyExtractor={item => item.id}></FlatList>
  )
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 20,
    paddingTop: 20,
    gap: 15
  }
});