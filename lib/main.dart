import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rewardpoints/app/bootstrap/app_widget.dart';
import 'package:rewardpoints/app/di/service_locator.dart';
import 'package:rewardpoints/shared/licenses/app_license_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ステータスバーをシースルーに設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // 縦向き固定 (必要に応じてコメントアウト)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 依存性注入の初期化
  await setupServiceLocator();

  // LicenseRegistry に独自ライセンスを登録
  AppLicenseRegistrar.register();

  runApp(const AppWidget());
}
