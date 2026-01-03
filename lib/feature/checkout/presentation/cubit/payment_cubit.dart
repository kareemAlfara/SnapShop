import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:shop_app/feature/checkout/domain/usecases/stripeUseCase.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this.stripeUseCase) : super(PaymentInitial());
  final StripeUseCase stripeUseCase;

  Future<void> makePayment({
    required PaymentIntentInputModel inputModel,
  }) async {
    emit(PaymentLoading());
    
    log('PaymentCubit: Starting payment...');
    log('Input: $inputModel');

    final result = await stripeUseCase.makePayment(inputModel: inputModel);
    
    result.fold(
      (failure) {
        log('PaymentCubit: Payment failed - ${failure.message}');
        emit(PaymentFailure(failure.message));
      },
      (_) {
        log('PaymentCubit: Payment successful! ✅');
        emit(PaymentSuccess());
      },
    );
  }

  @override
  void onChange(Change<PaymentState> change) {
    log(change.toString());
    super.onChange(change);
  }
}