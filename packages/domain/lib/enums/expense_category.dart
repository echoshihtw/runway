enum ExpenseCategory {
  // Rent: counts against the rent budget. Every other category counts as living.
  rent,
  // Living
  food,
  social,
  daily,
  physical,
  discretionary,
  // Transport
  transport,
  // Health
  medical,
  wellbeing,
  // Travel
  travel;

  String get label => switch (this) {
    ExpenseCategory.rent          => 'RENT',
    ExpenseCategory.food          => 'FOOD',
    ExpenseCategory.social        => 'SOCIAL',
    ExpenseCategory.daily         => 'DAILY',
    ExpenseCategory.physical      => 'PHYSICAL',
    ExpenseCategory.discretionary => 'DISCRETIONARY',
    ExpenseCategory.transport     => 'TRANSPORT',
    ExpenseCategory.medical       => 'MEDICAL',
    ExpenseCategory.wellbeing     => 'WELLBEING',
    ExpenseCategory.travel        => 'TRAVEL',
  };

  String get group => switch (this) {
    ExpenseCategory.rent          => 'RENT',
    ExpenseCategory.food ||
    ExpenseCategory.social ||
    ExpenseCategory.daily ||
    ExpenseCategory.physical ||
    ExpenseCategory.discretionary => 'LIVING',
    ExpenseCategory.transport     => 'TRANSPORT',
    ExpenseCategory.medical ||
    ExpenseCategory.wellbeing     => 'HEALTH',
    ExpenseCategory.travel        => 'TRAVEL',
  };

  static const groups = ['RENT', 'LIVING', 'TRANSPORT', 'HEALTH', 'TRAVEL'];

  static List<ExpenseCategory> subcategoriesFor(String group) => switch (group) {
    'RENT'      => [rent],
    'LIVING'    => [food, social, daily, physical, discretionary],
    'HEALTH'    => [medical, wellbeing],
    'TRANSPORT' => [transport],
    'TRAVEL'    => [travel],
    _           => [],
  };

  static bool groupHasSubcategories(String group) =>
      group == 'LIVING' || group == 'HEALTH';
}
