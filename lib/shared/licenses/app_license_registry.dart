import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Registers additional in-app license notices with [LicenseRegistry].
///
/// Flutter auto-registers licenses for packages that ship a LICENSE file.
/// Use this to add notices that are not picked up automatically, such as
/// fonts, in-house assets, or inline third-party code.
class AppLicenseRegistrar {
  AppLicenseRegistrar._();

  /// Call once at app startup, before [showLicensePage] is used.
  static void register() {
    LicenseRegistry.addLicense(_appLicenses);
  }

  static Stream<LicenseEntry> _appLicenses() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Noto Sans JP'],
      'Copyright 2014-2023 Adobe (http://www.adobe.com/), with Reserved Font '
          'Name "Source". All Rights Reserved. Noto is a trademark of Google LLC.\n\n'
          'This Font Software is licensed under the SIL Open Font License, Version 1.1.',
    );
    yield const LicenseEntryWithLineBreaks(
      [AppConfig.designSystemName],
      'Design tokens are derived from the ${AppConfig.designSystemName}, '
          'distributed under the ${AppConfig.designSystemLicense} license. '
          'See ${AppConfig.designSystemUrl} for details.',
    );
  }
}
