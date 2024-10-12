import { View, StyleSheet } from "react-native";
import { BlockCard } from "./BlockCard";

export interface BlockType {
  id: string;
  title: string;
  subtitle: string;
  apps: number;
}

interface ListBlocksProps {
  blocks: Array<BlockType>;
  refreshBlocks: () => void;
}

export const ListBlocks = (_props: ListBlocksProps) => {

  const { blocks, refreshBlocks } = _props;

  return (
    <View style={styles.container}>
      {
        blocks.map(block => (
          <BlockCard refreshBlocks={refreshBlocks} {...block} key={block.id} />
        ))
      }
    </View>
  )
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 20,
    marginTop: 20,
    gap: 15
  }
});