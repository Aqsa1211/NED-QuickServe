import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:food/utils/colors.dart";
class listTile extends StatelessWidget {
  final String text;
  final String quantity;
  final icon;
  const listTile({super.key, required this.text, required this.quantity, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 60,
        width: 300,
        child: Row(
          children: [
            Icon(icon,size:70,color:Color(0xFF800000),),
            SizedBox(width: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                Text(quantity,style: TextStyle(
                  color:AppColors.darkerGrey,
                ),),


              ],
            )
          ],
        ),
      ),
    );
  }
}