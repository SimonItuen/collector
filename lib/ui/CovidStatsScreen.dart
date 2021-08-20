import 'package:collector/providers/database_provider.dart';
import 'package:collector/repo/covid_stats_manager.dart';
import 'package:collector/repo/todo_list_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class CovidStatsScreen extends StatefulWidget {
  const CovidStatsScreen({Key? key}) : super(key: key);

  @override
  _CovidStatsScreenState createState() => _CovidStatsScreenState();
}

class _CovidStatsScreenState extends State<CovidStatsScreen> {
  TextEditingController searchEditingController =
      TextEditingController(text: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRandomData();
  }

  void getRandomData() async {
    await DBProvider.db.database;
    CovidStatsModel model =
        await CovidStatsManager().getRandomCountryCovidData(context);
    DBProvider.db.insertStats(model);
    searchEditingController.text = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.coronavirus_outlined),
              Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
              Text('Covid Stats'),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  getRandomData();
                },
                icon: Icon(Icons.add_location_alt))
          ],
        ),
        body: Column(
          children: [
            TextFormField(
              onChanged: (value) async {
                setState(() {});
              },
              controller: searchEditingController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                  hintText: 'Search a country or region',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                  ),
                  fillColor: Color(0xFFF2F2F2)),
            ),
            Expanded(
              child: FutureBuilder<List<CovidStatsModel>>(
                future: DBProvider.db
                    .covidStatsList(country: searchEditingController.text),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CovidStatsModel>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        CovidStatsModel model =
                            ((snapshot.data) as List<CovidStatsModel>)[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                model.country,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  'Confirmed Cases: ${NumberFormat('#,###').format(model.totalConfirmedCases).toString()}'),
                              Text(
                                  'Recovered Cases: ${NumberFormat('#,###').format(model.totalRecoveredCases).toString()}'),
                              Text(
                                  'Deaths Cases: ${NumberFormat('#,###').format(model.totalDeaths).toString()}'),
                            ],
                          ),
                          leading: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'flags/${model.isoCode.toLowerCase()}.png',
                                  package: 'country_code_picker',
                                  height: 40,
                                  fit: BoxFit.fill,
                                ),
                              )),
                          trailing: IconButton(
                            onPressed: () {
                              DBProvider.db.deleteStats(model.isoCode);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.remove_circle,
                              color:
                                  Theme.of(context).errorColor.withOpacity(0.6),
                            ),
                          ),
                        );
                      }, separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Divider(),
                        );
                    },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ));
  }
}
