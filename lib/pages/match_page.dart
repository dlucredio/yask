import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yask/custom_theme.dart';
import 'package:yask/database/database.dart';
import 'package:yask/model/yask_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yask/pages/new_round_page.dart';

const matchPageRoute = '/match';

const matchTableBorderColor = Colors.white;
const matchTableHeaderColor = Colors.indigo;
const matchTableHeaderTextColor = Colors.white;
const matchTableDataColor = Colors.black;
const matchTableDataTextColor = Colors.white;
const matchTableTotalScoreTextColor = Colors.amber;

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late Future<YaskMatch> futureMatch;

  @override
  void initState() {
    super.initState();
  }

  void _newRound(BuildContext context, String matchId) {
    Navigator.pushNamed(context, newRoundPageRoute, arguments: matchId)
        .then((value) => {
              setState(() {
                futureMatch = DBProvider.db.getYaskMatch(matchId);
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context)!.settings.arguments as String;

    futureMatch = DBProvider.db.getYaskMatch(matchId);

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
                padding: CustomTheme.defaultPageInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.duration}: ${match.getFormattedDate(context)}",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: CustomTheme.getDefaultTitleText(
                          AppLocalizations.of(context)!.overallScore),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(children: [
                          FixedColumnWidget(match: match),
                          ScrollableColumnWidget(match: match)
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _newRound(context, matchId),
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

class FixedColumnWidget extends StatelessWidget {
  final YaskMatch match;

  const FixedColumnWidget({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 10,
      horizontalMargin: 5,
      headingRowColor: MaterialStateProperty.all(matchTableHeaderColor),
      dataRowColor: MaterialStateProperty.all(matchTableHeaderColor),
      border: TableBorder.all(
        color: matchTableBorderColor,
        width: 1,
      ),
      columns: [
        DataColumn(
          label: Expanded(
            child: Text(
              AppLocalizations.of(context)!.name,
              textAlign: TextAlign.right,
              style: const TextStyle(color: matchTableHeaderTextColor),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              AppLocalizations.of(context)!.total,
              textAlign: TextAlign.center,
              style: const TextStyle(color: matchTableHeaderTextColor),
            ),
          ),
        ),
      ],
      rows: [
        ...match.players.map((player) => DataRow(
              cells: [
                DataCell(
                  Container(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      player,
                      style: const TextStyle(color: matchTableHeaderTextColor),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      NumberFormat('########.#')
                          .format(match.getPlayerScore(player)),
                      style: const TextStyle(
                        color: matchTableTotalScoreTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaleFactor: 1.5,
                    ),
                  ),
                ),
              ],
            ))
      ],
    );
  }
}

class ScrollableColumnWidget extends StatelessWidget {
  final YaskMatch match;

  const ScrollableColumnWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    Map<String, List<YaskRound>> rounds = match.getPlayerRounds();
    int numRounds = rounds.entries.first.value.length;
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 10,
            headingRowColor: MaterialStateProperty.all(matchTableHeaderColor),
            dataRowColor: MaterialStateProperty.all(matchTableDataColor),
            border: TableBorder.all(
              color: matchTableBorderColor,
              width: 1,
            ),
            columns: List.generate(
              numRounds,
              (index) => DataColumn(
                label: Expanded(
                  child: Text(
                    '$index',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: matchTableHeaderTextColor),
                  ),
                ),
              ),
            ),
            rows: [
              ...match.players.map((player) => DataRow(
                    cells: rounds[player]!
                        .map(
                          (round) => DataCell(
                            Container(
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                NumberFormat('########.#').format(round.score),
                                style: const TextStyle(
                                    color: matchTableDataTextColor),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ))
            ]),
      ),
    );
  }
}
