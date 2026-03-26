import 'main.dart';
import 'core/app_config.dart';

void main() async {
  await AppConfig.init(environment: AppEnv.prod);
  await startApp();
}
