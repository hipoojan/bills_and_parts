import 'package:bills_and_parts/utils/models.dart';
import 'package:bills_and_parts/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class Settings extends StatefulWidget {
  final SettingsChangeNotifier settingsProvider;
  const Settings({this.settingsProvider});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _companyNameController, _companyAddressController, _companyNumberController, _companyGSTINNoController, _bankNameController, _bankAccountNoController, _ifsCodeController;
  CompanyInfo _companyInfo;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _companyAddressController = TextEditingController();
    _companyNumberController = TextEditingController();
    _companyGSTINNoController = TextEditingController();
    _bankNameController = TextEditingController();
    _bankAccountNoController = TextEditingController();
    _ifsCodeController = TextEditingController();
    init();
  }

  /*@override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyNumberController.dispose();
    _companyGSTINNoController.dispose();
    _bankNameController.dispose();
    _bankAccountNoController.dispose();
    _ifsCodeController.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        child: RawKeyboardListener(
          focusNode: FocusNode(
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.escape)) node.unfocus();
              return false;
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                child: TextField(
                    cursorColor: Colors.black,
                    textInputAction: TextInputAction.done,
                    controller: _companyNameController,
                    decoration: InputDecoration.collapsed(hintText: "Company Name*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
              ),
              Container(
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                child: TextField(
                    cursorColor: Colors.black,
                    textInputAction: TextInputAction.done,
                    controller: _companyAddressController,
                    decoration: InputDecoration.collapsed(hintText: "Company Address*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: TextField(
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.done,
                          controller: _companyNumberController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                          decoration: InputDecoration.collapsed(hintText: "Company Number*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                          style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                    ),
                  ),
                  Container(width: 20),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: TextField(
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.done,
                          controller: _companyGSTINNoController,
                          decoration: InputDecoration.collapsed(hintText: "Company GSTIN No.", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                          style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                child: TextField(
                    cursorColor: Colors.black,
                    textInputAction: TextInputAction.done,
                    controller: _bankNameController,
                    decoration: InputDecoration.collapsed(hintText: "Bank Name*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: TextField(
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.done,
                          controller: _bankAccountNoController,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                          decoration: InputDecoration.collapsed(hintText: "Account Number*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                          style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                    ),
                  ),
                  Container(width: 20),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Color(0xffececec), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: TextField(
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.done,
                          controller: _ifsCodeController,
                          decoration: InputDecoration.collapsed(hintText: "IFS Code*", hintStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 18)),
                          style: GoogleFonts.inter(color: Colors.black, fontSize: 18)),
                    ),
                  )
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: TextButton(
                    onPressed: () {
                      if (_companyNameController.text.isNotEmpty &&
                          _companyAddressController.text.isNotEmpty &&
                          _companyNumberController.text.isNotEmpty &&
                          _bankNameController.text.isNotEmpty &&
                          _bankAccountNoController.text.isNotEmpty &&
                          _ifsCodeController.text.isNotEmpty) {
                        widget.settingsProvider
                            .saveData(CompanyInfo(
                                companyName: _companyNameController.text,
                                companyNumber: _companyNumberController.text,
                                companyAddress: _companyAddressController.text,
                                bankName: _bankNameController.text,
                                bankAccountNo: _bankAccountNoController.text,
                                ifsCode: _ifsCodeController.text,
                                companyGSTINNo: _companyGSTINNoController.text.isNotEmpty ? _companyGSTINNoController.text : ""))
                            .whenComplete(() => Toast.show("Company details saved!", context, backgroundRadius: 10, backgroundColor: Colors.green, duration: Toast.LENGTH_LONG));
                      } else
                        Toast.show("Provide all the required(*) fields!", context, backgroundRadius: 10, backgroundColor: Colors.red, duration: Toast.LENGTH_LONG);
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 20, horizontal: 30)),
                        backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                        elevation: MaterialStateProperty.all(15)),
                    child: Text('Save Changes', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500))),
              ),
              Expanded(child: Align(alignment: Alignment.bottomRight, child: Text('</> by hipoojan', style: GoogleFonts.inter(color: Colors.teal, fontSize: 18, fontWeight: FontWeight.w200))))
            ],
          ),
        ),
      ),
    );
  }

  init() async {
    if (_companyInfo == null) {
      _companyInfo = await widget.settingsProvider.getData();
      _companyNameController.text = widget.settingsProvider.companyInfo.companyName;
      _companyAddressController.text = widget.settingsProvider.companyInfo.companyAddress;
      _companyNumberController.text = widget.settingsProvider.companyInfo.companyNumber;
      _companyGSTINNoController.text = widget.settingsProvider.companyInfo.companyGSTINNo;
      _bankNameController.text = widget.settingsProvider.companyInfo.bankName;
      _bankAccountNoController.text = widget.settingsProvider.companyInfo.bankAccountNo;
      _ifsCodeController.text = widget.settingsProvider.companyInfo.ifsCode;
    }
    setState(() {});
  }
}
