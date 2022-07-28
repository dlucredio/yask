import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:yask/database/database.dart';
import 'package:yask/model/yask_model.dart';

const newMatchPageRoute = '/newMatch';

class NewMatchPage extends StatelessWidget {
  const NewMatchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.match),
      ),
      body: const Center(
        child: NewMatchForm(),
      ),
    );
  }
}

class NewMatchForm extends StatefulWidget {
  const NewMatchForm({Key? key}) : super(key: key);

  @override
  State<NewMatchForm> createState() => _NewMatchFormState();
}

class _NewMatchFormState extends State<NewMatchForm> {
  final _formKey = GlobalKey<FormState>();
  late List<String> players;
  final matchNameController = TextEditingController();
  final playerOrTeamController = TextEditingController();
  final initialScoreController = TextEditingController(text: "0");
  late FocusNode matchNameFocusNode;
  late FocusNode playerOrTeamFocusNode;
  late FocusNode initialScoreFocusNode;

  @override
  void initState() {
    super.initState();
    players = [];
    matchNameFocusNode = FocusNode();
    playerOrTeamFocusNode = FocusNode();
    initialScoreFocusNode = FocusNode();
  }

  @override
  void dispose() {
    matchNameController.dispose();
    playerOrTeamController.dispose();
    initialScoreController.dispose();
    matchNameFocusNode.dispose();
    playerOrTeamFocusNode.dispose();
    initialScoreFocusNode.dispose();
    super.dispose();
  }

  void _addPlayerOrTeam(String text) {
    if (playerOrTeamController.text.isEmpty) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        players.add(playerOrTeamController.text);
      });
      playerOrTeamController.text = "";
      playerOrTeamFocusNode.requestFocus();
    }
  }

  void _removePlayerOrTeam(int index) {
    setState(() {
      players.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    const uuid = Uuid();
    final matchId = uuid.v1();

    await DBProvider.db.insertNewYaskMatch(YaskMatch(
        id: matchId,
        startDateTime: DateTime.now(),
        endDateTime: DateTime.now(),
        name: matchNameController.text,
        initialScore: int.parse(initialScoreController.text),
        players: players,
        rounds: []));
  }

  Widget buildMatchNameFormField(BuildContext context) {
    return TextFormField(
      controller: matchNameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,
      autofocus: true,
      onFieldSubmitted: (value) => initialScoreFocusNode.requestFocus(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterSomeText;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.matchName,
      ),
    );
  }

  Widget buildInitialScoreFormField(BuildContext context) {
    return TextFormField(
      controller: initialScoreController,
      focusNode: initialScoreFocusNode,
      keyboardType: TextInputType.number,
      onFieldSubmitted: (value) => playerOrTeamFocusNode.requestFocus(),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.initialScore,
      ),
    );
  }

  Widget buildPlayerNameFormField(BuildContext context) {
    return TextFormField(
      controller: playerOrTeamController,
      focusNode: playerOrTeamFocusNode,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      onFieldSubmitted: _addPlayerOrTeam,
      validator: (value) {
        if (players.contains(value)) {
          return AppLocalizations.of(context)!.playerOrTeamAlreadyExist;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.playerOrTeam,
      ),
    );
  }

  Widget buildPlayersInMatch(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${players.length} ${AppLocalizations.of(context)!.playersOrTeams}",
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        players[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removePlayerOrTeam(index),
                      icon: const Icon(Icons.delete),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: buildMatchNameFormField(context)),
                const SizedBox(
                  width: 10,
                ),
                Expanded(child: buildInitialScoreFormField(context)),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: buildPlayerNameFormField(context),
                ),
                IconButton(
                  onPressed: () => _addPlayerOrTeam(''),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: players.isEmpty
                    ? Text(
                        AppLocalizations.of(context)!.noPlayersOrTeams,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      )
                    : buildPlayersInMatch(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: players.isEmpty
                    ? null
                    : () {
                        _submitForm().then((result) {
                          Navigator.pop(context);
                        });
                      },
                child: Text(AppLocalizations.of(context)!.startMatch),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
