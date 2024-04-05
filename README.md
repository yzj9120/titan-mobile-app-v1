# titan_app

Titan edge node for mobile device

## l10n
run the following code in project root directory:
```console
flutter gen-l10n
```
then, we need to patch at each file header of dart file generated in ./lib/l10n/generated/ with following line, to suppress dart warnings:
```console
// ignore_for_file: non_constant_identifier_names, use_super_parameters
```