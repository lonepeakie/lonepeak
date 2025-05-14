import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';

class EstateTile extends StatelessWidget {
  final Estate estate;
  final Function()? onTap;

  const EstateTile({super.key, required this.estate, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(estate.name, style: AppStyles.titleTextSmall),
      subtitle: Text(
        '${estate.address!.isEmpty ? "" : "${estate.address}, "}${estate.city}, ${estate.county}',
      ),
      onTap: onTap,
    );
  }
}
