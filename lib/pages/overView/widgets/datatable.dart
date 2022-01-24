import 'package:HyS/constants/style.dart';
import 'package:data_table_2/data_table_2.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Example without datasource
class DataTable_OverView extends StatelessWidget {
  const DataTable_OverView();

  @override
  Widget build(BuildContext context) {
    //setColumnSizeRatios(1, 2);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(color: lightGrey.withOpacity(0.1))),
      child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          smRatio: 0.75,
          lmRatio: 1.5,
          columns: [
            DataColumn2(
              size: ColumnSize.S,
              label: Text('Name'),
            ),
            DataColumn(
              label: Text('Location'),
            ),
            DataColumn(
              label: Text('Rating'),
            ),
            DataColumn(
              label: Text('Action'),
            ),
          ],
          rows: List<DataRow>.generate(
              10,
              (index) => DataRow(cells: [
                    DataCell(Text(
                      "Pratik Ekghare",
                      style: TextStyle(
                          color: lightGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    )),
                    DataCell(
                      Text(
                        "Nagpur",
                        style: TextStyle(
                            color: lightGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.deepOrange, size: 18),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "4.$index",
                          style: TextStyle(
                              color: lightGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    )),
                    DataCell(Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: active, width: 0.5),
                          color: light,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("Available Delivery",
                            style: TextStyle(
                                color: active.withOpacity(0.7),
                                fontWeight: FontWeight.bold)))),
                  ]))),
    );
  }
}
