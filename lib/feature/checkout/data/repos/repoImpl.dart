import 'package:dartz/dartz.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/checkout/data/repos/repo.dart';
import 'package:shop_app/feature/checkout/data/services/StripeServices.dart';


import '../models/payment_intent_input_model/payment_intent_input_model.dart';

class RepositoryImpl extends Repository {


final StripeServices stripeServices = StripeServices();

  @override
  Future<Either<Failure, void>> makePayment({
    required PaymentIntentInputModel inputModel,
  }) async {
    try {
      await stripeServices.makepayment(inputModel: inputModel);
      return Right(null);
    } on StripeException catch (e) {
      return Left(ServerFailure(e.error.message ?? 'Stripe Exception'));
    }catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 