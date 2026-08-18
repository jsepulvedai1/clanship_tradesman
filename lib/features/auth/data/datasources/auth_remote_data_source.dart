import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/models/user_model.dart';
import 'package:clanship_mobile_tradesman/core/network/firebase_notification_helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? address,
    String? phoneNumber,
    String? avatarPath,
    String? cedulaFrontPath,
    String? cedulaBackPath,
    List<Map<String, String>>? certificates,
    double? latitude,
    double? longitude,
    List<String>? specialtyIds,
    List<String>? tagIds,
    List<String>? subtagIds,
    String? bio,
    List<String>? workPhotoPaths,
  });
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
  Future<void> sendPasswordResetEmail(String email);
  Future<List<Map<String, dynamic>>> getAvailableTags();
  Future<Map<String, bool>> checkUserExistence({String? email, String? phoneNumber});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient client;

  AuthRemoteDataSourceImpl(this.client);

  String _extractErrorMessage(OperationException? exception) {
    if (exception == null) return 'Ocurrió un error inesperado.';
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.first.message;
    }
    if (exception.linkException != null) {
      return 'Error de conexión con el servidor. Por favor verifica tu conexión a internet.';
    }
    return exception.toString();
  }

  @override
  Future<UserModel> login(String email, String password) async {
    // Clear any existing token to prevent AuthLink from sending an invalid/expired token
    // which causes 'Error decoding signature' on the server.
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'jwt_refresh_token');

    const String loginMutation = r'''
      mutation TokenAuth($username: String!, $password: String!, $appType: String) {
        tokenAuth(username: $username, password: $password, appType: $appType) {
          token
          refreshToken
        }
      }
    ''';

    const String meQuery = r'''
      query {
        me {
          id
          username
          email
          isValidated
          phoneNumber
          firstName
          lastName
          address
          latitude
          longitude
          avatarUrl
          professionalProfile {
            requiresPlanUpgrade
            isVerified
            address
            latitude
            longitude
            serviceRadius
          }
        }
      }
    ''';

    final cleanEmail = email.trim().toLowerCase();

    final MutationOptions options = MutationOptions(
      document: gql(loginMutation),
      variables: {
        'username': cleanEmail,
        'password': password,
        'appType': 'TRADESMAN',
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(_extractErrorMessage(result.exception));
    }

    final token = result.data?['tokenAuth']?['token'];
    final refreshToken = result.data?['tokenAuth']?['refreshToken'];
    
    // Save token in flutter_secure_storage so AuthLink can use it securely
    if (token != null) {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt_token', value: token);
      if (refreshToken != null) {
        await storage.write(key: 'jwt_refresh_token', value: refreshToken);
      }
    }
    
    // Proceed to fetch 'me'
    final QueryOptions meOptions = QueryOptions(
      document: gql(meQuery),
      fetchPolicy: FetchPolicy.networkOnly,
      // If needed, we can pass context here to add the Authorization header manually for this specific request
      context: Context().withEntry(
        HttpLinkHeaders(
          headers: {'Authorization': 'JWT $token'},
        ),
      ),
    );

    final QueryResult meResult = await client.query(meOptions);

    if (meResult.hasException) {
      throw Exception(_extractErrorMessage(meResult.exception));
    }


    final userData = meResult.data?['me'] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception('Could not fetch user details');
    }
    
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? address,
    String? phoneNumber,
    String? avatarPath,
    String? cedulaFrontPath,
    String? cedulaBackPath,
    List<Map<String, String>>? certificates,
    double? latitude,
    double? longitude,
    List<String>? specialtyIds,
    List<String>? tagIds,
    List<String>? subtagIds,
    String? bio,
    List<String>? workPhotoPaths,
  }) async {
    // Clear any existing token to prevent AuthLink from sending an invalid/expired token
    // which causes 'Error decoding signature' on the server.
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'jwt_refresh_token');

    const String registerMutation = r'''
      mutation RegisterUser($email: String!, $password: String!, $firstName: String!, $lastName: String!, $userType: String!) {
        registerUser(
          email: $email, 
          password: $password, 
          firstName: $firstName, 
          lastName: $lastName, 
          userType: $userType
        ) {
          success
          user {
            id
            userType
          }
        }
      }
    ''';

    final cleanEmail = email.trim().toLowerCase();

    final MutationOptions options = MutationOptions(
      document: gql(registerMutation),
      variables: {
        'email': cleanEmail,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'userType': 'PROFESSIONAL',
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(_extractErrorMessage(result.exception));
    }

    final success = result.data?['registerUser']?['success'] as bool? ?? false;
    if (!success) {
      throw Exception('El registro no pudo completarse. Intenta nuevamente.');
    }


    // After successful registration, we login the user
    final userModel = await login(cleanEmail, password);

    UserModel finalUserModel = userModel;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      finalUserModel = finalUserModel.copyWith(avatarPath: avatarPath);
    }

    final List<Future<void>> uploadFutures = [];

    // If address, phone, or avatar is provided, update the profile with simulated location
    if ((address != null && address.isNotEmpty) || 
        (phoneNumber != null && phoneNumber.isNotEmpty) || 
        (avatarPath != null && avatarPath.isNotEmpty)) {
      uploadFutures.add(() async {
        String? base64Image;
        if (avatarPath != null && avatarPath.isNotEmpty) {
          try {
            final file = File(avatarPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              base64Image = base64Encode(bytes);
            }
          } catch (e) {
            print('Error encoding avatar image: $e');
          }
        }

        // Use passed coordinates or fallback to a simulated latitude/longitude near Santiago Centro, Chile
        final double finalLat = latitude ?? (-33.4489 + (Random().nextDouble() - 0.5) * 0.1);
        final double finalLng = longitude ?? (-70.6693 + (Random().nextDouble() - 0.5) * 0.1);

        const String updateProfileMutation = r'''
          mutation UpdateProfile(
            $firstName: String!, 
            $lastName: String!, 
            $email: String!, 
            $phoneNumber: String, 
            $address: String, 
            $latitude: Float, 
            $longitude: Float, 
            $avatarBase64: String
          ) {
            updateProfile(
              firstName: $firstName, 
              lastName: $lastName, 
              email: $email, 
              phoneNumber: $phoneNumber, 
              address: $address, 
              latitude: $latitude, 
              longitude: $longitude, 
              avatarBase64: $avatarBase64
            ) {
              success
              user {
                id
                username
                email
                phoneNumber
                firstName
                lastName
                address
                latitude
                longitude
                avatarUrl
              }
            }
          }
        ''';

        final MutationOptions updateOptions = MutationOptions(
          document: gql(updateProfileMutation),
          variables: {
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'phoneNumber': phoneNumber,
            'address': address,
            'latitude': finalLat,
            'longitude': finalLng,
            'avatarBase64': base64Image,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        );

        final QueryResult updateResult = await client.mutate(updateOptions);
        if (!updateResult.hasException) {
          final updateSuccess = updateResult.data?['updateProfile']?['success'] as bool? ?? false;
          if (updateSuccess) {
            final updatedUserData = updateResult.data?['updateProfile']?['user'] as Map<String, dynamic>?;
            if (updatedUserData != null) {
              // Avatar is uploaded and saved on server
            }
          }
        }
      }());
    }

    // Upload ID Card and Certificates
    Future<void> uploadDoc(String path, String docName) async {
      try {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64File = base64Encode(bytes);

          const String addDocMutation = r'''
            mutation AddProfessionalDocument($name: String!, $fileBase64: String!) {
              addProfessionalDocument(name: $name, fileBase64: $fileBase64) {
                success
              }
            }
          ''';

          final MutationOptions docOptions = MutationOptions(
            document: gql(addDocMutation),
            variables: {
              'name': docName,
              'fileBase64': base64File,
            },
            fetchPolicy: FetchPolicy.networkOnly,
          );

          await client.mutate(docOptions);
        }
      } catch (e) {
        print('Error uploading document $docName: $e');
      }
    }

    if (cedulaFrontPath != null && cedulaFrontPath.isNotEmpty) {
      uploadFutures.add(uploadDoc(cedulaFrontPath, 'Cédula de Identidad (Frontal)'));
    }
    if (cedulaBackPath != null && cedulaBackPath.isNotEmpty) {
      uploadFutures.add(uploadDoc(cedulaBackPath, 'Cédula de Identidad (Posterior)'));
    }
    if (certificates != null && certificates.isNotEmpty) {
      for (final cert in certificates) {
        final p = cert['path'];
        final n = cert['name'];
        if (p != null && p.isNotEmpty && n != null && n.isNotEmpty) {
          uploadFutures.add(uploadDoc(p, n));
        }
      }
    }
      
    // Update specialties, tags, subtags, and bio if provided
    if ((specialtyIds != null && specialtyIds.isNotEmpty) || 
        (tagIds != null && tagIds.isNotEmpty) || 
        (subtagIds != null && subtagIds.isNotEmpty) ||
        (bio != null && bio.isNotEmpty)) {
      uploadFutures.add(() async {
        const String updateTagsMutation = r'''
          mutation UpdateProfessionalProfile($specialtyIds: [ID!], $tagIds: [ID!], $subtagIds: [ID!], $bio: String) {
            updateProfessionalProfile(specialtyIds: $specialtyIds, tagIds: $tagIds, subtagIds: $subtagIds, bio: $bio) {
              success
            }
          }
        ''';
          
        final MutationOptions updateTagsOptions = MutationOptions(
          document: gql(updateTagsMutation),
          variables: {
            'specialtyIds': specialtyIds,
            'tagIds': tagIds,
            'subtagIds': subtagIds,
            'bio': bio,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        );
          
        try {
          await client.mutate(updateTagsOptions);
        } catch (e) {
          print('Error updating professional profile info: $e');
        }
      }());
    }

    // Upload portfolio work photos if provided
    if (workPhotoPaths != null && workPhotoPaths.isNotEmpty) {
      for (final path in workPhotoPaths) {
        uploadFutures.add(() async {
          try {
            final file = File(path);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64Image = base64Encode(bytes);

              const String addPortfolioMutation = r'''
                mutation AddPortfolioPhoto($imageBase64: String!) {
                  addPortfolioPhoto(imageBase64: $imageBase64) {
                    success
                  }
                }
              ''';

              final MutationOptions options = MutationOptions(
                document: gql(addPortfolioMutation),
                variables: {'imageBase64': base64Image},
                fetchPolicy: FetchPolicy.networkOnly,
              );

              await client.mutate(options);
            }
          } catch (e) {
            print('Error uploading portfolio photo $path: $e');
          }
        }());
      }
    }

    // Await all parallel uploads
    await Future.wait(uploadFutures);

    return finalUserModel;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    const String meQuery = r'''
      query {
        me {
          id
          username
          email
          isValidated
          phoneNumber
          firstName
          lastName
          address
          latitude
          longitude
          avatarUrl
          professionalProfile {
            requiresPlanUpgrade
            isVerified
            address
            latitude
            longitude
            serviceRadius
          }
        }
      }
    ''';

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception('No saved token found');
    }

    final QueryOptions meOptions = QueryOptions(
      document: gql(meQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult meResult = await client.query(meOptions);

    if (meResult.hasException) {
      throw Exception(meResult.exception.toString());
    }

    final userData = meResult.data?['me'] as Map<String, dynamic>?;
    print('DEBUG GQL RESPONSE: ${meResult.data}');
    if (userData == null) {
      throw Exception('Could not fetch user details');
    }

    return UserModel.fromJson(userData);
  }

  @override
  Future<void> logout() async {
    try {
      await FirebaseNotificationHelper.deleteFcmToken();
    } catch (e) {
      // Ignorar errores de red para asegurar que el logout local ocurra de todos modos
    }
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'jwt_refresh_token');
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    const String mutation = r'''
      mutation RequestPasswordReset($email: String!) {
        requestPasswordReset(email: $email) {
          success
          message
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'email': email},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final success = result.data?['requestPasswordReset']?['success'] as bool? ?? false;
    final message = result.data?['requestPasswordReset']?['message'] as String?;
    if (!success) {
      throw Exception(message ?? 'Failed to request password reset');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // This is a placeholder since the interface defines it but it was missing here
    await requestPasswordReset(email);
  }

  static int maxSpecialtiesLimit = 6;

  @override
  Future<List<Map<String, dynamic>>> getAvailableTags() async {
    const String query = r'''
      query GetSpecialties {
        maxSpecialtiesPerTradesman
        specialties {
          id
          name
          iconUrl
          color
          tags {
            id
            name
            iconUrl
            color
            subtags {
              id
              name
              color
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
      maxSpecialtiesLimit = maxLimit;
    }

    final specialtiesList = result.data?['specialties'] as List?;
    if (specialtiesList == null) {
      return [];
    }
    return specialtiesList.map((s) => s as Map<String, dynamic>).toList();
  }

  @override
  Future<Map<String, bool>> checkUserExistence({String? email, String? phoneNumber}) async {
    const String query = r'''
      query CheckUserExistence($email: String, $phoneNumber: String) {
        checkUserExistence(email: $email, phoneNumber: $phoneNumber) {
          emailExists
          phoneExists
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'email': email,
        'phoneNumber': phoneNumber,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      return {'emailExists': false, 'phoneExists': false};
    }

    final data = result.data?['checkUserExistence'] as Map<String, dynamic>?;
    return {
      'emailExists': data?['emailExists'] as bool? ?? false,
      'phoneExists': data?['phoneExists'] as bool? ?? false,
    };
  }
}
