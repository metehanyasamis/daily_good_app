enum CategoryFilterOption {
  all,
  food,
  bakery,
  breakfast,
  market,
  vegetarian,
  vegan,
  glutenFree,
}

String categoryLabel(CategoryFilterOption c) {
  switch (c) {
    case CategoryFilterOption.all:
      return 'Tümü';
    case CategoryFilterOption.food:
      return 'Yemek';
    case CategoryFilterOption.bakery:
      return 'Fırın & Pastane';
    case CategoryFilterOption.breakfast:
      return 'Kahvaltı';
    case CategoryFilterOption.market:
      return 'Market & Manav';
    case CategoryFilterOption.vegetarian:
      return 'Vejetaryen';
    case CategoryFilterOption.vegan:
      return 'Vegan';
    case CategoryFilterOption.glutenFree:
      return 'Glutensiz';
  }
}
