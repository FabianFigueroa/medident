class DentistProfileModel {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String address;
  final String phone;
  final String email;
 
  DentistProfileModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.address,
    required this.phone,
    required this.email,
  });
}
