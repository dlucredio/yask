import 'package:flutter/material.dart';
import 'package:yask/custom_theme.dart';
import 'package:yask/database/database.dart';
import 'package:yask/model/yask_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yask/pages/new_round_page.dart';

const matchPageRoute = '/match';

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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
                        child: SingleChildScrollView(
                          child: RoundsTable(match: match),
                        ),
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

class RoundsTable extends StatelessWidget {
  final YaskMatch match;
  const RoundsTable({Key? key, required this.match}) : super(key: key);

  TableCell buildTableCell(String text, TextAlign textAlign) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          text,
          textAlign: textAlign,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<YaskRound>> rounds = match.getPlayerRounds();
    int numRounds = rounds.entries.first.value.length;

    final firstRowCells = List.generate(numRounds, (index) => index + 1)
        .map((i) => buildTableCell('$i', TextAlign.center))
        .toList();

    final firstRow = TableRow(
      children: <TableCell>[
        buildTableCell(AppLocalizations.of(context)!.name, TextAlign.right),
        ...firstRowCells
      ],
    );

    final dataRows = <TableRow>[];
    for (var entry in rounds.entries) {
      final roundCells = entry.value
          .map((r) => buildTableCell('${r.score}', TextAlign.center));
      final playerRow = TableRow(children: <TableCell>[
        buildTableCell(entry.key, TextAlign.right),
        ...roundCells
      ]);
      dataRows.add(playerRow);
    }

    return Table(
      border: TableBorder.all(color: Colors.white),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: <TableRow>[firstRow, ...dataRows],
    );
  }
}
