import 'dart:async';

import 'package:weather_app/domain/weather/weather_services.dart';
import 'package:weather_app/models/exceptions.dart';
import 'package:weather_app/models/data_error.dart';
import 'package:weather_app/models/either.dart';
import 'package:weather_app/models/weather.dart';

class WeatherRepository {
  final WeatherApiService _apiService;
  final WeatherDBService _dbService;
  DateTime _lastRemoteFetch = DateTime.fromMillisecondsSinceEpoch(0);
  String? _previousCityId;

  WeatherRepository({apiService, dbService})
      : _apiService = apiService,
        _dbService = dbService;

  Future<Either<DataError, Weather>> getWeatherByCityId(String cityId, {bool forceRemoteFetch = false}) =>
      (!_checkDataValidity() || cityId != _previousCityId || forceRemoteFetch)
          ? _getRemoteWeatherByCityId(cityId)
          : _getLocalWeather();

  Future<Either<DataError, Weather>> _getRemoteWeatherByCityId(String cityId) =>
      _apiService.getWeatherByCityId(cityId).then<Either<DataError, Weather>>((value) {
        _previousCityId = cityId;
        _dbService.insertWeather(value);
        _lastRemoteFetch = DateTime.now();
        return Right(value);
      }).catchError((e) {
        _lastRemoteFetch = DateTime.fromMillisecondsSinceEpoch(0);
        return Left<DataError, Weather>(e.toDataError());
      });

  Future<Either<DataError, Weather>> _getLocalWeather() =>
      _dbService.getWeatherByCityId(_previousCityId!).then((value) =>
          value == null ? (_getRemoteWeatherByCityId(_previousCityId!) as Either<DataError, Weather>) : Right(value));

  bool _checkDataValidity() => DateTime.now().difference(_lastRemoteFetch).inSeconds < 15 ? true : false;
}

extension _DynamicDataErrorExtension on dynamic {
  DataError toDataError() {
    switch (runtimeType) {
      case NoConnectionException:
        return const DataError.noConnection();
      case HttpStatusException:
        return DataError.httpStatus(message: toString());
      case DatabaseException:
        return DataError.db(message: toString());
      default:
        return DataError.generic(message: toString());
    }
  }
}
