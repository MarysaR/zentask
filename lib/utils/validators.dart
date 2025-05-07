class Validators {
  // Validation du titre (ne peut pas être vide)
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un titre';
    }

    if (value.length > 100) {
      return 'Le titre ne peut pas dépasser 100 caractères';
    }

    return null;
  }

  // Validation de la description (peut être vide, mais limitée en taille)
  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'La description ne peut pas dépasser 500 caractères';
    }

    return null;
  }

  // Validation de la date d'échéance (doit être dans le futur)
  static String? validateDueDate(DateTime? value) {
    if (value != null && value.isBefore(DateTime.now())) {
      return 'La date d\'échéance ne peut pas être dans le passé';
    }

    return null;
  }

  // Validation du nom de la catégorie
  static String? validateCategoryName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un nom de catégorie';
    }

    if (value.length > 50) {
      return 'Le nom de catégorie ne peut pas dépasser 50 caractères';
    }

    return null;
  }

  // Validation du titre de la sous-tâche
  static String? validateSubTaskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un titre pour la sous-tâche';
    }

    if (value.length > 100) {
      return 'Le titre de la sous-tâche ne peut pas dépasser 100 caractères';
    }

    return null;
  }
}
