import 'package:get_it/get_it.dart';
import 'package:clanship_mobile_tradesman/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:clanship_mobile_tradesman/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:clanship_mobile_tradesman/features/home/presentation/bloc/home_bloc.dart';
import 'package:clanship_mobile_tradesman/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/theme_bloc.dart';
import 'package:clanship_mobile_tradesman/core/theme/bloc/language_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:clanship_mobile_tradesman/core/network/graphql_service.dart';
import 'package:clanship_mobile_tradesman/core/network/jobs_websocket_service.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/repositories/auth_repository.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/login_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/register_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/logout_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:clanship_mobile_tradesman/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/repositories/profile_repository.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/update_availability_usecase.dart';
import 'package:clanship_mobile_tradesman/features/profile/domain/usecases/subscription_usecases.dart';

import 'package:clanship_mobile_tradesman/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/repositories/requests_repository.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_pending_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_completed_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/get_rejected_requests_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/update_job_status_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/mark_job_as_read_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/domain/usecases/schedule_job_visit_usecase.dart';
import 'package:clanship_mobile_tradesman/features/requests/presentation/bloc/requests_bloc.dart';

import 'package:clanship_mobile_tradesman/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:clanship_mobile_tradesman/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/repositories/chat_repository.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/get_or_create_chat_room_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/stream_chat_messages_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/chat_room_bloc.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Init Hive for GraphQL Cache
  await initHiveForFlutter();

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core Network
  sl.registerLazySingleton(() => GraphQLService(sl()));
  sl.registerLazySingleton(() => JobsWebSocketService());

  // Features - Splash
  sl.registerFactory(() => SplashBloc(sl()));

  // Features - Navigation
  sl.registerFactory(() => NavigationBloc());

  // Features - Home
  sl.registerFactory(() => HomeBloc(sl(), sl(), sl()));

  // Features - Profile
  sl.registerFactory(() => ProfileBloc(sl()));

  // Features - Auth
  sl.registerFactory(() => AuthBloc(sl(), sl(), sl(), sl()));

  // Features - Requests
  sl.registerFactory(
    () => RequestsBloc(
      getPendingRequests: sl(),
      getCompletedRequests: sl(),
      getRejectedRequests: sl(),
      updateJobStatus: sl(),
      markJobAsRead: sl(),
      scheduleJobVisit: sl(),
    ),
  );

  // Features - Chat
  sl.registerFactory(() => ChatRoomBloc(getOrCreateChatRoom: sl()));
  sl.registerFactory(
    () => ChatMessagesBloc(
      getChatHistory: sl(),
      streamChatMessages: sl(),
      sendChatMessage: sl(),
      repository: sl(),
    ),
  );

  // Core - Theme / Language
  sl.registerLazySingleton(() => ThemeBloc());
  sl.registerLazySingleton(() => LanguageBloc());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<GraphQLService>().client),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<GraphQLService>().client),
  );
  sl.registerLazySingleton<RequestsRemoteDataSource>(
    () => RequestsRemoteDataSourceImpl(sl<GraphQLService>().client),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<GraphQLService>().client),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<RequestsRepository>(
    () => RequestsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl(), sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionPlansUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToPlanUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetRejectedRequestsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateJobStatusUseCase(sl()));
  sl.registerLazySingleton(() => MarkJobAsReadUseCase(sl()));
  sl.registerLazySingleton(() => ScheduleJobVisitUseCase(sl()));
  sl.registerLazySingleton(() => GetOrCreateChatRoomUseCase(sl()));
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
  sl.registerLazySingleton(() => StreamChatMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));

  // Core
}
