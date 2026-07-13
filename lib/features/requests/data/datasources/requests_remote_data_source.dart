import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_mobile_tradesman/features/requests/data/models/job_request_model.dart';

abstract class RequestsRemoteDataSource {
  Future<List<JobRequestModel>> getPendingJobRequests();
  Future<List<JobRequestModel>> getCompletedJobRequests();
  Future<List<JobRequestModel>> getRejectedJobRequests();
  Future<void> updateJobStatus(int jobId, String newStatus);
  Future<void> markJobAsRead(int jobId);
  Future<void> scheduleJobVisit(int jobId, String scheduledDate, String scheduledTime, int notificationLeadMinutes, {double? agreedPrice});
}

class RequestsRemoteDataSourceImpl implements RequestsRemoteDataSource {
  final GraphQLClient client;

  RequestsRemoteDataSourceImpl(this.client);

  @override
  Future<void> updateJobStatus(int jobId, String newStatus) async {
    const String mutation = r'''
      mutation UpdateJobStatus($jobId: Int!, $newStatus: String!) {
        updateJobStatus(jobId: $jobId, newStatus: $newStatus) {
          job {
            id
            status
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'jobId': jobId,
        'newStatus': newStatus,
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
          enrichedDetails
          additionalPhotoUrl
          notificationLeadMinutes
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
}
