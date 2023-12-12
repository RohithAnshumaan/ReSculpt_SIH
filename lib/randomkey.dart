import 'package:resculpt/keyclass.dart';
import 'dart:math';

randomIdGenerator() {
  var ranAssets = RanKeyAssets();
  String first4alphabets = '';
  String middle4Digits = '';
  String last4alphabets = '';
  for (int i = 0; i < 4; i++) {
    first4alphabets += ranAssets.smallAlphabets[
        Random.secure().nextInt(ranAssets.smallAlphabets.length)];

    middle4Digits +=
        ranAssets.digits[Random.secure().nextInt(ranAssets.digits.length)];

    last4alphabets += ranAssets.smallAlphabets[
        Random.secure().nextInt(ranAssets.smallAlphabets.length)];
  }

  return '$first4alphabets-$middle4Digits-${DateTime.now().microsecondsSinceEpoch.toString().substring(8, 12)}-$last4alphabets';
}
