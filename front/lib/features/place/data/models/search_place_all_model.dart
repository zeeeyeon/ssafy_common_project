import 'package:big_decimal/big_decimal.dart';

class SearchPlaceAllModel {
  final String keyword;
  final BigDecimal latitude;
  final BigDecimal longitude;

  SearchPlaceAllModel({
    required this.keyword,
    required this.latitude,
    required this.longitude,
  });
}