import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget{
  @override
  _SettingPageState createState()=>new _SettingPageState();

}

class _SettingPageState extends State<SettingPage>{
  SharedPreferences prefs;
  List<String> week = ['日','月', '火', '水', '木', '金', '土'];
  List<String> weekNames=['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  List<bool> dispDaysBool=[];
  List<Widget> checkBoxForm=[];
  bool allDaybool=false;

  @override
  void initState() {
    setCheckBox();
    super.initState();
  }

  void setCheckBox()async{
    prefs = await SharedPreferences.getInstance();
    weekNames.forEach(
            (dayName){
              bool dispBool=prefs.getBool(dayName+'dispBool');
              dispBool=true;
              dispDaysBool.add(dispBool);
    });

    List<Widget> _checkBoxForm=[];
    for(var i=0;i<week.length;i++){
      _checkBoxForm.add(checkboxWidget(i));
    }
    setState(() {
      checkBoxForm=_checkBoxForm;
    });
  }

  Widget checkboxWidget(int dayNum){
    bool _dispBool=dispDaysBool[dayNum];
    return CheckboxListTile(
      title: Text(week[dayNum]+"曜日"),
      value: allDaybool,
      onChanged: (changedValue)async{
        prefs.setBool(weekNames[dayNum], changedValue);
        setState(() {
          print(changedValue.toString());
          allDaybool=changedValue;
          dispDaysBool[dayNum]=changedValue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("設定"),
      ),
      body: Column(
        children: checkBoxForm
            //todo:saveButtonの設置、保存処理のあとNavigator.popでtimeTable.dartに曜日のデータを渡す.その後のtimeTable側での画面更新　
      ),
    );
  }
}