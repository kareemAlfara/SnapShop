// ========================================
// 📁 lib/core/di/order_injection.dart
// ========================================
import 'package:get_it/get_it.dart';
import 'package:shop_app/feature/checkout/data/dataSource/order_remote_datasource.dart';
import 'package:shop_app/feature/checkout/data/repos/order_repository_impl.dart';
import 'package:shop_app/feature/checkout/domain/order_repo/order_repository.dart';
import 'package:shop_app/feature/checkout/domain/usecases/create_order_usecase.dart';
import 'package:shop_app/feature/checkout/domain/usecases/get_user_orders_usecase.dart';
import 'package:shop_app/feature/checkout/presentation/cubit/order_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> setupOrderDependencies() async {
  print('🔧 Initializing Order dependencies...');

  // ✅ 1. Supabase Client (if not already registered)
  if (!getIt.isRegistered<SupabaseClient>()) {
    getIt.registerLazySingleton<SupabaseClient>(
      () => Supabase.instance.client,
    );
    print('   ✅ SupabaseClient registered');
  }

  // ✅ 2. Data Source
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(
      supabase: getIt<SupabaseClient>(),
    ),
  );
  print('   ✅ OrderRemoteDataSource registered');

  // ✅ 3. Repository
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: getIt<OrderRemoteDataSource>(),
    ),
  );
  print('   ✅ OrderRepository registered');

  // ✅ 4. Use Cases
  getIt.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(getIt<OrderRepository>()),
  );
  print('   ✅ CreateOrderUseCase registered');

  getIt.registerLazySingleton<GetUserOrdersUseCase>(
    () => GetUserOrdersUseCase(getIt<OrderRepository>()),
  );
  print('   ✅ GetUserOrdersUseCase registered');

  // ✅ 5. Cubit - IMPORTANT: Use registerFactory, not registerLazySingleton
  getIt.registerFactory<OrderCubit>(
    () => OrderCubit(
      createOrderUseCase: getIt<CreateOrderUseCase>(),
      getUserOrdersUseCase: getIt<GetUserOrdersUseCase>(),
    ),
  );
  print('   ✅ OrderCubit registered');

  print('✅ Order dependencies initialized successfully\n');
}