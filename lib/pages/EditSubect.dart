import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/Database.dart';

class EditSubjectPage extends StatefulWidget {
  EditSubjectPage(this.week, this.num);
  final String week;
  final String num;
  @override
  _EditSubjectPageState createState() => new _EditSubjectPageState(week, num);
}

class _EditSubjectPageState extends State<EditSubjectPage> {
  _EditSubjectPageState(this.week, this.num);
  final editorFormKey = new GlobalKey<_EditorFormState>();
  final String week;
  final String num;

  List<String> getInputData() {
    return editorFormKey.currentState.getInputData();
  }

  bool checkDataExist() {
    return editorFormKey.currentState.dataExist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(week + '曜' + num + '限目'),
      ),
      body: ListView(
        children: <Widget>[
          EditorForm(week, num, key: editorFormKey),
          SaveButtonForm(week, num, getInputData, checkDataExist),
        ],
      ),
    );
  }
}

class SaveButtonForm extends StatefulWidget {
  SaveButtonForm(this.week, this.num, this.getInputData, this.checkDataExist);
  final String week;
  final String num;
  final Function getInputData;
  final Function checkDataExist;
  @override
  _SaveButtonFormState createState() =>
      new _SaveButtonFormState(week, num, getInputData, checkDataExist);
}

class _SaveButtonFormState extends State<SaveButtonForm> {
  _SaveButtonFormState(
      this.week, this.num, this.getInputData, this.checkDataExist);
  final String week;
  final String num;
  final Function getInputData;
  final Function checkDataExist;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Center(
        child: RaisedButton(
            child: Text('Save'),
            onPressed: () async {
              List<String> subjectInfo = [week, num] + getInputData();
              if (checkDataExist()) {
                TimeTableDB.updateData(
                    week: subjectInfo[0],
                    period: subjectInfo[1],
                    subject: subjectInfo[2],
                    teacher: subjectInfo[3],
                    room: subjectInfo[4]);
              } else {
                await TimeTableDB.insertData(
                    week: subjectInfo[0],
                    period: subjectInfo[1],
                    subject: subjectInfo[2],
                    teacher: subjectInfo[3],
                    room: subjectInfo[4]);
              }
              Navigator.pop(context, subjectInfo);
            }),
      ),
    );
  }
}

class EditorForm extends StatefulWidget {
  const EditorForm(this.week, this.num, {Key key}) : super(key: key);
  final String week;
  final String num;
  @override
  _EditorFormState createState() => new _EditorFormState(week, num);
}

class _EditorFormState extends State<EditorForm> {
  _EditorFormState(this.week, this.period);
  final String week;
  final String period;
  SharedPreferences prefs;
  TextEditingController subjectTxtCtrl = TextEditingController();
  TextEditingController teacherTxtCtrl = TextEditingController();
  TextEditingController roomTxtCtrl = TextEditingController();
  bool dataExist = false;

  @override
  void initState() {
    super.initState();
    setSubjectInfo();
  }

  void setSubjectInfo() async {
    List<Map<String, dynamic>> subjectInfo =
        await TimeTableDB.searchData(week, period);
    if (subjectInfo.length != 0) {
      dataExist = true;
      subjectTxtCtrl.text = subjectInfo[0]['subject'];
      teacherTxtCtrl.text = subjectInfo[0]['teacher'];
      roomTxtCtrl.text = subjectInfo[0]['room'];
    }
  }

  Widget editorTile(String title, TextEditingController txtCtrl) {
    return ListTile(
        title: Row(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width / 2, child: Text(title)),
        Expanded(
          child: TextField(
            controller: txtCtrl,
          ),
        ),
      ],
    ));
  }

  List<String> getInputData() {
    return [subjectTxtCtrl.text, teacherTxtCtrl.text, roomTxtCtrl.text];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        editorTile('科目名', subjectTxtCtrl),
        editorTile('講師名', teacherTxtCtrl),
        editorTile('教室名', roomTxtCtrl)
      ],
    );
  }
}
