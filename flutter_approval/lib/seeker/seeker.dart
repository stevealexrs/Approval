import 'package:flutter_approval/blockchain/chain.dart';
import 'package:flutter_approval/seeker/erc1155_seeker.dart';
import 'package:flutter_approval/seeker/erc20_seeker.dart';
import 'package:flutter_approval/seeker/erc721_seeker.dart';
import 'package:flutter_approval/seeker/erc777_seeker.dart';
import 'package:flutter_approval/blockchain/web3_extension.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Seeker {
  Web3Client web3Client;
  Erc20Seeker erc20Seeker;
  Erc721Seeker erc721seeker;
  Erc777Seeker erc777seeker;
  Erc1155Seeker erc1155seeker;
  Seeker._create(this.web3Client, this.erc20Seeker, this.erc721seeker,
      this.erc777seeker, this.erc1155seeker);

  static Future<Seeker> create(Chain chain) async {
    return Seeker.createFromRpc(await chain.randomRpc());
  }

  factory Seeker.createFromRpc(String rpcUrl) {
    var httpClient = Client();
    var web3Client = Web3Client(rpcUrl, httpClient);
    return Seeker._create(
        web3Client,
        Erc20Seeker(web3Client),
        Erc721Seeker(web3Client),
        Erc777Seeker(web3Client),
        Erc1155Seeker(web3Client));
  }

  Future<int> getBlockNumberByDate(DateTime expected) {
    return web3Client.getBlockNumberByDate(expected);
  }
}
