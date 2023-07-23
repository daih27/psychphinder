import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/widgets/itemlist.dart';
import 'global/globals.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List data = csvData.data;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box("favorites").listenable(),
              builder: (BuildContext context, dynamic box, Widget? child) {
                final favorites = box.values.toList();
                return ItemList(lines: favorites, data: data);
              },
            ),
          ),
        ],
      ),
    );
  }
}
