import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_mobile_tradesman/features/requests/data/models/job_request_model.dart';

abstract class RequestsRemoteDataSource {
  Future<List<JobRequestModel>> getPendingJobRequests();
  Future<List<JobRequestModel>> getCompletedJobRequests();
  Future<List<JobRequestModel>> getRejectedJobRequests();
  Future<void> updateJobStatus(int jobId, String newStatus, {String? cancellationReason});
  Future<void> markJobAsRead(int jobId);
  Future<void> scheduleJobVisit(int jobId, String scheduledDate, String scheduledTime, int notificationLeadMinutes, {double? agreedPrice});
  Future<List<Map<String, dynamic>>> getOpenPublicJobRequests();
  Future<bool> submitJobProposal({
    required int publicRequestId,
    required double estimatedPrice,
    required String scheduledDate,
    required String scheduledTime,
    String? message,
  });
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final GraphQLClient client;

  RequestsRemoteDataSourceImpl(this.client);

  @override
  Future<void> updateJobStatus(int jobId, String newStatus, {String? cancellationReason}) async {
    const String mutation = r'''
      mutation UpdateJobStatus($jobId: Int!, $newStatus: String!, $cancellationReason: String) {
        updateJobStatus(jobId: $jobId, newStatus: $newStatus, cancellationReason: $cancellationReason) {
          job {
            id
            status
            cancellationReason
            cancelledByUserName
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'jobId': jobId,
        'newStatus': newStatus,
        'cancellationReason': cancellationReason,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<List<JobRequestModel>> getPendingJobRequests() async {
    const String query = r'''
      query GetPendingJobRequests {
        myJobs {
          id
          description
          scheduledDate
          scheduledTime
          agreedPrice
          address
          status
          isRead
          hasUnreadMessages
          enrichedDetails
          additionalPhotoUrl
          notificationLeadMinutes
          cancellationReason
          cancelledByUserName
          customer {
            id
            firstName
            lastName
            email
            phoneNumber
          }
          createdAt
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

    final data = result.data?['myJobs'] as List<dynamic>?;

    if (data == null) {
      return [];
    }

    return data
        .map((json) => JobRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<JobRequestModel>> getCompletedJobRequests() async {
    const String query = r'''
      query GetCompletedJobRequests {
        myJobs(status: "FINISHED") {
          id
          description
          scheduledDate
          scheduledTime
          agreedPrice
          address
          status
          isRead
          customer {
            id
            firstName
            email
            phoneNumber
          }
          review {
            rating
            comment
          }
          createdAt
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

    final data = result.data?['myJobs'] as List<dynamic>?;

    if (data == null) {
      return [];
    }

    return data
        .map((json) => JobRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<JobRequestModel>> getRejectedJobRequests() async {
    const String query = r'''
      query GetRejectedJobRequests {
        myJobs(status: "CANCELLED") {
          id
          description
          scheduledDate
          scheduledTime
          agreedPrice
          address
          status
          isRead
          enrichedDetails
          additionalPhotoUrl
          notificationLeadMinutes
          cancellationReason
          cancelledByUserName
          customer {
            id
            firstName
            email
            phoneNumber
          }
          createdAt
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

    final data = result.data?['myJobs'] as List<dynamic>?;

    if (data == null) {
      return [];
    }

    return data
        .map((json) => JobRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markJobAsRead(int jobId) async {
    const String mutation = r'''
      mutation MarkJobAsRead($jobId: Int!) {
        markJobAsRead(jobId: $jobId) {
          success
          job {
            id
            isRead
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'jobId': jobId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<void> scheduleJobVisit(int jobId, String scheduledDate, String scheduledTime, int notificationLeadMinutes, {double? agreedPrice}) async {
    const String mutation = r'''
      mutation ScheduleJobVisit($jobId: Int!, $scheduledDate: Date!, $scheduledTime: Time!, $notificationLeadMinutes: Int!, $agreedPrice: Decimal) {
        scheduleJobVisit(jobId: $jobId, scheduledDate: $scheduledDate, scheduledTime: $scheduledTime, notificationLeadMinutes: $notificationLeadMinutes, agreedPrice: $agreedPrice) {
          success
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'jobId': jobId,
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'notificationLeadMinutes': notificationLeadMinutes,
        'agreedPrice': agreedPrice,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOpenPublicJobRequests() async {
    const String query = r'''
      query OpenPublicJobRequests($specialtyId: Int) {
        openPublicJobRequests(specialtyId: $specialtyId) {
          id
          title
          description
          address
          budget
          isUrgent
          status
          createdAt
          customerName
          specialtyName
          proposalsCount
          hasSubmittedProposal
          myProposal {
            id
            estimatedPrice
            scheduledDate
            scheduledTime
            message
            status
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
      return [];
    }

    final List list = result.data?['openPublicJobRequests'] ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<bool> submitJobProposal({
    required int publicRequestId,
    required double estimatedPrice,
    required String scheduledDate,
    required String scheduledTime,
    String? message,
  }) async {
    const String mutation = r'''
      mutation SubmitJobProposal(
        $publicRequestId: Int!,
        $estimatedPrice: Float!,
        $scheduledDate: Date!,
        $scheduledTime: Time!,
        $message: String
      ) {
        submitJobProposal(
          publicRequestId: $publicRequestId,
          estimatedPrice: $estimatedPrice,
          scheduledDate: $scheduledDate,
          scheduledTime: $scheduledTime,
          message: $message
        ) {
          success
          proposal {
            id
            status
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'publicRequestId': publicRequestId,
        'estimatedPrice': estimatedPrice,
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'message': message,
      },
    );

    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['submitJobProposal']?['success'] ?? false;
  }
}
