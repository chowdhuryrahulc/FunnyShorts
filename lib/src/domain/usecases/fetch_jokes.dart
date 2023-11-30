import 'package:FunnyShorts/src/core/result.dart';
import 'package:FunnyShorts/src/domain/entities/joke.dart';
import 'package:FunnyShorts/src/domain/repositories/joke_repository.dart';

// FetchJokes is a class used to fetch jokes from the repository.
class FetchJokes {
  FetchJokes(this.repository);
  final JokeRepository repository;

  Future<Result<Joke>> call() async {
    final res = await repository.fetchJoke();
    return res;
  }
}
