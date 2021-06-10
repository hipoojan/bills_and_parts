import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:toast/toast.dart';

class NewPart extends StatefulWidget {
  final PartsChangeNotifier partsProvider;
  final bool isEditing;
  final Part part;
  const NewPart({this.partsProvider, this.isEditing = false, this.part});

  @override
  _NewPartState createState() => _NewPartState();
}

class _NewPartState extends State<NewPart> {
  TextEditingController _idController, _nameController, _priceController, _taxController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.isEditing ? widget.part.id.toString() : "");
    _nameController = TextEditingController(text: widget.isEditing ? widget.part.name : "");
    _priceController = TextEditingController(text: widget.isEditing ? widget.part.price.toString() : "");
    _taxController = TextEditingController(text: widget.isEditing ? widget.part.tax.toString() : "");
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: EdgeInsets.symmetric(horizontal: 40.0.w),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(color: widget.isEditing ? Colors.grey : Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextField(
                        cursorColor: Colors.black,
                        autofocus: true,
                        controller: _idController,
                        textAlign: TextAlign.center,
                        enabled: !widget.isEditing,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                        decoration: InputDecoration.collapsed(hintText: "#ID", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                        style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                  )),
              Container(width: 20),
              Expanded(
                  flex: 8,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextField(
                        cursorColor: Colors.black,
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration.collapsed(hintText: "Name", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                        style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                  ))
            ],
          ),
          Container(height: 20),
          Row(
            children: [
              Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextField(
                        cursorColor: Colors.black,
                        controller: _priceController,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                        decoration: InputDecoration.collapsed(hintText: "Price (₹)", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                        style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                  )),
              Container(width: 20),
              Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextField(
                        cursorColor: Colors.black,
                        controller: _taxController,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                        decoration: InputDecoration.collapsed(hintText: "Tax (%)", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                        style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                  ))
            ],
          ),
          Container(height: 20),
          Expanded(
            child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    if (_idController.text.isNotEmpty && _nameController.text.isNotEmpty && _priceController.text.isNotEmpty && _taxController.text.isNotEmpty) {
                      if (widget.isEditing) {
                        widget.partsProvider
                            .editPart(widget.part.id, Part(id: widget.part.id, name: _nameController.text, price: int.parse(_priceController.text), tax: int.parse(_taxController.text)));
                        Toast.show("Part Successfully Edited!", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } else {
                        widget.partsProvider.parts.any((e) => e.id == int.parse(_idController.text))
                            ? Toast.show("Part with that ID already exists!", context, backgroundColor: Colors.red, backgroundRadius: 10, duration: Toast.LENGTH_LONG)
                            : widget.partsProvider
                                .addPart(Part(id: int.parse(_idController.text), name: _nameController.text, price: int.parse(_priceController.text), tax: int.parse(_taxController.text)))
                                .whenComplete(() {
                                Toast.show("Part Successfully Added!", context, backgroundColor: Colors.green, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                                Navigator.pop(context);
                              });
                      }
                    } else
                      Toast.show("Enter all the fields", context, backgroundColor: Colors.red, backgroundRadius: 10, duration: Toast.LENGTH_LONG);
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Text('Confirm', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
