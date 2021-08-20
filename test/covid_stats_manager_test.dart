import 'dart:convert';
import 'dart:math';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collector/repo/covid_stats_manager.dart';

class DioMock extends Mock implements Dio {}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  Response<dynamic> response;

  group('Covid stats', () {

    int randomId = Random().nextInt(CovidStatsManager.countryIsoList.length);

    //use random number to get an iso-code from the list
    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
    });

    test('return a map when status code 200', () async {

      String url =
          'https://coronavirus-smartable.p.rapidapi.com/stats/v1/${CovidStatsManager.countryIsoList[randomId]}/';

      dioAdapter.onGet(
        url,
            (server) => server.reply(200, {'message': 'Success!'}),
      );
      final response = await dio.get(url);

      expect(response.statusCode, 200);
    });

  });

}
