import { StyleSheet, FlatList } from "react-native";
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
}

export const ListBlocks = (_props: ListBlocksProps) => {

  const { blocks, refreshBlocks } = _props;

  return (
    <FlatList style={styles.container} data={blocks} renderItem={({item}) => <BlockCard refreshBlocks={refreshBlocks} {...item} />} keyExtractor={item => item.id}></FlatList>
  )
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 20,
    paddingTop: 20,
    gap: 15
  }
});