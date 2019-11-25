import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/models/phone_number.dart';
import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/phone_mask_input_formatter.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:libphonenumber/libphonenumber.dart';

class InternationalPhoneNumberInput extends StatefulWidget {
  final ValueChanged<PhoneNumber> onInputChanged;
  final ValueChanged<bool> onInputValidated;

  final VoidCallback onSubmit;
  final TextEditingController textFieldController;
  final TextInputAction keyboardAction;

  final String initialCountry2LetterCode;
  final String inputFormat;
  final String hintText;
  final String errorMessage;

  final bool formatInput;
  final bool shouldParse;
  final bool shouldValidate;
  final bool wrappedAroundForm;

  final TextStyle textStyle;
  final InputBorder inputBorder;
  final InputDecoration inputDecoration;

  final FocusNode focusNode;

  final List<String> countries;

  const InternationalPhoneNumberInput({
    Key key,
    @required this.onInputChanged,
    this.onInputValidated,
    this.focusNode,
    this.textFieldController,
    this.onSubmit,
    this.keyboardAction,
    this.countries,
    this.textStyle,
    this.inputBorder,
    this.inputDecoration,
    this.initialCountry2LetterCode = 'NG',
    this.inputFormat = '(000) 000-0000',
    this.hintText = '(800) 000-0001',
    this.shouldParse = true,
    this.shouldValidate = true,
    this.formatInput = true,
    this.wrappedAroundForm = false,
    this.errorMessage = 'Invalid phone number',
  }) : super(key: key);

  factory InternationalPhoneNumberInput.withCustomDecoration({
    @required ValueChanged<PhoneNumber> onInputChanged,
    ValueChanged<bool> onInputValidated,
    FocusNode focusNode,
    TextEditingController textFieldController,
    VoidCallback onSubmit,
    TextInputAction keyboardAction,
    List<String> countries,
    TextStyle textStyle,
    @required InputDecoration inputDecoration,
    String initialCountry2LetterCode = 'NG',
    String inputFormat = '(000) 000-0000',
    bool formatInput = true,
    bool shouldParse = true,
    bool shouldValidate = true,
    bool wrappedAroundForm = false,
  }) {
    return InternationalPhoneNumberInput(
      onInputChanged: onInputChanged,
      onInputValidated: onInputValidated,
      focusNode: focusNode,
      textFieldController: textFieldController,
      onSubmit: onSubmit,
      keyboardAction: keyboardAction,
      countries: countries,
      textStyle: textStyle,
      inputDecoration: inputDecoration,
      initialCountry2LetterCode: initialCountry2LetterCode,
      inputFormat: inputFormat,
      formatInput: formatInput,
      shouldParse: shouldParse,
      shouldValidate: shouldValidate,
      wrappedAroundForm: wrappedAroundForm,
    );
  }

  factory InternationalPhoneNumberInput.withCustomBorder({
    @required ValueChanged<PhoneNumber> onInputChanged,
    @required ValueChanged<bool> onInputValidated,
    FocusNode focusNode,
    TextEditingController textFieldController,
    VoidCallback onSubmit,
    TextInputAction keyboardAction,
    List<String> countries,
    TextStyle textStyle,
    @required InputBorder inputBorder,
    @required String hintText,
    String initialCountry2LetterCode = 'NG',
    String inputFormat = '(000) 000-0000',
    String errorMessage = 'Invalid phone number',
    bool formatInput = true,
    bool shouldParse = true,
    bool shouldValidate = true,
    bool wrappedAroundForm = false,
  }) {
    return InternationalPhoneNumberInput(
      onInputChanged: onInputChanged,
      onInputValidated: onInputValidated,
      focusNode: focusNode,
      textFieldController: textFieldController,
      onSubmit: onSubmit,
      keyboardAction: keyboardAction,
      countries: countries,
      textStyle: textStyle,
      inputBorder: inputBorder,
      hintText: hintText,
      initialCountry2LetterCode: initialCountry2LetterCode,
      inputFormat: inputFormat,
      errorMessage: errorMessage,
      formatInput: formatInput,
      shouldParse: shouldParse,
      shouldValidate: shouldValidate,
      wrappedAroundForm: wrappedAroundForm,
    );
  }

  @override
  State<StatefulWidget> createState() => _InternationalPhoneNumberInputState();
}

