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

import 'package:kite_ui/features/expense/data/datasources/ai_remote_data_source.dart';
import 'package:kite_ui/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:kite_ui/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:kite_ui/features/expense/domain/usecases/add_expense_usecase.dart';
import 'package:kite_ui/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:kite_ui/features/expense/domain/usecases/get_expense_summary_usecase.dart';
import 'package:kite_ui/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:kite_ui/features/expense/domain/usecases/parse_sms_usecase.dart';
import 'package:kite_ui/features/expense/domain/usecases/update_budget_usecase.dart';
import 'package:kite_ui/features/expense/domain/usecases/update_expense_usecase.dart';
import 'package:kite_ui/features/expense/presentation/bloc/ai_parser_bloc.dart';
import 'package:kite_ui/features/expense/presentation/bloc/expense_bloc.dart';

import 'package:kite_ui/features/sms_listener/data/datasources/sms_local_data_source.dart';
import 'package:kite_ui/features/sms_listener/data/repositories/sms_repository_impl.dart';
import 'package:kite_ui/features/sms_listener/presentation/bloc/sms_listener_bloc.dart';

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

    final expenseRemoteDataSource = ExpenseRemoteDataSourceImpl(apiClient: apiClient);
    final expenseRepository = ExpenseRepositoryImpl(remoteDataSource: expenseRemoteDataSource);

    final expenseBloc = ExpenseBloc(
      getExpensesUseCase: GetExpensesUseCase(expenseRepository),
      getExpenseSummaryUseCase: GetExpenseSummaryUseCase(expenseRepository),
      addExpenseUseCase: AddExpenseUseCase(expenseRepository),
      updateExpenseUseCase: UpdateExpenseUseCase(expenseRepository),
      deleteExpenseUseCase: DeleteExpenseUseCase(expenseRepository),
      updateBudgetUseCase: UpdateBudgetUseCase(repository: expenseRepository),
    );

    final aiRemoteDataSource = AiRemoteDataSourceImpl(apiClient: apiClient);
    final parseSmsUseCase = ParseSmsUseCase(aiRemoteDataSource);
    final aiParserBloc = AiParserBloc(parseSmsUseCase: parseSmsUseCase);

    final smsLocalDataSource = SmsLocalDataSourceImpl();
    final smsRepository = SmsRepositoryImpl(localDataSource: smsLocalDataSource);
    final smsListenerBloc = SmsListenerBloc(
      smsRepository: smsRepository,
      parseSmsUseCase: parseSmsUseCase,
    );

    await tester.pumpWidget(KiteApp(
      authBloc: authBloc,
      expenseBloc: expenseBloc,
      aiParserBloc: aiParserBloc,
      smsListenerBloc: smsListenerBloc,
    ));
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
