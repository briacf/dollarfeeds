String sanitizeName(var name) {
  return name.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '');
}