class _InternationalPhoneNumberInputState
    extends State<InternationalPhoneNumberInput> {
  PhoneMaskInputFormatter _kPhoneInputFormatter;

  String _validPhoneNumber;

  bool _isNotValid = false;

  List<Country> _countries = [];
  Country _selectedCountry;

  TextEditingController _controller;

  List<TextInputFormatter> _buildInputFormatter() {
    List<TextInputFormatter> formatter = [
      LengthLimitingTextInputFormatter(widget.inputFormat.length),
    ];
    if (widget.formatInput) {
      formatter.add(_kPhoneInputFormatter);
    }

    return formatter;
  }

  _loadCountries() async {
    List<Country> data = await _getCountriesDataFromJsonFile(
        context: context, countries: widget.countries);
    setState(() {
      _countries = data;
      _selectedCountry = Utils.getInitialSelectedCountry(
          _countries, widget.initialCountry2LetterCode);
    });
  }

  Future<List<Country>> _getCountriesDataFromJsonFile(
      {@required BuildContext context,
      @required List<String> countries}) async {
    var list = await CountryProvider.getCountriesDataFromJsonFile(
        context: context, countries: countries);
    return list;
  }

  void _phoneNumberControllerListener() {
    _isNotValid = false;
    String parsedPhoneNumberString =
        _controller.text.replaceAll(RegExp(r'[^\d]'), '');

    if (widget.shouldParse) {
      getParsedPhoneNumber(
              parsedPhoneNumberString, _selectedCountry?.countryCode)
          .then((phoneNumber) {
        if (phoneNumber == null) {
          if (widget.onInputValidated != null) {
            widget.onInputValidated(false);
          }
          if (widget.shouldValidate) {
            setState(() {
              _isNotValid = true;
            });
          }
        } else {
          _validPhoneNumber = phoneNumber;
          widget.onInputChanged(new PhoneNumber(
            phoneNumber: phoneNumber,
            dialCode: _selectedCountry.dialCode,
            isoCode: _selectedCountry.countryCode,
          ));

          if (widget.onInputValidated != null) {
            widget.onInputValidated(true);
          }
          if (widget.shouldValidate) {
            setState(() {
              _isNotValid = false;
            });
          }
        }
      });
    } else {
      String phoneNumber =
          '${_selectedCountry.dialCode}$parsedPhoneNumberString';
      _validPhoneNumber = phoneNumber;
      widget.onInputChanged(new PhoneNumber(
        phoneNumber: phoneNumber,
        dialCode: _selectedCountry.dialCode,
        isoCode: _selectedCountry.countryCode,
      ));
    }
  }

  static Future<String> getParsedPhoneNumber(
      String phoneNumber, String iso) async {
    if (iso == null || iso.isEmpty) return null;
    if (phoneNumber.isNotEmpty) {
      try {
        bool isValidPhoneNumber = await PhoneNumberUtil.isValidPhoneNumber(
            phoneNumber: phoneNumber, isoCode: iso);

        if (isValidPhoneNumber) {
          return await PhoneNumberUtil.normalizePhoneNumber(
              phoneNumber: phoneNumber, isoCode: iso);
        }
      } on Exception {
        return null;
      }
    }
    return null;
  }

  void _formatTextField() {
    String text = _controller.text;
    bool isFormatted = _controller.text.contains(RegExp(r'[^\d]'));
    bool isNotEmpty = _controller.text.isNotEmpty;

    // ignore: unused_local_variable
    String _unMaskMask = widget.inputFormat.replaceAll(RegExp(r'[^\d]'), '');
    // ignore: unused_local_variable
    bool isEqual = text.length == _unMaskMask.length;

    int firstIndexOfSeparator = widget.inputFormat.indexOf(RegExp(r'[^\d]'));
    int lastIndexOfText = text.lastIndexOf(RegExp(r'[\d]'));

    bool shouldFormat = lastIndexOfText > firstIndexOfSeparator;

    if (!isFormatted && isNotEmpty && widget.formatInput && shouldFormat) {
      TextEditingValue textEditingValue = TextEditingValue(text: text);
      textEditingValue = _kPhoneInputFormatter.applyMask(textEditingValue);
      _controller.text = textEditingValue.text;
    }
  }

  @override
  void initState() {
    _loadCountries();
    _kPhoneInputFormatter = PhoneMaskInputFormatter(mask: widget.inputFormat);
    _controller = widget.textFieldController ?? TextEditingController();
    _controller.addListener(_phoneNumberControllerListener);
    _controller.addListener(_formatTextField);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DropdownButtonHideUnderline(
            child: DropdownButton<Country>(
              value: _selectedCountry,
              items: _mapCountryToDropdownItem(_countries),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
                _phoneNumberControllerListener();
              },
            ),
          ),
          Flexible(
            child: TextFormField(
              controller: _controller,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.phone,
              textInputAction: widget.keyboardAction,
              inputFormatters: _buildInputFormatter(),
              style: widget.textStyle,
              onEditingComplete: () {
                widget.onSubmit();
                widget.onInputChanged(
                  new PhoneNumber(
                    phoneNumber: _validPhoneNumber,
                    dialCode: _selectedCountry.dialCode,
                    isoCode: _selectedCountry.countryCode,
                  ),
                );
              },
              validator: (String value) {
                if (_isNotValid || value.isEmpty) {
                  return widget.errorMessage;
                }
                return null;
              },
              onChanged: (text) {
                _phoneNumberControllerListener();
              },
              decoration: _getInputDecoration(widget.inputDecoration),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(InputDecoration decoration) {
    return decoration ??
        InputDecoration(
          border: widget.inputBorder ?? UnderlineInputBorder(),
          hintText: widget.hintText,
          errorText: (_isNotValid && !widget.wrappedAroundForm)
              ? widget.errorMessage
              : null,
        );
  }

  List<DropdownMenuItem<Country>> _mapCountryToDropdownItem(
      List<Country> countries) {
    return countries.map((country) {
      return DropdownMenuItem<Country>(
          value: country,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                country.flagUri,
                width: 32.0,
                package: 'intl_phone_number_input',
              ),
              SizedBox(width: 12.0),
              Text(
                country.dialCode,
                style: widget.textStyle,
              )
            ],
          ));
    }).toList();
  }

  @override
  void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
    if (widget.initialCountry2LetterCode !=
        oldWidget.initialCountry2LetterCode) {
      setState(() {
        _selectedCountry = Utils.getInitialSelectedCountry(
            _countries, widget.initialCountry2LetterCode);
      });
    }
    super.didUpdateWidget(oldWidget);
  }
}
