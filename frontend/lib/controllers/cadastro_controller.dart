// João Pedro Panza Mainieri - RA: 25006642
import 'package:flutter/material.dart';

class SigninController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cpfController = TextEditingController();
  final birthDateController = TextEditingController();
  DateTime? birthDate;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ========== VALIDADORES PARA TextFormField (retornam String? ou null) ==========

  String? validateName(String? value) {
    final name = (value ?? nameController.text).trim();
    if (name.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (name.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    if (!name.contains(' ')) {
      return 'Insira seu nome completo (nome e sobrenome)';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final email = (value ?? emailController.text).trim().toLowerCase();
    if (email.isEmpty) {
      return 'Email é obrigatório';
    }
    // RFC 5322 simplified
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Email inválido';
    }
    return null;
  }

  String? validateCPF(String? value) {
    final cpf = (value ?? cpfController.text).replaceAll(RegExp(r'\D'), '');

    if (cpf.isEmpty) {
      return 'CPF é obrigatório';
    }
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verificar se todos os dígitos são iguais
    if (cpf.split('').toSet().length == 1) {
      return 'CPF inválido';
    }

    // Validar primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[9]) != firstDigit) {
      return 'CPF inválido';
    }

    // Validar segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[10]) != secondDigit) {
      return 'CPF inválido';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final phone = (value ?? phoneController.text).trim().replaceAll(RegExp(r'\s+'), '');

    if (phone.isEmpty) {
      return 'Telefone é obrigatório';
    }

    final phoneRegex = RegExp(r'^\+55[1-9]\d{9,10}$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Telefone inválido. Formato: +5511987654321';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? passwordController.text;

    if (password.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (password.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    if (password.length > 16) {
      return 'Máximo 16 caracteres';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Deve conter letra maiúscula';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Deve conter letra minúscula';
    }

    if (!password.contains(RegExp(r'\d'))) {
      return 'Deve conter número';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Deve conter caractere especial';
    }

    return null;
  }

  String? validateBirthDate(String? value) {
    final date = value ?? birthDateController.text;

    if (date.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }

    if (birthDate == null) {
      return 'Selecione uma data válida';
    }

    final age = DateTime.now().year - birthDate!.year;
    if (age < 18) {
      return 'Você deve ter pelo menos 18 anos';
    }

    return null;
  }

  bool validate() {
    _errorMessage = null;

    final nameError = validateName(null);
    if (nameError != null) {
      _errorMessage = nameError;
      return false;
    }

    final emailError = validateEmail(null);
    if (emailError != null) {
      _errorMessage = emailError;
      return false;
    }

    final cpfError = validateCPF(null);
    if (cpfError != null) {
      _errorMessage = cpfError;
      return false;
    }

    final phoneError = validatePhone(null);
    if (phoneError != null) {
      _errorMessage = phoneError;
      return false;
    }

    final passwordError = validatePassword(null);
    if (passwordError != null) {
      _errorMessage = passwordError;
      return false;
    }

    final birthDateError = validateBirthDate(null);
    if (birthDateError != null) {
      _errorMessage = birthDateError;
      return false;
    }

    return true;
  }

  void setBirthDate(DateTime date) {
    birthDate = date;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    birthDateController.text = '$day/$month/$year';
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    birthDateController.dispose();
  }
}
