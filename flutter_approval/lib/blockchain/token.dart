import 'package:web3dart/web3dart.dart';

enum TokenType { erc20, erc721, erc777, erc1155 }

class Token {
  final EthereumAddress tokenAddress;
  final TokenType type;

  Token(this.tokenAddress, this.type);
}

class TokenWithMetadata extends Token {
  TokenWithMetadata(this.symbol, TokenType type, EthereumAddress tokenAddress)
      : super(tokenAddress, type);

  final String symbol;
}

class Erc20Token extends TokenWithMetadata {
  Erc20Token(super.symbol, super.type, super.tokenAddress, this.decimal);
  final BigInt decimal;
}
