import 'package:shop_app/feature/mainview/domain/entities/productEntity.dart';

ProductEntity getDummyProduct() {
  return ProductEntity(
    id: "1",
    title: "title",
    reviews: [],
    price: 11,
    category: "11111",
    favorites: [],
    description: "description",
    image: "https://mcprod.hyperone.com.eg/media/catalog/product/cache/8d4e6327d79fd11192282459179cc69e/2/3/2394293000006.jpg",
    quantity: 11,
  );
}

List<ProductEntity> getDummyProducts() {
  return [
    getDummyProduct(),
    getDummyProduct(),
    getDummyProduct(),
    getDummyProduct(),
    getDummyProduct(),
    getDummyProduct(),
  ];
}
