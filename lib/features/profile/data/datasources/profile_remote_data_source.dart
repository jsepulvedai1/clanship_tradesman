import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_mobile_tradesman/features/home/domain/entities/user_entity.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/datasources/auth_remote_data_source.dart';

abstract class ProfileRemoteDataSource {
  Future<UserEntity> getMyProfile();
  Future<UserEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarBase64,
  });
  Future<UserEntity> updateAvailability({required bool isAvailable, bool? isEmergency});
  Future<UserEntity> updateProfessionalProfile({
    String? bio,
    double? hourlyRate,
    int? serviceRadius,
    String? facebookUrl,
    String? instagramUrl,
    String? tiktokUrl,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tagIds,
    String? specialtyId,
    List<String>? specialtyIds,
    List<String>? subtagIds,
  });
  Future<List<Map<String, dynamic>>> getSpecialties();
  Future<UserEntity> addPortfolioPhoto({
    required String imageBase64,
  });
  Future<UserEntity> deletePortfolioPhoto({
    required String photoId,
  });
  Future<List<Map<String, dynamic>>> getTags();
  Future<UserEntity> addProfessionalDocument({
    required String name,
    required String fileBase64,
  });
  Future<UserEntity> toggleDocumentVisibility({
    required String documentId,
    required bool isVisible,
  });
  Future<UserEntity> deleteProfessionalDocument({
    required String documentId,
  });
  Future<List<SubscriptionPlanEntity>> getSubscriptionPlans();
  Future<UserEntity> subscribeToPlan({required String planId});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final GraphQLClient client;

  ProfileRemoteDataSourceImpl(this.client);

  static const String _userFields = r'''
    id
    username
    email
    phoneNumber
    firstName
    lastName
    userType
    avatarUrl
    isAvailable
    isEmergency
    activeJobs
    completedJobs
    scheduledJobs
    rejectedJobs
    reviewsCount
    address
    latitude
    longitude
    professionalProfile {
      bio
      rating
      hourlyRate
      serviceRadius
      facebookUrl
      instagramUrl
      tiktokUrl
      plan {
        id
        name
        description
        price
        durationDays
        monthlyRequests
        urgentRequests
        serviceCategories
        searchPosition
        featuredBadge
        rrssCampaigns
        radioBroadcast
        profileStatistics
        supportLevel
      }
      specialty {
        id
        name
        iconUrl
      }
      specialties {
        id
        name
        iconUrl
      }
      tags {
        id
        name
      }
      subtags {
        id
        name
        tag {
          id
          name
        }
      }
      photos {
        id
        imageUrl
      }
      documents {
        id
        name
        fileUrl
        isVisible
        status
        rejectionReason
      }
    }
  ''';

  static const String getMyProfileQuery = '''
    query GetMyProfile {
      me {
        $_userFields
      }
    }
  ''';

  UserEntity _mapUserEntity(Map<String, dynamic> data) {
    final profProfile = data['professionalProfile'];
    final planData = profProfile?['plan'];
    final subscriptionPlan = planData != null
        ? SubscriptionPlanEntity(
            id: planData['id']?.toString() ?? '',
            name: planData['name']?.toString() ?? '',
            description: planData['description']?.toString() ?? '',
            price: double.tryParse(planData['price']?.toString() ?? '0') ?? 0.0,
            durationDays: int.tryParse(planData['durationDays']?.toString() ?? '30') ?? 30,
            monthlyRequests: planData['monthlyRequests'] != null ? int.tryParse(planData['monthlyRequests'].toString()) : null,
            urgentRequests: planData['urgentRequests'] != null ? int.tryParse(planData['urgentRequests'].toString()) : null,
            serviceCategories: planData['serviceCategories'] != null ? int.tryParse(planData['serviceCategories'].toString()) : null,
            searchPosition: planData['searchPosition']?.toString() ?? 'Estándar',
            featuredBadge: planData['featuredBadge']?.toString(),
            rrssCampaigns: planData['rrssCampaigns']?.toString(),
            radioBroadcast: planData['radioBroadcast']?.toString(),
            profileStatistics: planData['profileStatistics']?.toString() ?? 'Básicas',
            supportLevel: planData['supportLevel']?.toString() ?? 'Estándar',
          )
        : null;

    return UserEntity(
      id: data['id']?.toString() ?? '',
      name: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phoneNumber'] ?? '',
      profileImageUrl: data['avatarUrl'],
      isAvailable: data['isAvailable'] ?? false,
      isEmergency: data['isEmergency'] ?? false,
      activeJobs: data['activeJobs'] ?? 0,
      completedJobs: data['completedJobs'] ?? 0,
      scheduledJobs: data['scheduledJobs'] ?? 0,
      rejectedJobs: data['rejectedJobs'] ?? 0,
      reviewsCount: data['reviewsCount'] ?? 0,
      biography: profProfile?['bio'] ?? '',
      rating: double.tryParse(profProfile?['rating']?.toString() ?? '0') ?? 0.0,
      hourlyRate: double.tryParse(profProfile?['hourlyRate']?.toString() ?? '0') ?? 0.0,
      serviceTags: (profProfile?['tags'] as List?)
          ?.map((t) => t['name'] as String)
          .whereType<String>()
          .toList() ?? 
          (profProfile?['specialty']?['name'] != null 
              ? [profProfile['specialty']['name']] 
              : const []),
      portfolioPhotos: (profProfile?['photos'] as List?)
          ?.map((p) => PortfolioPhotoEntity(
                id: p['id']?.toString() ?? '',
                imageUrl: p['imageUrl']?.toString() ?? '',
              ))
          .toList() ?? const [],
      documents: (profProfile?['documents'] as List?)
          ?.map((d) => ProfessionalDocumentEntity(
                id: d['id']?.toString() ?? '',
                name: d['name']?.toString() ?? '',
                fileUrl: d['fileUrl']?.toString() ?? '',
                isVisible: d['isVisible'] ?? true,
                status: d['status']?.toString() ?? 'PENDING',
                rejectionReason: d['rejectionReason']?.toString(),
              ))
          .toList() ?? const [],
      address: profProfile?['address'] ?? data['address'],
      latitude: double.tryParse(profProfile?['latitude']?.toString() ?? data['latitude']?.toString() ?? ''),
      longitude: double.tryParse(profProfile?['longitude']?.toString() ?? data['longitude']?.toString() ?? ''),
      serviceRadius: double.tryParse(profProfile?['serviceRadius']?.toString() ?? '10.0') ?? 10.0,
      facebookUrl: profProfile?['facebookUrl'] ?? '',
      instagramUrl: profProfile?['instagramUrl'] ?? '',
      tiktokUrl: profProfile?['tiktokUrl'] ?? '',
      specialtyId: profProfile?['specialty']?['id']?.toString(),
      specialtyName: profProfile?['specialty']?['name']?.toString(),
      specialtyIconUrl: profProfile?['specialty']?['iconUrl']?.toString(),
      specialties: (profProfile?['specialties'] as List?)
          ?.map((s) => {
                'id': s['id']?.toString() ?? '',
                'name': s['name']?.toString() ?? '',
                'iconUrl': s['iconUrl']?.toString() ?? '',
              })
          .toList() ?? const [],
      subtags: (profProfile?['subtags'] as List?)
          ?.map((s) => {
                'id': s['id']?.toString() ?? '',
                'name': s['name']?.toString() ?? '',
                'tag': {
                  'id': s['tag']?['id']?.toString() ?? '',
                  'name': s['tag']?['name']?.toString() ?? '',
                },
              })
          .toList() ?? const [],
      subscriptionPlan: subscriptionPlan,
      planName: subscriptionPlan?.name ?? 'Plan Base',
    );
  }

  @override
  Future<UserEntity> getMyProfile() async {
    final QueryOptions options = QueryOptions(
      document: gql(getMyProfileQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['me'];
    if (data == null) {
      throw Exception('Usuario no encontrado');
    }

    return _mapUserEntity(data);
  }

  @override
  Future<UserEntity> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarBase64,
  }) async {
    final String updateProfileMutation = '''
      mutation UpdateProfile(
        \$firstName: String!, 
        \$lastName: String!, 
        \$email: String!, 
        \$address: String, 
        \$latitude: Float, 
        \$longitude: Float, 
        \$avatarBase64: String
      ) {
        updateProfile(
          firstName: \$firstName, 
          lastName: \$lastName, 
          email: \$email, 
          address: \$address, 
          latitude: \$latitude, 
          longitude: \$longitude, 
          avatarBase64: \$avatarBase64
        ) {
          success
          user {
            $_userFields
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(updateProfileMutation),
      variables: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'avatarBase64': avatarBase64,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['updateProfile']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al actualizar el perfil');
    }

    final userData = result.data?['updateProfile']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<UserEntity> updateAvailability({required bool isAvailable, bool? isEmergency}) async {
    final String mutation = '''
      mutation UpdateAvailability(\$isAvailable: Boolean!, \$isEmergency: Boolean) {
        updateAvailability(isAvailable: \$isAvailable, isEmergency: \$isEmergency) {
          success
          user {
            $_userFields
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'isAvailable': isAvailable,
        'isEmergency': isEmergency,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['updateAvailability']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al actualizar disponibilidad');
    }

    final userData = result.data?['updateAvailability']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<UserEntity> updateProfessionalProfile({
    String? bio,
    double? hourlyRate,
    int? serviceRadius,
    String? facebookUrl,
    String? instagramUrl,
    String? tiktokUrl,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tagIds,
    String? specialtyId,
    List<String>? specialtyIds,
    List<String>? subtagIds,
  }) async {
    const String mutation = r'''
      mutation UpdateProfessionalProfile(
        $bio: String,
        $hourlyRate: Float,
        $serviceRadius: Int,
        $facebookUrl: String,
        $instagramUrl: String,
        $tiktokUrl: String,
        $address: String,
        $latitude: Float,
        $longitude: Float,
        $tagIds: [ID],
        $specialtyId: Int,
        $specialtyIds: [ID],
        $subtagIds: [ID]
      ) {
        updateProfessionalProfile(
          bio: $bio,
          hourlyRate: $hourlyRate,
          serviceRadius: $serviceRadius,
          facebookUrl: $facebookUrl,
          instagramUrl: $instagramUrl,
          tiktokUrl: $tiktokUrl,
          address: $address,
          latitude: $latitude,
          longitude: $longitude,
          tagIds: $tagIds,
          specialtyId: $specialtyId,
          specialtyIds: $specialtyIds,
          subtagIds: $subtagIds
        ) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
            userType
            avatarUrl
            isAvailable
            activeJobs
            completedJobs
            scheduledJobs
            rejectedJobs
            reviewsCount
            address
            latitude
            longitude
            professionalProfile {
              bio
              rating
              hourlyRate
              serviceRadius
              facebookUrl
              instagramUrl
              tiktokUrl
              specialty {
                id
                name
                iconUrl
              }
              specialties {
                id
                name
                iconUrl
              }
              tags {
                id
                name
              }
              subtags {
                id
                name
                tag {
                  id
                  name
                }
              }
              photos {
                id
                imageUrl
              }
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        if (bio != null) 'bio': bio,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (serviceRadius != null) 'serviceRadius': serviceRadius,
        if (facebookUrl != null) 'facebookUrl': facebookUrl,
        if (instagramUrl != null) 'instagramUrl': instagramUrl,
        if (tiktokUrl != null) 'tiktokUrl': tiktokUrl,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (tagIds != null) 'tagIds': tagIds,
        if (specialtyId != null) 'specialtyId': int.tryParse(specialtyId),
        if (specialtyIds != null) 'specialtyIds': specialtyIds,
        if (subtagIds != null) 'subtagIds': subtagIds,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['updateProfessionalProfile']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al actualizar perfil profesional');
    }

    final userData = result.data?['updateProfessionalProfile']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<UserEntity> addPortfolioPhoto({required String imageBase64}) async {
    const String mutation = r'''
      mutation AddPortfolioPhoto($imageBase64: String!) {
        addPortfolioPhoto(imageBase64: $imageBase64) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
            userType
            avatarUrl
            isAvailable
            activeJobs
            completedJobs
            scheduledJobs
            rejectedJobs
            reviewsCount
            address
            latitude
            longitude
            professionalProfile {
              bio
              rating
              hourlyRate
              serviceRadius
              facebookUrl
              instagramUrl
              tiktokUrl
              specialty {
                name
              }
              tags {
                id
                name
              }
              photos {
                id
                imageUrl
              }
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'imageBase64': imageBase64,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['addPortfolioPhoto']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al subir foto de portafolio');
    }

    final userData = result.data?['addPortfolioPhoto']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<UserEntity> deletePortfolioPhoto({required String photoId}) async {
    const String mutation = r'''
      mutation DeletePortfolioPhoto($photoId: ID!) {
        deletePortfolioPhoto(photoId: $photoId) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
            userType
            avatarUrl
            isAvailable
            activeJobs
            completedJobs
            scheduledJobs
            rejectedJobs
            reviewsCount
            address
            latitude
            longitude
            professionalProfile {
              bio
              rating
              hourlyRate
              serviceRadius
              facebookUrl
              instagramUrl
              tiktokUrl
              specialty {
                name
              }
              tags {
                id
                name
              }
              photos {
                id
                imageUrl
              }
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'photoId': photoId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['deletePortfolioPhoto']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al eliminar foto de portafolio');
    }

    final userData = result.data?['deletePortfolioPhoto']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<List<Map<String, dynamic>>> getTags() async {
    const String query = r'''
      query GetTags {
        tags {
          id
          name
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final tagsList = result.data?['tags'] as List?;
    if (tagsList == null) {
      return [];
    }

    return tagsList.map((t) => Map<String, dynamic>.from(t)).toList();
  }

  @override
  Future<UserEntity> addProfessionalDocument({
    required String name,
    required String fileBase64,
  }) async {
    const String mutation = r'''
      mutation AddProfessionalDocument($name: String!, $fileBase64: String!) {
        addProfessionalDocument(name: $name, fileBase64: $fileBase64) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
            userType
            avatarUrl
            isAvailable
            activeJobs
            completedJobs
            scheduledJobs
            rejectedJobs
            reviewsCount
            address
            latitude
            longitude
            professionalProfile {
              bio
              rating
              hourlyRate
              serviceRadius
              facebookUrl
              instagramUrl
              tiktokUrl
              specialty {
                name
              }
              tags {
                id
                name
              }
              photos {
                id
                imageUrl
              }
              documents {
                id
                name
                fileUrl
                isVisible
                status
                rejectionReason
              }
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'name': name,
        'fileBase64': fileBase64,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['addProfessionalDocument']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al añadir documento');
    }

    final userData = result.data?['addProfessionalDocument']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<UserEntity> toggleDocumentVisibility({
    required String documentId,
    required bool isVisible,
  }) async {
    const String mutation = r'''
      mutation ToggleDocumentVisibility($documentId: ID!, $isVisible: Boolean!) {
        toggleDocumentVisibility(documentId: $documentId, isVisible: $isVisible) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
            userType
            avatarUrl
            isAvailable
            activeJobs
            completedJobs
            scheduledJobs
            rejectedJobs
            reviewsCount
            address
            latitude
            longitude
            professionalProfile {
              bio
              rating
              hourlyRate
              serviceRadius
              facebookUrl
              instagramUrl
              tiktokUrl
              specialty {
                name
              }
              tags {
                id
                name
              }
              photos {
                id
                imageUrl
              }
              documents {
                id
                name
                fileUrl
                isVisible
                status
                rejectionReason
              }
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'documentId': documentId,
        'isVisible': isVisible,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['toggleDocumentVisibility']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al cambiar visibilidad');
    }

    final userData = result.data?['toggleDocumentVisibility']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<UserEntity> deleteProfessionalDocument({
    required String documentId,
  }) async {
    const String mutation = r'''
      mutation DeleteProfessionalDocument($documentId: ID!) {
        deleteProfessionalDocument(documentId: $documentId) {
          success
          user {
            id
            username
            email
            phoneNumber
            firstName
            lastName
            userType
            avatarUrl
            isAvailable
            activeJobs
            completedJobs
            scheduledJobs
            rejectedJobs
            reviewsCount
            address
            latitude
            longitude
            professionalProfile {
              bio
              rating
              hourlyRate
              serviceRadius
              facebookUrl
              instagramUrl
              tiktokUrl
              specialty {
                name
              }
              tags {
                id
                name
              }
              photos {
                id
                imageUrl
              }
              documents {
                id
                name
                fileUrl
                isVisible
                status
                rejectionReason
              }
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'documentId': documentId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['deleteProfessionalDocument']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al eliminar documento');
    }

    final userData = result.data?['deleteProfessionalDocument']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el usuario actualizado');
    }

    return _mapUserEntity(userData);
  }

  @override
  Future<List<Map<String, dynamic>>> getSpecialties() async {
    const String query = r'''
      query GetSpecialties {
        maxSpecialtiesPerTradesman
        specialties {
          id
          name
          iconUrl
          tags {
            id
            name
            subtags {
              id
              name
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final maxLimit = result.data?['maxSpecialtiesPerTradesman'] as int?;
    if (maxLimit != null) {
      AuthRemoteDataSourceImpl.maxSpecialtiesLimit = maxLimit;
    }

    final List<dynamic> list = result.data?['specialties'] ?? [];
    return list.map((s) => s as Map<String, dynamic>).toList();
  }

  @override
  Future<List<SubscriptionPlanEntity>> getSubscriptionPlans() async {
    const String query = r'''
      query GetSubscriptionPlans {
        subscriptionPlans {
          id
          name
          description
          price
          durationDays
          monthlyRequests
          urgentRequests
          serviceCategories
          searchPosition
          featuredBadge
          rrssCampaigns
          radioBroadcast
          profileStatistics
          supportLevel
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final plansList = result.data?['subscriptionPlans'] as List?;
    if (plansList == null) {
      return [];
    }

    return plansList.map((p) => SubscriptionPlanEntity(
      id: p['id']?.toString() ?? '',
      name: p['name']?.toString() ?? '',
      description: p['description']?.toString() ?? '',
      price: double.tryParse(p['price']?.toString() ?? '0') ?? 0.0,
      durationDays: int.tryParse(p['durationDays']?.toString() ?? '30') ?? 30,
      monthlyRequests: p['monthlyRequests'] != null ? int.tryParse(p['monthlyRequests'].toString()) : null,
      urgentRequests: p['urgentRequests'] != null ? int.tryParse(p['urgentRequests'].toString()) : null,
      serviceCategories: p['serviceCategories'] != null ? int.tryParse(p['serviceCategories'].toString()) : null,
      searchPosition: p['searchPosition']?.toString() ?? 'Estándar',
      featuredBadge: p['featuredBadge']?.toString(),
      rrssCampaigns: p['rrssCampaigns']?.toString(),
      radioBroadcast: p['radioBroadcast']?.toString(),
      profileStatistics: p['profileStatistics']?.toString() ?? 'Básicas',
      supportLevel: p['supportLevel']?.toString() ?? 'Estándar',
    )).toList();
  }

  @override
  Future<UserEntity> subscribeToPlan({required String planId}) async {
    final String mutation = '''
      mutation SubscribeToPlan(\$planId: ID!) {
        subscribeToPlan(planId: \$planId) {
          success
          profile {
            user {
              $_userFields
            }
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'planId': planId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['subscribeToPlan']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('Error al suscribir al plan');
    }

    final userData = result.data?['subscribeToPlan']?['profile']?['user'];
    if (userData == null) {
      throw Exception('Error al obtener el perfil de usuario actualizado');
    }

    return _mapUserEntity(userData);
  }
}
