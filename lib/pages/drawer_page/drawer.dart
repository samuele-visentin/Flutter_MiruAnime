import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miru_anime/backend/sites/animeworld/anime_section.dart';
import 'package:miru_anime/constants/app_colors.dart';
import 'package:miru_anime/pages/advance_search/advance_search.dart';
import 'package:miru_anime/pages/categorie_page/categorie_page.dart';
import 'package:miru_anime/pages/genre_page/genre_page.dart';
import 'package:miru_anime/pages/home_page/home_page.dart';
import 'package:miru_anime/pages/news_page/news_page.dart';
import 'package:miru_anime/pages/specific_page/specific_anime.dart';
import 'package:miru_anime/pages/upcoming_page/upcoming_page.dart';
import 'package:miru_anime/pages/user_list_page/user_anime_list.dart';

class AppDrawerMenu extends StatefulWidget {
  final String route;
  const AppDrawerMenu({Key? key, required this.route}) : super(key: key);

  @override
  State<AppDrawerMenu> createState() => _AppDrawerMenuState();
}

class _AppDrawerMenuState extends State<AppDrawerMenu> {
  
  late String currentRoute;
  
  @override
  void initState() {
    super.initState();
    currentRoute = widget.route;
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent
          ),
          child: ListView(
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 2),),
              _tileDrawer(
                name: 'Home',
                route: HomePage.route,
                icon: FontAwesomeIcons.house,
              ),
              _tileDrawer(
                name: 'La mia lista',
                route: UserAnimeListPage.route,
                icon: FontAwesomeIcons.folderOpen
              ),
              _tileDrawer(
                name: 'Nuove aggiunte',
                route: AnimeSection.newAdded.route,
                icon: FontAwesomeIcons.plus,
              ),
              _tileDrawer(
                name: 'Ultimi episodi',
                route: AnimeSection.last.route,
                icon: FontAwesomeIcons.tv
              ),
              _tileDrawer(
                name: 'Anime in corso',
                icon: FontAwesomeIcons.spinner,
                route: AnimeSection.ongoing.route,
              ),
              _tileDrawer(
                name: 'Generi',
                icon: FontAwesomeIcons.barsStaggered,
                route: GenrePage.route,
              ),
              _tileDrawer(
                name: 'Categorie',
                icon: FontAwesomeIcons.listUl,
                route: CategoriesPage.route,
              ),
              _tileDrawer(
                name: 'Ricerca avanzata',
                icon: FontAwesomeIcons.magnifyingGlassPlus,
                route: AdvanceSearch.route,
              ),
              _tileDrawer(
                name: 'Prossime uscite',
                icon: FontAwesomeIcons.bullhorn,
                route: UpcomingPage.route,
              ),
              _tileDrawer(
                name: 'News',
                icon: FontAwesomeIcons.newspaper,
                route: NewsPage.route,
              ),
              _tileDrawer(
                name: 'Casuale',
                icon: FontAwesomeIcons.shuffle,
                route: SpecificAnimePage.randomAnimeRoute,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _tileDrawer({
    required final String name,
    required final String route,
    required final IconData icon
  }) {
    if (currentRoute == route) {
      return Container(
        decoration: const BoxDecoration(
            border: Border(
                right: BorderSide(color: AppColors.purple, width: 5))),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.20),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18)),
            ),
            child: ListTile(
              onTap: () => Navigator.of(context).pop(),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              title: Text(name,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white)
              ),
              leading: FaIcon(
                icon,
                size: 20,
                color: AppColors.purple,
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: (){
          setState(() {
            currentRoute = route;
          });
          if(route == HomePage.route) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.of(context).popAndPushNamed(route);
          }
        },
        title: Text(name,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white)
        ),
        leading: FaIcon(
          icon,
          size: 20,
          color: AppColors.purple,
        ),
      ),
    );
  }
}


