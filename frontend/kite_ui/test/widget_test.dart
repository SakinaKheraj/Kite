import 'package:flutter_test/flutter_test.dart';
import 'package:kite_ui/core/network/api_client.dart';
import 'package:kite_ui/core/utils/storage_service.dart';
import 'package:kite_ui/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kite_ui/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kite_ui/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kite_ui/features/auth/domain/usecases/login_usecase.dart';
import 'package:kite_ui/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kite_ui/features/auth/domain/usecases/signup_usecase.dart';
import 'package:kite_ui/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kite_ui/main.dart';

void main() {
  testWidgets('KiteApp smoke test', (WidgetTester tester) async {
    final storageService = StorageService();
    final apiClient = ApiClient(storageService: storageService);
    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      storageService: storageService,
    );

    final authBloc = AuthBloc(
      signupUseCase: SignupUseCase(authRepository),
      loginUseCase: LoginUseCase(authRepository),
      checkAuthUseCase: CheckAuthUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
    );

    await tester.pumpWidget(KiteApp(authBloc: authBloc));
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
