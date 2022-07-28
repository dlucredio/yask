import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:yask/database/database.dart';
import 'package:yask/model/yask_model.dart';
import 'package:yask/pages/new_match_page.dart';

const mainPageRoute = '/';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<YaskMatch>> matches;

  @override
  void initState() {
    super.initState();
    setState(() {
      matches = DBProvider.db.getAllYaskMatches();
    });
  }

  void _newMatch() {
    Navigator.pushNamed(context, newMatchPageRoute).then((_) {
      setState(() {
        matches = DBProvider.db.getAllYaskMatches();
      });
    });
  }

  Future<void> _deleteMatch(YaskMatch match) async {
    await DBProvider.db.deleteYaskMatch(match);
    setState(() {
      matches = DBProvider.db.getAllYaskMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Center(
        child: FutureBuilder<List<YaskMatch>>(
          future: matches,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return MatchesList(
                matches: snapshot.data!,
                deleteMatchCallback: _deleteMatch,
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newMatch,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MatchesList extends StatelessWidget {
  final List<YaskMatch> matches;
  final void Function(YaskMatch match) deleteMatchCallback;
  const MatchesList(
      {Key? key, required this.matches, required this.deleteMatchCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "${DateFormat.yMEd().format(matches[index].dateTime)}"
                        " "
                        "${DateFormat.jm().format(matches[index].dateTime)}",
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 0.8)
                            .apply(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        matches[index].name,
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 1.5)
                            .apply(fontWeightDelta: 2),
                      ),
                      Text(
                        matches[index].players.join(', '),
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => deleteMatchCallback(matches[index]),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}
