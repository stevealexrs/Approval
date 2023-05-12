import 'package:web3dart/web3dart.dart';

EthereumAddress topicToAddress(String topic) {
  return EthereumAddress.fromHex(topic.substring(26));
}
