import 'package:flutter/material.dart';
import './EditSubect.dart';
import '../db/Database.dart';
import './Settings.dart';

class TimeTablePage extends StatefulWidget {
  TimeTablePage(this.sizes);
  final sizes;
  @override
  _TimeTablePageState createState() => new _TimeTablePageState(sizes);
}

class _TimeTablePageState extends State<TimeTablePage> {
  _TimeTablePageState(this.sizes);
  final sizes;
  List<String> week = ['月', '火', '水', '木', '金', '土'];
  List<TableRow> tableView = [];
  Widget table = Center(
    child: Text('loading...'),
  );
  List<List<Map<String, dynamic>>> cellInfoList;
  int subjectNum = 7;

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

    cellInfoList = new List.generate(
        week.length,
        (i) => List.generate(subjectNum, (j) {
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
      cellInfoList[week.indexOf(subInfo['week'])][subInfo['period'] - 1] =
          subInfo;
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
    for (var i = 0; i < subjectNum; i++) {
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
                .then((changedInfoList) {
              if (changedInfoList != null) {
                cellInfoList[week.indexOf(changedInfoList[0])]
                [int.parse(changedInfoList[1]) - 1] = {
                  'week': changedInfoList[0],
                  'period': changedInfoList[1],
                  'subject': changedInfoList[2],
                  'teacher': changedInfoList[3],
                  'room': changedInfoList[4]
                };
                setState(() {
                  setCell();
                  print(week.indexOf(changedInfoList[0]));
                });
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
                    .then((changedInfoList) {
                  if (changedInfoList != null) {
//                    setState(() {
//                      setCell();
//                    });
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