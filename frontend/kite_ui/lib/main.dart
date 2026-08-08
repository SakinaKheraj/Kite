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
import 'features/auth/presentation/screens/login_screen.dart';

import 'features/expense/data/datasources/ai_remote_data_source.dart';
import 'features/expense/data/datasources/expense_remote_data_source.dart';
import 'features/expense/data/repositories/expense_repository_impl.dart';
import 'features/expense/domain/usecases/add_expense_usecase.dart';
import 'features/expense/domain/usecases/delete_expense_usecase.dart';
import 'features/expense/domain/usecases/get_expense_summary_usecase.dart';
import 'features/expense/domain/usecases/get_expenses_usecase.dart';
import 'features/expense/domain/usecases/parse_sms_usecase.dart';
import 'features/expense/domain/usecases/update_expense_usecase.dart';
import 'features/expense/presentation/bloc/ai_parser_bloc.dart';
import 'features/expense/presentation/bloc/expense_bloc.dart';
import 'features/expense/presentation/screens/expense_dashboard_screen.dart';

import 'features/sms_listener/data/datasources/sms_local_data_source.dart';
import 'features/sms_listener/data/repositories/sms_repository_impl.dart';
import 'features/sms_listener/presentation/bloc/sms_listener_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Services
  final storageService = StorageService();
  final apiClient = ApiClient(storageService: storageService);

  // Auth Data Sources & Repository
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storageService: storageService,
  );

  // Auth Use Cases
  final signupUseCase = SignupUseCase(authRepository);
  final loginUseCase = LoginUseCase(authRepository);
  final checkAuthUseCase = CheckAuthUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // Expense Data Sources & Repository
  final expenseRemoteDataSource = ExpenseRemoteDataSourceImpl(apiClient: apiClient);
  final expenseRepository = ExpenseRepositoryImpl(remoteDataSource: expenseRemoteDataSource);

  // Expense Use Cases
  final getExpensesUseCase = GetExpensesUseCase(expenseRepository);
  final getExpenseSummaryUseCase = GetExpenseSummaryUseCase(expenseRepository);
  final addExpenseUseCase = AddExpenseUseCase(expenseRepository);
  final updateExpenseUseCase = UpdateExpenseUseCase(expenseRepository);
  final deleteExpenseUseCase = DeleteExpenseUseCase(expenseRepository);

  // AI Parser Data Source & Use Case
  final aiRemoteDataSource = AiRemoteDataSourceImpl(apiClient: apiClient);
  final parseSmsUseCase = ParseSmsUseCase(aiRemoteDataSource);

  // SMS Listener Data Source, Repository & BLoC
  final smsLocalDataSource = SmsLocalDataSourceImpl();
  final smsRepository = SmsRepositoryImpl(localDataSource: smsLocalDataSource);
  final smsListenerBloc = SmsListenerBloc(
    smsRepository: smsRepository,
    parseSmsUseCase: parseSmsUseCase,
  );

  final authBloc = AuthBloc(
    signupUseCase: signupUseCase,
    loginUseCase: loginUseCase,
    checkAuthUseCase: checkAuthUseCase,
    logoutUseCase: logoutUseCase,
  )..add(const CheckAuthStatusRequested());

  final expenseBloc = ExpenseBloc(
    getExpensesUseCase: getExpensesUseCase,
    getExpenseSummaryUseCase: getExpenseSummaryUseCase,
    addExpenseUseCase: addExpenseUseCase,
    updateExpenseUseCase: updateExpenseUseCase,
    deleteExpenseUseCase: deleteExpenseUseCase,
  );

  final aiParserBloc = AiParserBloc(parseSmsUseCase: parseSmsUseCase);

  runApp(
    KiteApp(
      authBloc: authBloc,
      expenseBloc: expenseBloc,
      aiParserBloc: aiParserBloc,
      smsListenerBloc: smsListenerBloc,
    ),
  );
}

class KiteApp extends StatelessWidget {
  final AuthBloc authBloc;
  final ExpenseBloc expenseBloc;
  final AiParserBloc aiParserBloc;
  final SmsListenerBloc smsListenerBloc;

  const KiteApp({
    super.key,
    required this.authBloc,
    required this.expenseBloc,
    required this.aiParserBloc,
    required this.smsListenerBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: expenseBloc),
        BlocProvider.value(value: aiParserBloc),
        BlocProvider.value(value: smsListenerBloc),
      ],
      child: MaterialApp(
        title: 'Kite Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return ExpenseDashboardScreen(userId: state.userId);
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
