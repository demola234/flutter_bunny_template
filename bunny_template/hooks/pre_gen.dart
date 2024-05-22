import 'package:mason/mason.dart';

enum Platform {
  android,
  ios,
}

void run(HookContext context) {
  context.vars['application_id_android'] =
      _appId(context, platform: Platform.android);
  context.vars['application_id'] = _appId(context);
}

String _appId(HookContext context, {Platform? platform}) {
  final applicationId = context.vars['application_id'] as String?;
  if (applicationId == null) {
    return '';
  }
  if (platform == Platform.android) {
    return applicationId.replaceAll('.', '_');
  }

  if (platform == Platform.ios) {
    return applicationId.replaceAll('.', '');
  }

  return applicationId;
}
