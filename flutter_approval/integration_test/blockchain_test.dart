import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_approval/seeker/seeker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('blockchain rpc test', () {
    test('blocknumber estimation zero', () async {
      var ethereum = Chain.ethereum;
      var seeker = Seeker.createFromRpc(await ethereum.randomRpc());
      var estimatedZero = await seeker.getBlockNumberByDate(DateTime.utc(1970));
      expect(0, estimatedZero);
    });

    test('blocknumber estimation fixed', () async {
      var ethereum = Chain.ethereum;
      var seeker = Seeker.createFromRpc(await ethereum.randomRpc());
      var estimatedFixed = await seeker
          .getBlockNumberByDate(DateTime.utc(2016, 2, 13, 22, 54, 13));
      expect(1000000, estimatedFixed);
    });
  });
}
