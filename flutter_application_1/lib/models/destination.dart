class Destination {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final int price;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.price,
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['image_url'],
      location: map['location'],
      price: map['price'],
    );
  }
}
