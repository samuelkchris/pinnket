// import 'package:pinnket/api/api_service.dart';
// import 'package:test/test.dart';
// import 'package:dio/dio.dart';
// import 'package:mockito/mockito.dart';
//
// class MockDio extends Mock implements Dio {}
//
// void main() {
//   late ApiService apiService;
//   late MockDio mockDio;
//
//   setUp(() {
//     mockDio = MockDio();
//     apiService = ApiService();
//     apiService._dio = mockDio;
//   });
//
//   group('ApiService', () {
//     test('get returns data on success', () async {
//       final response = Response(
//         requestOptions: RequestOptions(path: '/test'),
//         data: {'key': 'value'},
//         statusCode: 200,
//       );
//       when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
//           .thenAnswer((_) async => response);
//
//       final result = await apiService.get('/test');
//
//       expect(result.data, {'key': 'value'});
//     });
//
//     test('post returns data on success', () async {
//       final response = Response(
//         requestOptions: RequestOptions(path: '/test'),
//         data: {'key': 'value'},
//         statusCode: 200,
//       );
//       when(mockDio.post(any, data: anyNamed('data'),
//           queryParameters: anyNamed('queryParameters'),
//           options: anyNamed('options')))
//           .thenAnswer((_) async => response);
//
//       final result = await apiService.post('/test', data: {'data': 'value'});
//
//       expect(result.data, {'key': 'value'});
//     });
//
//     test('put returns data on success', () async {
//       final response = Response(
//         requestOptions: RequestOptions(path: '/test'),
//         data: {'key': 'value'},
//         statusCode: 200,
//       );
//       when(mockDio.put(any, data: anyNamed('data'),
//           queryParameters: anyNamed('queryParameters')))
//           .thenAnswer((_) async => response);
//
//       final result = await apiService.put('/test', data: {'data': 'value'});
//
//       expect(result.data, {'key': 'value'});
//     });
//
//     test('delete returns data on success', () async {
//       final response = Response(
//         requestOptions: RequestOptions(path: '/test'),
//         data: {'key': 'value'},
//         statusCode: 200,
//       );
//       when(mockDio.delete(any, data: anyNamed('data'),
//           queryParameters: anyNamed('queryParameters')))
//           .thenAnswer((_) async => response);
//
//       final result = await apiService.delete('/test', data: {'data': 'value'});
//
//       expect(result.data, {'key': 'value'});
//     });
//
//     test('uploadFile returns data on success', () async {
//       final file = File('test.txt');
//       final response = Response(
//         requestOptions: RequestOptions(path: '/upload'),
//         data: {'key': 'value'},
//         statusCode: 200,
//       );
//       when(mockDio.post(
//           any, data: anyNamed('data'), options: anyNamed('options')))
//           .thenAnswer((_) async => response);
//
//       final result = await apiService.uploadFile('/upload', file);
//
//       expect(result.data, {'key': 'value'});
//     });
//
//     test('get throws NetworkException on timeout', () async {
//       when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
//           .thenThrow(DioException(type: DioExceptionType.connectionTimeout, requestOptions: RequestOptions(path: '/test')));
//
//       expect(() => apiService.get('/test'), throwsA(isA<NetworkException>()));
//     });
//
//     test('post throws BadRequestException on 400', () async {
//       final response = Response(
//         requestOptions: RequestOptions(path: '/test'),
//         data: {'message': 'Bad Request'},
//         statusCode: 400,
//       );
//       when(mockDio.post(any, data: anyNamed('data'),
//           queryParameters: anyNamed('queryParameters'),
//           options: anyNamed('options')))
//           .thenThrow(DioException(response: response, requestOptions: RequestOptions(path: '/test')));
//
//       expect(() => apiService.post('/test', data: {'data': 'value'}),
//           throwsA(isA<BadRequestException>()));
//     });
//   });
// }