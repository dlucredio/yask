import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yask/custom_theme.dart';
import 'package:yask/database/database.dart';
import 'package:yask/model/yask_model.dart';
import 'package:yask/pages/match_page.dart';

const newRoundPageRoute = "$matchPageRoute/newRoundPage";

class NewRoundPage extends StatelessWidget {
  const NewRoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newRound),
      ),
      body: Center(
        child: NewRoundForm(
          matchId: matchId,
        ),
      ),
    );
  }
}

class NewRoundForm extends StatefulWidget {
  final String matchId;
  const NewRoundForm({Key? key, required this.matchId}) : super(key: key);

  @override
  State<NewRoundForm> createState() => _NewRoundFormState();
}

class _NewRoundFormState extends State<NewRoundForm> {
  final Map<String, TextEditingController> playerScoreControllers = {};
  final Map<String, FocusNode> playerScoreFocusNodes = {};

  @override
  void dispose() {
    for (var controller in playerScoreControllers.values) {
      controller.dispose();
    }
    for (var focusNode in playerScoreFocusNodes.values) {
      focusNode.dispose();
    }
    playerScoreControllers.clear();
    playerScoreFocusNodes.clear();
    super.dispose();
  }

  bool validate() {
    for (var controller in playerScoreControllers.values) {
      if (double.tryParse(controller.text) == null) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _submitForm(String matchId) async {
    if (!validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorInPlayerScores),
      ));
      return Future.value(false);
    }
    DateTime now = DateTime.now();
    for (var e in playerScoreControllers.entries) {
      final score = double.parse(e.value.text);
      await DBProvider.db.insertNewYaskRound(
          matchId,
          YaskRound(
            dateTime: now,
            playerName: e.key,
            score: score,
          ));
    }
    return Future.value(true);
  }

  Widget buildNewRoundForm(BuildContext context, YaskMatch match) {
    final rows = <TableRow>[];
    for (String player in match.players) {
      playerScoreControllers[player] = TextEditingController();
      playerScoreFocusNodes[player] = FocusNode();
    }
    for (var i = 0; i < match.players.length; i++) {
      final player = match.players[i];
      rows.add(TableRow(
        children: <TableCell>[
          TableCell(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                player,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          TableCell(
            child: TextFormField(
              controller: playerScoreControllers[player],
              focusNode: playerScoreFocusNodes[player],
              autofocus: i == 0,
              keyboardType: TextInputType.number,
              onFieldSubmitted: i < match.players.length - 1
                  ? (value) {
                      playerScoreFocusNodes[match.players[i + 1]]
                          ?.requestFocus();
                    }
                  : null,
            ),
          )
        ],
      ));
    }

    return Padding(
      padding: CustomTheme.defaultPageInsets,
      child: Column(children: [
        CustomTheme.getDefaultTitleText(
            AppLocalizations.of(context)!.enterPlayerScores),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: rows,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ElevatedButton(
            onPressed: () {
              _submitForm(match.id).then((result) {
                if (result) {
                  Navigator.pop(context);
                }
              });
            },
            child: Text(AppLocalizations.of(context)!.saveScores),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchId = widget.matchId;
    Future<YaskMatch> futureMatch = DBProvider.db.getYaskMatch(matchId);

    return FutureBuilder<YaskMatch>(
      future: futureMatch,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildNewRoundForm(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
