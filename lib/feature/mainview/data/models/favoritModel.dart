class Favoritmodel {
    final String product_id;
  final String user_id;
final bool isfavorite;
  Favoritmodel({
    required this.user_id,
    required this.product_id,
    required this.isfavorite,
  });

  factory Favoritmodel.fromJson(Map<String, dynamic> json) => Favoritmodel(
    user_id: json['user_id'],
    product_id: json['product_id'],
    isfavorite: json['isfavorite'],
  );

  
}
