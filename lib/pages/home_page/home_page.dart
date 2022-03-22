import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru_anime/backend/database/anime_saved.dart';
import 'package:miru_anime/backend/database/store.dart';
import 'package:miru_anime/backend/sites/animeworld/models/anime.dart';
import 'package:miru_anime/backend/sites/animeworld/models/home_page.dart';
import 'package:miru_anime/backend/sites/animeworld/scraper.dart';
import 'package:miru_anime/constants/app_colors.dart';
import 'package:miru_anime/objectbox.g.dart';
import 'package:miru_anime/widgets/app_scaffold.dart';
import 'package:miru_anime/widgets/default_error_page.dart';
import 'package:miru_anime/widgets/gallery/thumbnail_title_anime.dart';
import 'package:miru_anime/widgets/gallery/thumbnail_with_badge.dart';
import 'package:miru_anime/widgets/gallery/thumbnail_with_bottom_badge.dart';
import 'package:miru_anime/widgets/shimmer_box.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  static const route = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static Future<AnimeWorldHomePage>? _data;
  final PageController _pageController = PageController();
  int _activeTab = 0;
  bool _isEmpty = true;
  late final StreamSubscription<Query<AnimeDatabase>> _sub;
  List<Anime> _userList = <Anime>[];

  @override
  void initState() {
    super.initState();
    _data ??= AnimeWorldScraper().getHomePage();
    _sub = ObjectBox.store.box<AnimeDatabase>().query(
        AnimeDatabase_.userFinishedToWatch.equals(false)
    ).watch(triggerImmediately: true).listen((event) {
      final list = (event.find()..sort((final a, final b) => b.time.compareTo(a.time)))
          .map((e) => Anime.fromDatabase(e)).toList();
      setState(() {
        _userList = list;
        _isEmpty = list.isEmpty;
      });
    });
    Connectivity().checkConnectivity().then((value) {
      if(value == ConnectivityResult.none) {
        showDialog(context: context, builder: (_) =>
            AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              backgroundColor: AppColors.white,
              contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20),
              title: const Text(
                'Sembra che non sei connesso ad internet!',
                style: TextStyle(
                  color: AppColors.functionalred,
                  fontWeight: FontWeight.w600,
                  letterSpacing: double.minPositive,
                  fontFamily: 'Montserrat',
                ),
              ),
              content: CupertinoScrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('La tua connessione ad internet ha fallito, quindi probabilmente visualizzerai un messaggio di errore, controlla di essere connesso al '
                          'WiFi oppure di avere attivato la connessione dati. Dopo aver controllato puoi aggiornare la pagina home trascindo verso di te la pagina '
                          'finchè non comparirà un indicatore.',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black)
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  //highlightColor: alphaAccent,
                  //splashColor: alphaAccent,
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            )
        );
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      route: HomePage.route,
      child: RefreshIndicator(
        color: AppColors.purple,
        backgroundColor: AppColors.darkBlue,
        onRefresh: () async {
          _data = AnimeWorldScraper().getHomePage();
          setState(() {});
        },
        child: FutureBuilder<AnimeWorldHomePage>(
          future: _data,
          builder: (final _, final snap) {
            switch (snap.connectionState) {
              case ConnectionState.done:
                return snap.hasError ? DefaultErrorPage(error: snap.error.toString()) : _successfulWidget(snap.data!);
              default:
                return _shimmerWidget();
            }
          },
        ),
      )
    );
  }

  Widget _successfulWidget(final AnimeWorldHomePage data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          _customTitle('Top Anime'),
          _selectTop(),
          _topAnime(data.topAnime),
          _customTitle('Raccomandati'),
          _swiper(data.sliders),
          Visibility(
            visible: !_isEmpty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _customTitle('Continua a guardare'),
                _animeListViewWithBadge(_userList),
              ],
            ),
          ),
          _customTitle('In tendenza'),
          _animeListViewWithBadge(data.trending),
          _customTitle('In corso'),
          _animeListViewWithBadge(data.ongoing),
          _customTitle('Ultimi episodi'),
          _animeListViewWithBadge(data.all),
          _customTitle('Sub ITA'),
          _animeListViewWithBadge(data.subITA),
          _customTitle('Doppiati ITA'),
          _animeListViewWithBadge(data.dubbed),
          _customTitle('Nuove aggiunte'),
          _animeListView(data.newAdded),
          _customTitle(data.upcomingTitle),
          _animeListView(data.upcoming)
        ],
      ),
    );
  }

  Widget _swiper(final List<Anime> list) {
    return SizedBox(
      height: 200,
      child: Swiper(
        itemBuilder: (context, index) {
          final anime = list[index];
          return ThumbnailWithTitle(
            title: anime.title,
            image: anime.thumbnail,
            urlAnime: anime.link,
            width: 340,
            height: 140,
          );
        },
        itemHeight: 200,
        itemWidth: 340,
        itemCount: list.length,
        scale: 0.7,
      ),
    );
  }

  Widget _topAnime(final List<List<Anime>> data) {
    Widget _rankedAnime(final List<Anime> list){
      return Column(
        children: [
          ThumbnailWithBadge(
            title: list.first.title,
            thumbnail: list.first.thumbnail,
            link: list.first.link,
            width: MediaQuery.of(context).size.width * 0.85,
            height: 210,
            rank: list.first.rank!,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: 270
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: list.length - 1,
                itemBuilder: (_, index) {
                  final anime = list[index+1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ThumbnailWithBadge(
                      rank: anime.rank!,
                      thumbnail: anime.thumbnail,
                      link: anime.link,
                      title: anime.title,
                    )
                  );
                },
              )
          ),
        ],
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 560),
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (final page) {
          setState(() => _activeTab = page);
        },
        children: [
          Column(
            children: [
              _rankedAnime(data[0]),
              //const Padding(padding: const EdgeInsets.symmetric(vertical: 30.0),),
            ],
          ),
          Column(
            children: [
              _rankedAnime(data[1]),
              //const Padding(padding: const EdgeInsets.symmetric(vertical: 30.0),),
            ],
          ),
          Column(
            children: [
              _rankedAnime(data[2]),
              //const Padding(padding: const EdgeInsets.symmetric(vertical: 30.0),),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectTop(){
    Widget _tab(final String label, final int tabNum, final double tabWidth){
      final bool _isDisable = _activeTab != tabNum;
      return GestureDetector(
        onTap: () async => await _pageController.animateToPage(
          tabNum,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        ),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: !_isDisable ? BoxDecoration(
              border: Border.all(
                  color: AppColors.purple,
                width: 2
              ),
              borderRadius: BorderRadius.circular(50)
          ) : const BoxDecoration(),
          child: Text(
            label,
            style: TextStyle(
              color: _isDisable
                  ? AppColors.grey
                  : AppColors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _tab('Today',0,45.0),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),
          _tab('Week',1,80.0),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),
          _tab('Month',2,50.0),
        ],
      ),
    );
  }

  Widget _customTitle(final String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline5!.apply(
          color: AppColors.purple
        ),
      ),
    );
  }

  Widget _animeListView(final List<Anime> list) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          maxHeight: 290
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (_, index) {
          final anime = list[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ThumbnailWithTitle(
              title: anime.title,
              image: anime.thumbnail,
              urlAnime: anime.link,
            ),
          );
        },
      ),
    );
  }
  
  Widget _animeListViewWithBadge(final List<Anime> list) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 290
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (_, index) {
          final anime = list[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ThumbnailBottomBadge(
              title: anime.title,
              thumbnail: anime.thumbnail,
              link: anime.link,
              badge: anime.info!,
            ),
          );
        },
      ),
    );
  }

  Widget _shimmerWidget() {
    Widget _row() {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 260
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (_,__){
            return const ShimmerBox(
              height: 225,
              width: 155
            );
          },
        ),
      );
    }
    Widget _title() {
      return const Padding(
        padding: EdgeInsets.only(left: 8.0,top: 10, bottom: 10),
        child: ShimmerBox(
          width: 200,
          height: 20,
        ),
      );
    }
    return ListView(
      children: [
        _title(),
        Shimmer.fromColors(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.grey
              ),
            ),
          ),
          baseColor: AppColors.baseColor,
          highlightColor: AppColors.highlightColor),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        _row(),
        _title(),
        _row(),
        _title(),
        _row()
      ],
    );
  }

}
