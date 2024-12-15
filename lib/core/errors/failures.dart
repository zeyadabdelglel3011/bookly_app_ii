import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

class ServerFailure extends Failure {
  const ServerFailure(String errMessage) : super(errMessage);

  factory ServerFailure.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with the server.');

      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with the server.');

      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with the server.');

      case DioExceptionType.badCertificate:
        return ServerFailure('Invalid certificate received from the server.');

      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioError.response?.statusCode,
          dioError.response?.data,
        );

      case DioExceptionType.cancel:
        return ServerFailure('Request to the server was canceled.');

      case DioExceptionType.connectionError:
        return ServerFailure('Failed to establish a connection with the server.');

      case DioExceptionType.unknown:
        if (dioError.message!.contains('SocketException')) {
          return ServerFailure('No Internet connection.');
        }
        return ServerFailure('Unexpected error occurred, please try again.');

      default:
        return ServerFailure('Oops, an error occurred, please try again.');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response['error']['message'] ?? 'Unauthorized request.');
    } else if (statusCode == 404) {
      return ServerFailure('The requested resource was not found.');
    } else if (statusCode == 500) {
      return ServerFailure('Internal server error, please try again later.');
    } else {
      return ServerFailure('An unexpected error occurred, please try again.');
    }
  }
}
