import 'package:dartz/dartz.dart';
import 'package:shop_app/core/utils/failures.dart';
import 'package:shop_app/feature/checkout/data/models/payment_intent_input_model/payment_intent_input_model.dart';
import 'package:shop_app/feature/checkout/data/repos/repo.dart';
import 'package:shop_app/feature/checkout/data/services/StripeServices.dart';

class RepositoryImpl implements Repository {
  final StripeServices stripeServices = StripeServices();

  @override
  Future<Either<Failure, void>> makePayment({
    required PaymentIntentInputModel inputModel,
  }) async {
    try {
      print('Repository: Starting payment process...');
      print('Input Model: $inputModel');
      
      await stripeServices.makepayment(inputModel: inputModel);
      
      print('Repository: Payment completed successfully ✅');
      return const Right(null);
    } catch (e) {
      print('Repository: Payment failed ❌');
      print('Error: $e');
      
      String errorMessage = 'Payment failed';
      
      if (e.toString().contains('canceled')) {
        errorMessage = 'Payment was cancelled';
      } else if (e.toString().contains('network') || 
                 e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('card')) {
        errorMessage = 'Card error. Please check your card details';
      } else {
        errorMessage = 'Payment failed: ${e.toString()}';
      }
      
      return Left(ServerFailure( message:errorMessage));
    }
  }
}