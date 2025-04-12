import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

class MachinesRow extends StatelessWidget {
  final List equipment;
  final String name;
  const MachinesRow({super.key, required this.equipment, required this.name});

  @override
  Widget build(BuildContext context) {
     var media = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "${equipment.length} equipos",
                style: TextStyle(
                    color: TColor.gray, fontSize: 12),
              ),
            )
          ],
        ),
       
        SizedBox(
          height: media.width * 0.5,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: equipment.length,
              itemBuilder: (context, index) {
                var yObj = equipment[index] as Map? ?? {};
                return Container(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: media.width * 0.35,
                          width: media.width * 0.35,
                          decoration: BoxDecoration(
                              color: TColor.lightGray,
                              borderRadius:
                                  BorderRadius.circular(15)),
                          alignment: Alignment.center,
                          child: Image.asset(
                            yObj["image"].toString(),
                            width: media.width * 0.2,
                            height: media.width * 0.2,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            yObj["title"].toString(),
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 12),
                          ),
                        )
                      ],
                    ));
              }),
        ),
        ],
      ),
    );
  }
}