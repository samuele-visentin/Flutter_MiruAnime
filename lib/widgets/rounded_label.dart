import 'package:flutter/material.dart';
import 'package:miru_anime/constants/app_colors.dart';

class RoundedLabel extends StatelessWidget {
  final String name;
  const RoundedLabel({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.purple.withOpacity(0.7),
          borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Center(child: Text(name, style: Theme.of(context).textTheme.bodyText1,)),
    );
  }
}
