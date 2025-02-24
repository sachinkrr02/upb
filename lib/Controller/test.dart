import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CountryPhoneField extends StatefulWidget {
  @override
  _CountryPhoneFieldState createState() => _CountryPhoneFieldState();
}

class _CountryPhoneFieldState extends State<CountryPhoneField> {
  final TextEditingController _mobileController = TextEditingController();
  CountryCode _selectedCountry =
      CountryCode.fromCountryCode('IN'); // Default India 🇮🇳

  bool _isValidMobile(String value) {
    return RegExp(r'^[0-9]{10}$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CountryCodePicker(
          onChanged: (country) {
            setState(() {
              _selectedCountry = country;
            });
            debugPrint(
                "Selected Country: ${country.name}, Code: ${country.dialCode}");
          },
          initialSelection: 'IN', // Default country
          showCountryOnly: false,
          showOnlyCountryWhenClosed: false,
          showFlag: true,
          alignLeft: false,
        ),
        const SizedBox(width: 5), // Space between country picker and text field
        Expanded(
          child: TextFormField(
            controller: _mobileController,
            decoration: InputDecoration(
              labelText: "Mobile Number",
              border: const OutlineInputBorder(),
              prefixIcon: _selectedCountry.flagUri != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        _selectedCountry.flagUri!,
                        package:
                            'country_code_picker', // Required for package assets
                        width: 24,
                        height: 24,
                      ),
                    )
                  : const Icon(Icons.phone), // Fallback icon if flag is missing
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Mobile number is required";
              }
              if (!_isValidMobile(value)) {
                return "Enter a valid 10-digit mobile number";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
