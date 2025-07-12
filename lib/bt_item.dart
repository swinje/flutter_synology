import 'package:flutter/material.dart';

class BTItem extends StatelessWidget {
  BTItem({
    required Key? key,
    required this.notifyParent,
    required this.index,
    required this.picked,
    required this.title,
    required this.link,
    required this.peers,
    required this.seeds,
  }) : super(key: key);

  final Function(BuildContext context, int index) notifyParent;
  final int index;
  final bool picked;
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
                width: width - 40,
                child: Text(
                  '$title',
                  maxLines: null,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16.0,
                      color: Theme.of(context).colorScheme.onSurface),
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
                icon: picked
                    ? Icon(Icons.cloud_queue)
                    : Icon(Icons.cloud_download),
                color: picked
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  notifyParent(context, index);
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
