import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutterbase/application/usecases/app_info/get_app_info_usecase.dart';
import 'package:flutterbase/application/usecases/data/export_data_usecase.dart';
import 'package:flutterbase/application/usecases/data/import_data_usecase.dart';
import 'package:flutterbase/application/usecases/debug/get_debug_settings_usecase.dart';
import 'package:flutterbase/application/usecases/debug/set_debug_mode_usecase.dart';
import 'package:flutterbase/application/usecases/debug/set_log_level_usecase.dart';
import 'package:flutterbase/application/usecases/points/add_points_usecase.dart';
import 'package:flutterbase/application/usecases/points/consume_points_usecase.dart';
import 'package:flutterbase/application/usecases/points/delete_point_entry_usecase.dart';
import 'package:flutterbase/application/usecases/points/update_point_entry_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_past_applications_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_past_reasons_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_point_balance_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_point_history_usecase.dart';
import 'package:flutterbase/application/usecases/theme/get_theme_preference_usecase.dart';
import 'package:flutterbase/application/usecases/theme/set_theme_preference_usecase.dart';
import 'package:flutterbase/application/usecases/user/create_user_usecase.dart';
import 'package:flutterbase/application/usecases/user/delete_user_usecase.dart';
import 'package:flutterbase/application/usecases/user/get_users_usecase.dart';
import 'package:flutterbase/domain/repositories/app_info_repository.dart';
import 'package:flutterbase/domain/repositories/debug_settings_repository.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/repositories/theme_preference_repository.dart';
import 'package:flutterbase/domain/repositories/user_repository.dart';
import 'package:flutterbase/infrastructure/db/sqlite/app_database.dart';
import 'package:flutterbase/infrastructure/db/sqlite/dao/point_entry_dao.dart';
import 'package:flutterbase/infrastructure/db/sqlite/dao/user_dao.dart';
import 'package:flutterbase/infrastructure/logging/persistent_app_logger.dart';
import 'package:flutterbase/infrastructure/repositories/package_info_app_info_repository.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_debug_settings_repository.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_theme_preference_repository.dart';
import 'package:flutterbase/infrastructure/repositories/sqlite_point_entry_repository.dart';
import 'package:flutterbase/infrastructure/repositories/sqlite_user_repository.dart';
import 'package:flutterbase/presentation/viewmodels/about_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/add_points_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/consume_points_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/debug_settings_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/debug_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/export_import_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/theme_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/user_detail_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/user_list_viewmodel.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';

final GetIt sl = GetIt.instance;

