class PhoneNumber {
  final String internationalPhoneNumber;
  final String countryDialCode;
  final String country2letterCode;

  PhoneNumber(this.internationalPhoneNumber, this.countryDialCode,
      this.country2letterCode);

  @override
  String toString() {
    return internationalPhoneNumber;
  }
}
