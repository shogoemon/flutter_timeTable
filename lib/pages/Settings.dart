import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import './SettingData.dart';

class SettingPage extends StatefulWidget{
  @override
  _SettingPageState createState()=>new _SettingPageState();
}

class _SettingPageState extends State<SettingPage>{
  SharedPreferences prefs;
  List<Widget> checkBoxForm=[];

  @override
  void initState() {
    setCheckBox();
    super.initState();
  }

  void setCheckBox()async{
    prefs = await SharedPreferences.getInstance();

    List<Widget> _checkBoxForm=[];
    for(var i=0;i<SettingData.week.length;i++){
      _checkBoxForm.add(checkboxWidget(i));
    }
    setState(() {
      checkBoxForm=_checkBoxForm;
    });
  }

  Widget checkboxWidget(int dayNum){
    bool _dispBool=SettingData.dispDaysBool[dayNum];
    return CheckboxListTile(
      title: Text(SettingData.week[dayNum]+"曜日"),
      value: _dispBool,
      onChanged: (changedValue)async{
        prefs.setBool(SettingData.weekNames[dayNum], changedValue);
        setState(() {
          //print("value:"+changedValue.toString());
          _dispBool=changedValue;
          SettingData.dispDaysBool[dayNum]=changedValue;
          checkBoxForm[dayNum]=checkboxWidget(dayNum);
          prefs.setBool(SettingData.weekNames[dayNum]+'dispBool',changedValue);
          SettingData.reloadBool=true;
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
        children: <Widget>[
          ListTile(
            title: Text(
                "「表示する曜日」",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Column(
              children: checkBoxForm
            //todo:saveButtonの設置、保存処理のあとNavigator.popでtimeTable.dartに曜日のデータを渡す.その後のtimeTable側での画面更新　
          ),
          ListTile(
            title: Text(
                "「時間数」",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SubNumForm()
        ],
      )
    );
  }
}

class SubNumForm extends StatefulWidget{
  @override
  _SubNumFormState createState()=>new _SubNumFormState();
}

class _SubNumFormState extends State<SubNumForm>{
  static List<int> subNumList=[3,4,5,6,7,8,9];
  int selectedValue=subNumList.indexOf(SettingData.subjectNum);

  @override
  Widget build(BuildContext context) {
    List<Widget> subNumTiles=[];
    subNumList.forEach(
            (value){
              subNumTiles.add(
                  Text(value.toString())
              );
            });
    return ListTile(
          title: Text(SettingData.subjectNum.toString()+'コマ'),
          trailing: IconButton(
              icon: Icon(Icons.expand_more),
              onPressed: (){
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      //changeSubNumLabel();
                      return       Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: subNumList.indexOf(SettingData.subjectNum)
                          ),
                          useMagnifier: true,
                          itemExtent: 30.0,
                          onSelectedItemChanged: (value){
                            setState(() {
                              SettingData.reloadBool=true;
                              selectedValue=value;
                              SettingData.subjectNum=subNumList[selectedValue];
                            });
                          },
                          children: subNumTiles,
                        ),
                      );
                    });
              }),
          onTap: (){
            //changeSubNumLabel('');
          },
        );
    }
}
