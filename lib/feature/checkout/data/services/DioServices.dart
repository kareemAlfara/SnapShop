import 'package:dio/dio.dart';

class DioServices {
  final Dio dio = Dio();

  Future<Response> post({
    required String url,
    required Map<String, dynamic> data,
    required String token,
     String? contentType,
    Map<String, dynamic>? Headers  ,
  }) async {
  var  respone= await dio.post(
      url,
      data: data,
      options: Options(
        contentType:contentType ,
        headers:Headers ??{'Authorization': 'Bearer $token'},
      ),
    );
    return respone;
  }

  Future<Response> get({required String url, required String token}) async {
    var respone =  await dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return respone;
  }

  Future<Response> delete({required String url, required String token}) async {
    var respone = await dio.delete(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return respone;
  }
}