/// Wires up all dependencies. Call once at app startup before [runApp].
Future<void> setupServiceLocator() async {
  // ─── Infrastructure singletons ───────────────────────────────────────

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ignore: avoid_print — logger not yet available
  print('[DI] SharedPreferences ready');

  // ─── Debug settings repository (needed before logger init) ──────────
  final debugSettingsRepo = SharedPreferencesDebugSettingsRepository(prefs);
  sl.registerSingleton<DebugSettingsRepository>(debugSettingsRepo);

  // Logging — restore saved level so filtering is correct from first log
  final logger = PersistentAppLogger();
  await logger.init(savedLevel: debugSettingsRepo.getMinLogLevel());
  sl.registerSingleton<AppLogger>(logger);
  logger.info('[DI] Logger ready (minLevel: ${logger.minLevel.name})');

  // ─── Repository bindings ─────────────────────────────────────────────

  sl.registerSingleton<ThemePreferenceRepository>(
    SharedPreferencesThemePreferenceRepository(prefs),
  );

  sl.registerSingleton<AppInfoRepository>(
    const PackageInfoAppInfoRepository(),
  );

  // ─── Use cases ───────────────────────────────────────────────────────

  sl.registerFactory<GetThemePreferenceUseCase>(
    () => GetThemePreferenceUseCase(sl<ThemePreferenceRepository>()),
  );
  sl.registerFactory<SetThemePreferenceUseCase>(
    () => SetThemePreferenceUseCase(sl<ThemePreferenceRepository>()),
  );
  sl.registerFactory<GetAppInfoUseCase>(
    () => GetAppInfoUseCase(sl<AppInfoRepository>()),
  );
  sl.registerFactory<GetDebugSettingsUseCase>(
    () => GetDebugSettingsUseCase(sl<DebugSettingsRepository>()),
  );
  sl.registerFactory<SetDebugModeUseCase>(
    () => SetDebugModeUseCase(sl<DebugSettingsRepository>()),
  );
  sl.registerFactory<SetLogLevelUseCase>(
    () => SetLogLevelUseCase(sl<DebugSettingsRepository>(), sl<AppLogger>()),
  );

  // ─── ViewModels ──────────────────────────────────────────────────────

  sl.registerSingleton<ThemeViewModel>(
    ThemeViewModel(
      sl<GetThemePreferenceUseCase>(),
      sl<SetThemePreferenceUseCase>(),
    ),
  );
  sl.registerSingleton<DebugSettingsViewModel>(
    DebugSettingsViewModel(
      sl<GetDebugSettingsUseCase>(),
      sl<SetDebugModeUseCase>(),
      sl<SetLogLevelUseCase>(),
    ),
  );
  sl.registerFactory<AboutViewModel>(
    () => AboutViewModel(sl<GetAppInfoUseCase>()),
  );
  sl.registerFactory<DebugViewModel>(
    () => DebugViewModel(sl<GetAppInfoUseCase>(), sl<AppLogger>()),
  );

  // ─── Infrastructure (DB, Repositories) ──────────────────────────────
  final appDb = AppDatabase.instance;
  final database = await appDb.database;
  sl.registerSingleton<AppDatabase>(appDb);

  final userDao = UserDao(database);
  final pointEntryDao = PointEntryDao(database);

  sl.registerSingleton<UserRepository>(SqliteUserRepository(userDao));
  sl.registerSingleton<PointEntryRepository>(
    SqlitePointEntryRepository(pointEntryDao),
  );

  // ─── Application (UseCases) ─────────────────────────────────────────
  sl.registerFactory<CreateUserUseCase>(
    () => CreateUserUseCase(sl<UserRepository>()),
  );
  sl.registerFactory<GetUsersUseCase>(
    () => GetUsersUseCase(sl<UserRepository>(), sl<PointEntryRepository>()),
  );
  sl.registerFactory<DeleteUserUseCase>(
    () => DeleteUserUseCase(sl<UserRepository>(), sl<PointEntryRepository>()),
  );
  sl.registerFactory<AddPointsUseCase>(
    () => AddPointsUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<ConsumePointsUseCase>(
    () => ConsumePointsUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<GetPointHistoryUseCase>(
    () => GetPointHistoryUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<GetPointBalanceUseCase>(
    () => GetPointBalanceUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<GetPastReasonsUseCase>(
    () => GetPastReasonsUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<GetPastApplicationsUseCase>(
    () => GetPastApplicationsUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<DeletePointEntryUseCase>(
    () => DeletePointEntryUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<UpdatePointEntryUseCase>(
    () => UpdatePointEntryUseCase(sl<PointEntryRepository>()),
  );
  sl.registerFactory<ExportDataUseCase>(
    () => ExportDataUseCase(sl<UserRepository>(), sl<PointEntryRepository>()),
  );
  sl.registerFactory<ImportDataUseCase>(
    () => ImportDataUseCase(sl<UserRepository>(), sl<PointEntryRepository>()),
  );

  // ─── Point ViewModels ────────────────────────────────────────────────
  sl.registerSingleton<UserListViewModel>(
    UserListViewModel(
      sl<GetUsersUseCase>(),
      sl<CreateUserUseCase>(),
      sl<DeleteUserUseCase>(),
    ),
  );
  sl.registerFactory<UserDetailViewModel>(
    () => UserDetailViewModel(
      sl<GetPointHistoryUseCase>(),
      sl<GetPointBalanceUseCase>(),
      sl<DeletePointEntryUseCase>(),
      sl<UpdatePointEntryUseCase>(),
    ),
  );
  sl.registerFactory<AddPointsViewModel>(
    () => AddPointsViewModel(sl<AddPointsUseCase>(), sl<GetPastReasonsUseCase>()),
  );
  sl.registerFactory<ConsumePointsViewModel>(
    () => ConsumePointsViewModel(sl<ConsumePointsUseCase>(), sl<GetPastApplicationsUseCase>()),
  );
  sl.registerFactory<ExportImportViewModel>(
    () => ExportImportViewModel(sl<ExportDataUseCase>(), sl<ImportDataUseCase>()),
  );

  sl<AppLogger>().info('[DI] Service locator setup complete');
}
