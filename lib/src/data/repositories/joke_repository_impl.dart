import 'dart:convert';

import 'package:FunnyShorts/src/constants.dart';
import 'package:FunnyShorts/src/core/result.dart';
import 'package:FunnyShorts/src/data/data_sources/remote_data_source.dart';
import 'package:FunnyShorts/src/data/models/joke_model.dart';
import 'package:FunnyShorts/src/domain/entities/joke.dart';
import 'package:FunnyShorts/src/domain/repositories/joke_repository.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JokeRepositoryImpl implements JokeRepository {
  JokeRepositoryImpl(this.remoteDataSource, this.sharedPreferences);
  final RemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences; // Add shared preferences

  // Fetch a joke from the API
  @override
  Future<Result<Joke>> fetchJoke() async {
    try {
      final jokeModel = await remoteDataSource.fetchJoke();
      final joke =
          JokeModel.fromJson(jsonDecode(jokeModel) as Map<String, dynamic>);
      return Success(data: Joke(joke.joke));
    } on ClientException {
      return const Failure(
        exception:
            'Unable to fetch joke, make sure you are connected to the internet',
      );
    } on Exception catch (exception) {
      return Failure(exception: exception.toString());
    } catch (e) {
      return Failure(exception: 'Failed to fetch joke: $e');
    }
  }

  // Load saved jokes from shared preferences
  @override
  Future<Result<List<Joke>>> getSavedJokes() async {
    try {
      final jokeTexts = sharedPreferences.getStringList(Constants.jokeListKey);
      if (jokeTexts != null) {
        final jokes = jokeTexts.map(Joke.new).toList();
        return Success(data: jokes);
      }
      return const Success(data: []);
    } catch (e) {
      return Failure(exception: 'Failed to load saved jokes: $e');
    }
  }

  // Save jokes to shared preferences
  @override
  Future<Result<void>> saveJokes(List<Joke> jokes) async {
    try {
      final jokeTexts = jokes.map((joke) => joke.text).toList();
      await sharedPreferences.setStringList(Constants.jokeListKey, jokeTexts);
      return const Success();
    } catch (e) {
      return Failure(exception: 'Failed to save joke: $e');
    }
  }

  // Clear all jokes from shared preferences
  @override
  Future<Result<void>> clearAllJokes() async {
    try {
      await sharedPreferences.clear();
      return const Success();
    } catch (e) {
      return Failure(exception: 'Failed to clear jokes: $e');
    }
  }
}
