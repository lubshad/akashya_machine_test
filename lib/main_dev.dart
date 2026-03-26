import 'main.dart';
import 'core/app_config.dart';

void main() async {
  await AppConfig.init(
    environment: AppEnv.dev,
    email: 'dev@finvestea.com',
    password: 'Password123',
    phone: '9876543210',
  );
  await startApp();
}
