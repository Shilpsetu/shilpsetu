/// Represents an authenticated artisan profile on Shilpsetu.
class ArtisanUser {
  const ArtisanUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.craftType,
    this.location,
    this.isRegistered = true,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final String? craftType;
  final String? location;
  final bool isRegistered;

  ArtisanUser copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? craftType,
    String? location,
    bool? isRegistered,
  }) {
    return ArtisanUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      craftType: craftType ?? this.craftType,
      location: location ?? this.location,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
