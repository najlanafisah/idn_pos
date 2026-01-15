class Product {
  final String name;
  final int price;
  // Ini bisa kalo mau nambagin gambar pake final string image;

  Product({required this.name, required this.price});
}

final List<Product> menus = [
  Product(name: 'Nasi Goreng', price: 200000),
  Product(name: "Ayam Bakar", price: 220000),
  Product(name: "Sate Ayam", price: 300000),
  Product(name: "Mie Aceh", price: 180000),
  Product(name: "Es Teh", price: 36000),
  Product(name: "Es Jeruk", price: 75000),
  Product(name: "Americano", price: 80000),
  Product(name: "Air Mineral", price: 40000),
];