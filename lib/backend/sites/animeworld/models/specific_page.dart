import 'package:miru_anime/backend/sites/animeworld/models/anime.dart';
import 'package:miru_anime/backend/sites/animeworld/models/comment.dart';
import 'package:miru_anime/backend/sites/animeworld/models/server.dart';

enum AnimeState {
  undefined,
  toBeRelease,
  finish,
  ongoing
}

class AnimeWorldSpecificAnime {
  final List<AnimeWorldServer> servers;
  final String description;
  final String image;
  final String title;
  final String animeID;
  final List<Anime> simili;
  final List<Anime> correlati;
  final AnimeWorldComment comment;
  final AnimeState state;
  final DetailAnime info;
  final String nextEpisode;

  AnimeWorldSpecificAnime({
    required this.image,
    required this.title,
    required this.animeID,
    required this.comment,
    required this.correlati,
    required this.description,
    required this.info,
    required this.servers,
    required this.simili,
    required this.state,
    required this.nextEpisode
  });
}

class Href {
  final String value;
  final String url;
  Href(this.value, this.url);
}

class DetailAnime {
  final String categoria;
  final Href audio;
  final String releaseDate;
  final Href season;
  final Href studio;
  final Map<String,String> genre;
  final String voto;
  final String durata;
  final String numberEpisode;
  final String views;
  final Href status;


  DetailAnime({
    required this.audio,
    required this.categoria,
    required this.durata,
    required this.genre,
    required this.numberEpisode,
    required this.releaseDate,
    required this.season,
    required this.studio,
    required this.views,
    required this.voto,
    required this.status
  });
}