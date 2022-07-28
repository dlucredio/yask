import 'package:flutter/material.dart';
import 'package:yask/database/database.dart';
import 'package:yask/model/yask_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const matchPageRoute = '/match';

class MatchPage extends StatelessWidget {
  const MatchPage({Key? key}) : super(key: key);

  void _newRound() {}

  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context)!.settings.arguments as String;

    Future<YaskMatch> futureMatch = DBProvider.db.getYaskMatch(matchId);

    return FutureBuilder<YaskMatch>(
      future: futureMatch,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          YaskMatch match = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(match.name),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.duration}: ${match.getFormattedDate(context)}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: RoundsTable(match: match),
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _newRound,
              tooltip: AppLocalizations.of(context)!.newRound,
              child: const Icon(Icons.add),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class RoundsTable extends StatelessWidget {
  final YaskMatch match;
  const RoundsTable({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, List<YaskRound>> rounds = match.getPlayerRounds();
    int numRounds = rounds.entries.first.value.length;
    return DataTable(
      columns: [
        DataColumn(
            label: Text(
          AppLocalizations.of(context)!.name,
        )),
        ...List.generate(numRounds, (index) => index + 1)
            .map(
              (i) => DataColumn(
                label: Text('$i'),
              ),
            )
            .toList()
      ],
      rows: rounds.entries
          .map((playerRounds) => DataRow(cells: [
                DataCell(Text(playerRounds.key)),
                ...playerRounds.value
                    .map((r) => DataCell(Text('${r.score}')))
                    .toList()
              ]))
          .toList(),
    );
  }
}
