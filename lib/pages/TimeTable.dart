import 'package:flutter/material.dart';
import './EditSubect.dart';
import '../db/Database.dart';
import './Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './SettingData.dart';

class TimeTablePage extends StatefulWidget {
  TimeTablePage(this.sizes);
  final sizes;
  @override
  _TimeTablePageState createState() => new _TimeTablePageState(sizes);
}

class _TimeTablePageState extends State<TimeTablePage> {
  _TimeTablePageState(this.sizes);
  SharedPreferences prefs;
  final sizes;
  List<String> week = ['月', '火', '水', '木', '金', '土'];
  List<TableRow> tableView = [];
  Widget table = Center(
    child: Text('loading...'),
  );
  List<List<Map<String, dynamic>>> cellInfoList;

  Future<int> loadSettings()async{
    prefs = await SharedPreferences.getInstance();
    SettingData.subjectNum=prefs.getInt("subjectNum");
    SettingData.subjectNum??=5;
    SettingData.weekNames.forEach(
            (dayName){
          bool dispBool=prefs.getBool(dayName+'dispBool');
          dispBool??=true;
          SettingData.dispDaysBool.add(dispBool);
        });
    return 0;
  }

  @override
  void initState() {
    loadTimeTable().then((res) {
      setCell();
    });
    super.initState();
  }

  Future<bool> loadTimeTable() async {
    await TimeTableDB.connectDB();
    List<Map<String, dynamic>> subjectInfos = await TimeTableDB.getTableData();
    await loadSettings();

    cellInfoList = new List.generate(
        week.length,
        (i) => List.generate(SettingData.subjectNum, (j) {
//            print('i:'+i.toString());
//            print('j:'+j.toString());
              return {
                'week': '',
                'period': '',
                'subject': '',
                'teacher': '',
                'room': ''
              };
            }));

    subjectInfos.forEach((subInfo) {
      //todo 最初のデータ取得の際、whereを使ってperiodの値がsubjectNum以下のデータのみを取得に変更する
      if(subInfo['period'] - 1<SettingData.subjectNum){
        cellInfoList[week.indexOf(subInfo['week'])][subInfo['period'] - 1] = subInfo;
      }
    });
    return true;
  }

  void setCell() async {
    List<TableRow> tableList = [];
    List<Widget> weekRowList = [];
    weekRowList.add(empCell());
    week.forEach((day) {
      weekRowList.add(weekCell(day));
    });
    tableList.add(TableRow(children: weekRowList));
    //縦のループ
    for (var i = 0; i < SettingData.subjectNum; i++) {
      weekRowList = [];
      weekRowList.add(numCell(i));
      //横のループ
      for (var j = 0; j < week.length; j++) {
        weekRowList.add(subjectCell(
            title: cellInfoList[j][i]['subject'],
            name: cellInfoList[j][i]['teacher'],
            place: cellInfoList[j][i]['room'],
            today: week[j],
            num: i));
      }
      //段を追加
      tableList.add(TableRow(children: weekRowList));
    }
    setState(() {
      table = Table(columnWidths: <int, TableColumnWidth>{
        0: FixedColumnWidth(sizes.width / 15),
        1: FixedColumnWidth(sizes.width / 6.5),
        2: FixedColumnWidth(sizes.width / 6.5),
        3: FixedColumnWidth(sizes.width / 6.5),
        4: FixedColumnWidth(sizes.width / 6.5),
        5: FixedColumnWidth(sizes.width / 6.5),
        6: FixedColumnWidth(sizes.width / 6.5),
      }, children: tableList);
    });
  }

  Widget subjectCell(
      {String title, String name, String place, String today, int num}) {
    return SizedBox(
        height: sizes.height / 7,
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) =>
                        EditSubjectPage(today, (num + 1).toString())))
                .then((value) {
              // todo 画面更新後にsubjectNumのデータの保存、subjectNumと表示曜日を変更した際でSettngDataのboolを分ける？
              if (SettingData.reloadBool) {
                cellInfoList[week.indexOf(SettingData.changedInfoList[0])]
                [int.parse(SettingData.changedInfoList[1]) - 1] = {
                  'week': SettingData.changedInfoList[0],
                  'period': SettingData.changedInfoList[1],
                  'subject': SettingData.changedInfoList[2],
                  'teacher': SettingData.changedInfoList[3],
                  'room': SettingData.changedInfoList[4]
                };
                setState(() {
                  setCell();
                });
                SettingData.reloadBool=false;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    place,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget numCell(int num) {
    return SizedBox(
        height: sizes.height / 7,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue),
          child: Center(
            child: Text(
              (num + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }

  Widget weekCell(String week) {
    return SizedBox(
        height: sizes.height / 30,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue),
          child: Center(
            child: Text(
              week,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }

  Widget empCell() {
    return SizedBox(
        height: sizes.height / 30,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('時間割り'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: (){
                Navigator.of(context)
                    .push(MaterialPageRoute(
                    builder: (context) =>
                        SettingPage()))
                    .then((value) {
//                  print(SettingData.reloadBool.toString());
                  if (SettingData.reloadBool) {
                    prefs.setInt('subjectNum', SettingData.subjectNum);
                    loadTimeTable().then((res) {
                      setState(() {
                        setCell();
                      });
                    });
                    SettingData.reloadBool=false;
                  }
                });
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child:table
        ));
  }
}