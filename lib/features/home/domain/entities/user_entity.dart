import 'package:equatable/equatable.dart';

class PortfolioPhotoEntity extends Equatable {
  final String id;
  final String imageUrl;

  const PortfolioPhotoEntity({
    required this.id,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, imageUrl];
}

class ProfessionalDocumentEntity extends Equatable {
  final String id;
  final String name;
  final String fileUrl;
  final bool isVisible;
  final String status;
  final String? rejectionReason;

  const ProfessionalDocumentEntity({
    required this.id,
    required this.name,
    required this.fileUrl,
    required this.isVisible,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [id, name, fileUrl, isVisible, status, rejectionReason];
}

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
  });

  @override
  List<Object?> get props => [id, name, description, price, durationDays];
}

class UserEntity extends Equatable {
  final String id;
  final String name; // Keeping as a computed full name or just username
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final double rating;
  final int reviewsCount;
  final int activeJobs;
  final int completedJobs;
  final int rejectedJobs;
  final int scheduledJobs;
  final bool isAvailable;
  final String biography;
  final String planName;
  final int daysRemaining;
  final SubscriptionPlanEntity? subscriptionPlan;
  final List<String> serviceTags;
  final List<PortfolioPhotoEntity> portfolioPhotos;
  final List<ProfessionalDocumentEntity> documents;
  final double hourlyRate;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double serviceRadius;
  final String facebookUrl;
  final String instagramUrl;
  final String tiktokUrl;
  final String? specialtyId;
  final String? specialtyName;
  final String? specialtyIconUrl;
  final List<Map<String, dynamic>> specialties;

  const UserEntity({
    required this.id,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.profileImageUrl,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.activeJobs = 0,
    this.completedJobs = 0,
    this.rejectedJobs = 0,
    this.scheduledJobs = 0,
    this.isAvailable = true,
    this.biography = '',
    this.planName = 'Básico',
    this.daysRemaining = 0,
    this.subscriptionPlan,
    this.serviceTags = const [],
    this.portfolioPhotos = const [],
    this.documents = const [],
    this.hourlyRate = 0.0,
    this.address,
    this.latitude,
    this.longitude,
    this.serviceRadius = 10.0,
    this.facebookUrl = '',
    this.instagramUrl = '',
    this.tiktokUrl = '',
    this.specialtyId,
    this.specialtyName,
    this.specialtyIconUrl,
    this.specialties = const [],
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImageUrl,
    double? rating,
    int? reviewsCount,
    int? activeJobs,
    int? completedJobs,
    int? rejectedJobs,
    int? scheduledJobs,
    bool? isAvailable,
    String? biography,
    String? planName,
    int? daysRemaining,
    SubscriptionPlanEntity? subscriptionPlan,
    List<String>? serviceTags,
    List<PortfolioPhotoEntity>? portfolioPhotos,
    List<ProfessionalDocumentEntity>? documents,
    double? hourlyRate,
    String? address,
    double? latitude,
    double? longitude,
    double? serviceRadius,
    String? facebookUrl,
    String? instagramUrl,
    String? tiktokUrl,
    String? specialtyId,
    String? specialtyName,
    String? specialtyIconUrl,
    List<Map<String, dynamic>>? specialties,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      rejectedJobs: rejectedJobs ?? this.rejectedJobs,
      scheduledJobs: scheduledJobs ?? this.scheduledJobs,
      isAvailable: isAvailable ?? this.isAvailable,
      biography: biography ?? this.biography,
      planName: planName ?? this.planName,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      serviceTags: serviceTags ?? this.serviceTags,
      portfolioPhotos: portfolioPhotos ?? this.portfolioPhotos,
      documents: documents ?? this.documents,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      specialtyId: specialtyId ?? this.specialtyId,
      specialtyName: specialtyName ?? this.specialtyName,
      specialtyIconUrl: specialtyIconUrl ?? this.specialtyIconUrl,
      specialties: specialties ?? this.specialties,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        firstName,
        lastName,
        email,
        phone,
        profileImageUrl,
        rating,
        reviewsCount,
        activeJobs,
        completedJobs,
        rejectedJobs,
        scheduledJobs,
        isAvailable,
        biography,
        planName,
        daysRemaining,
        subscriptionPlan,
        serviceTags,
        portfolioPhotos,
        documents,
        hourlyRate,
        address,
        latitude,
        longitude,
        serviceRadius,
        facebookUrl,
        instagramUrl,
        tiktokUrl,
        specialtyId,
        specialtyName,
        specialtyIconUrl,
        specialties,
      ];
}
