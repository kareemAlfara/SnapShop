import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/checkout/data/repos/repo.dart';


class StripeUseCase {
  // Use case implementation
  final Repository repository;

  StripeUseCase(this.repository);
  Future<Either<Failure, void>> makePayment({
    required inputModel,
  }) async {
    return await repository.makePayment(inputModel: inputModel);
  }
}