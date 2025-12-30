class Usermodel {
  final String email, name, id, image, phone;
  Usermodel({
    required this.email,
    required this.name,
    required this.id,
    required this.image,
    required this.phone,
  });

  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(
      image: json["image"],
      name: json['name'],
      email: json['email'],
      id: json['uid'],
      phone: json['phone']??"",
    );
  }
  Map<String, dynamic> toJson() => {
    'uid': id,
    'email': email,
    'name': name,
    "image": image,
    'phone': phone,
  };
}
