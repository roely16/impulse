import { StyleSheet, FlatList, RefreshControl } from "react-native";
import { BlockCard } from "./BlockCard";
import { heightPercentageToDP as hp } from "react-native-responsive-screen";

export interface BlockType {
  id: string;
  title: string;
  subtitle: string;
  apps: number;
  enable: boolean;
  weekdays: number[];
}

interface ListBlocksProps {
  blocks: Array<BlockType>;
  refreshBlocks: () => void;
  isLoading: boolean;
  editBlock: (id: string) => void;
}

export const ListBlocks = (_props: ListBlocksProps) => {

  const { blocks, refreshBlocks, isLoading, editBlock } = _props;

  const getBlocksActiveAndInactive = (): { active: number, inactive: number } => {
    const active = blocks.filter((block) => block.enable).length;
    const inactive = blocks.filter((block) => !block.enable).length;

    return {
      active,
      inactive
    }
  }

  const totalOfBlocks = getBlocksActiveAndInactive();

  return (
    <FlatList refreshControl={
      <RefreshControl
        refreshing={isLoading}
        onRefresh={refreshBlocks}
      />
    } style={styles.container} data={blocks} renderItem={({item}) => <BlockCard total_blocks={blocks.length} total_active_limits={totalOfBlocks.active} total_inactive_limits={totalOfBlocks.inactive} editBlock={(key) => editBlock(key)} refreshBlocks={refreshBlocks} {...item} />} keyExtractor={item => item.id}></FlatList>
  )
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 20,
    paddingTop: hp('0.2%'),
    gap: 15
  }
});