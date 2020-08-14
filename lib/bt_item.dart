import 'package:flutter/material.dart';

class BTItem extends StatelessWidget {
  BTItem({
    Key key,
    this.notifyParent,
    this.index,
    this.picked,
    this.title,
    this.link,
    this.peers,
    this.seeds,
  }) : super(key: key);

  final Function(int index) notifyParent;
  final int   index;
  final bool  picked;
  final String title;
  final String link;
  final int peers;
  final int seeds;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 10),
              Container(
                width: width-40,
                child: Text(
                  '$title',
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 20),
              IconButton(
                icon: picked ? Icon(Icons.cloud_queue) : Icon(Icons.cloud_download),
                color: picked ? Colors.black : Colors.pink,
                onPressed: (){
                  notifyParent(index);
                  },
              ),
              SizedBox(width: 40),
              Text(
                'Peers: $peers',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Seeds: $seeds',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
