import 'package:web3dart/web3dart.dart';

extension BlockEstimator on Web3Client {
  Future<int> getBlockNumberByDate(DateTime expected) async {
    var rightBlockNumber = await getBlockNumber();
    var rightBlock =
        await getBlockInformation(blockNumber: "0x${rightBlockNumber.toRadixString(16)}");
    var leftBlockNumber = 0;
    var leftBlock =
        await getBlockInformation(blockNumber: "0x${leftBlockNumber.toRadixString(16)}");

    if (expected.isBefore(leftBlock.timestamp) ||
        expected.isAtSameMomentAs(leftBlock.timestamp)) {
      return leftBlockNumber;
    }

    if (expected.isAfter(rightBlock.timestamp) ||
        expected.isAtSameMomentAs(rightBlock.timestamp)) {
      return rightBlockNumber;
    }

    while (true) {
      var centerBlockNumber = (leftBlockNumber + rightBlockNumber) ~/ 2;
      var centerBlock =
          await getBlockInformation(blockNumber: "0x${centerBlockNumber.toRadixString(16)}");
      if (expected.isAtSameMomentAs(centerBlock.timestamp)) {
        return centerBlockNumber;
      } else if (expected.isBefore(centerBlock.timestamp)) {
        rightBlockNumber = centerBlockNumber;
        rightBlock = centerBlock;
      } else {
        leftBlockNumber = centerBlockNumber;
        leftBlock = centerBlock;
      }

      if (rightBlockNumber - leftBlockNumber <= 1) {
        if (rightBlock.timestamp.difference(expected) <
            expected.difference(leftBlock.timestamp)) {
          return rightBlockNumber;
        } else {
          return leftBlockNumber;
        }
      }
    }
  }
}
