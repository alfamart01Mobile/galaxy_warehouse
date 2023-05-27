

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galaxy_warehouse/views/pages/issuing/issuing.dart';
class SearchTab  extends StatelessWidget
{
   
   const SearchTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(IssuingPageState.tabController.index.toString()), 
        ],
      ),
    );
  }
}