part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

// ✅ الحالة الأولية
class OrderInitial extends OrderState {}

// ✅ حالة التحميل
class OrderLoading extends OrderState {}

// ✅ نجاح إنشاء الطلب
class OrderSuccess extends OrderState {
  final String orderId;

  const OrderSuccess(this.orderId);

  @override
  List<Object> get props => [orderId];
}

// ✅ تحميل الطلبات بنجاح
class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

// ✅ لا توجد طلبات
class OrdersEmpty extends OrderState {
  const OrdersEmpty();
}

// ✅ تم تحديث حالة الطلب
class OrderStatusUpdated extends OrderState {}

// ✅ تم إلغاء الطلب
class OrderCancelled extends OrderState {}

// ✅ فشل العملية
class OrderFailure extends OrderState {
  final String error;

  const OrderFailure(this.error);

  @override
  List<Object> get props => [error];
}

// ✅ حالة تحميل طلب واحد
class SingleOrderLoading extends OrderState {}

// ✅ تم تحميل طلب واحد بنجاح
class SingleOrderLoaded extends OrderState {
  final OrderEntity order;

  const SingleOrderLoaded(this.order);

  @override
  List<Object> get props => [order];
}