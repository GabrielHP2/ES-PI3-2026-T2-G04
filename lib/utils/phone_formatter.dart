import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final telefoneFormatter = MaskTextInputFormatter(
  mask: '+55 (##) #####-####',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);
