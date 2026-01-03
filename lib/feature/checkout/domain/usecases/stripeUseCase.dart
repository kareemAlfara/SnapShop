import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:shop_app/feature/checkout/data/repos/repo.dart';

class StripeUseCase {
  final Repository repository;

  StripeUseCase(this.repository);

  Future<Either<Failure, void>> makePayment({
    required PaymentIntentInputModel inputModel,
  }) async {
    return await repository.makePayment(inputModel: inputModel);
  }
}