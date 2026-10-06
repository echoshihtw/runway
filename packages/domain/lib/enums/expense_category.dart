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
}
