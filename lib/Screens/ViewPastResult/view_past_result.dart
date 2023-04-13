import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ViewPastResultScreen extends StatefulWidget {
  final String info;
  const ViewPastResultScreen({Key? key, required this.info}) : super(key: key);

  @override
  State<ViewPastResultScreen> createState() => _ViewPastResultState();
}

class _ViewPastResultState extends State<ViewPastResultScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MaterialApp(
        home: Scaffold(
        appBar: AppBar(title: Text('Mental Health Assistant Chatbot'),),
        body: FutureBuilder(
            future: getViewPastResultDataGridSource(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
              return snapshot.hasData
                  ? SfDataGrid(source: snapshot.data, columns: getColumns())
                  : Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              );
            }
        ),
    ),
        ),
    );
  }

  Future<ViewPastResultDataGridSource> getViewPastResultDataGridSource() async{
    var ViewPastResultList = await generateViewPastResultList();
    return ViewPastResultDataGridSource(ViewPastResultList);
  }

  List<GridColumn> getColumns(){
    return <GridColumn>[
      GridColumn(
          columnName: 'Date and Time',
          width: 120,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('Date and Time',
                  overflow: TextOverflow.clip, softWrap: true)
          )
      ),
      GridColumn(
          columnName: 'Depression Score',
          width: 90,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('Depression Score',
                  overflow: TextOverflow.clip, softWrap: true)
          )
      ),
      GridColumn(
          columnName: 'Anxiety Score',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('Anxiety Score',
                  overflow: TextOverflow.clip, softWrap: true)
          )
      ),
      GridColumn(
          columnName: 'Stress Score',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('Stress Score',
                  overflow: TextOverflow.clip, softWrap: true)
          )
      )
    ];
  }
  Future<List<ViewPastResult>> generateViewPastResultList() async{
    var url = "http://192.168.43.74/mental_health_assistant_chatbot/StartEvaluation/evaluationPastResult.php";
    var response = await http.post(url, body: {
      "email": widget.info
    });
    var decodedViewPastResult = json.decode(response.body).cast<Map<String, dynamic>>();
    List<ViewPastResult> ViewPastResultList = await decodedViewPastResult
        .map<ViewPastResult>((json) => ViewPastResult.fromJson(json))
        .toList();
    return ViewPastResultList;
  }
}

class ViewPastResultDataGridSource extends DataGridSource {
  ViewPastResultDataGridSource(this.ViewPastResultList) {
    buildDataGridRow();
  }
  late List<DataGridRow> dataGridRows;
  late List<ViewPastResult> ViewPastResultList;
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    return DataGridRowAdapter(cells: [
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[0].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[1].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[3].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      )
    ]);
  }
  @override
  List<DataGridRow> get rows => dataGridRows;
  void buildDataGridRow(){
    dataGridRows = ViewPastResultList.map<DataGridRow>((dataGridRow){
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Date and Time', value: dataGridRow.date),
        DataGridCell<String>(columnName: 'Depression Score', value: dataGridRow.depression_score),
        DataGridCell<String>(columnName: 'Anxiety Score', value: dataGridRow.anxiety_score),
        DataGridCell<String>(columnName: 'Stress Score', value: dataGridRow.stress_score),
      ]);
    }).toList(growable: false);
  }
}


class ViewPastResult{
  factory ViewPastResult.fromJson(Map<String, dynamic> json){
    return ViewPastResult(date: json['date'], depression_score: json['depression_score'], anxiety_score: json['anxiety_score'], stress_score: json['stress_score']);
  }
  ViewPastResult(
      {
        required this.date,
        required this.depression_score,
        required this.anxiety_score,
        required this.stress_score
      });
  final String? date;
  final String? depression_score;
  final String? anxiety_score;
  final String? stress_score;
}
