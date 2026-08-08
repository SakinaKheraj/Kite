import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_service.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/check_auth_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/home_screen_placeholder.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Services
  final storageService = StorageService();
  final apiClient = ApiClient(storageService: storageService);

  // Data Sources & Repository
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storageService: storageService,
  );

  // Use Cases
  final signupUseCase = SignupUseCase(authRepository);
  final loginUseCase = LoginUseCase(authRepository);
  final checkAuthUseCase = CheckAuthUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  runApp(
    KiteApp(
      authBloc: AuthBloc(
        signupUseCase: signupUseCase,
        loginUseCase: loginUseCase,
        checkAuthUseCase: checkAuthUseCase,
        logoutUseCase: logoutUseCase,
      )..add(const CheckAuthStatusRequested()),
    ),
  );
}

class KiteApp extends StatelessWidget {
  final AuthBloc authBloc;

  const KiteApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp(
        title: 'Kite Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return HomeScreenPlaceholder(userId: state.userId);
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
