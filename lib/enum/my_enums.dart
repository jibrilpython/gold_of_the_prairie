enum HarvestCommodity {
  wheat('Wheat'),
  corn('Corn'),
  barley('Barley'),
  oats('Oats'),
  rye('Rye'),
  sorghum('Sorghum');

  const HarvestCommodity(this.label);
  final String label;
}

enum InspectionClassification {
  coreSampler('Core Sampler'),
  triageSieve('Triage Sieve'),
  testWeightScale('Test-Weight Scale'),
  seedDockingMill('Seed Docking Mill'),
  kernelCountBoard('Kernel Count Board'),
  moistureComparator('Analog Moisture Comparator');

  const InspectionClassification(this.label);
  final String label;
}

enum ArtisanHallmark {
  prairieCraft('PrairieCraft IronWorks'),
  aetherGrain('AetherGrain Scientific'),
  greatPlains('Great Plains Balance Co.'),
  redRiver('Red River Sieve & Scale'),
  chaffless('Chaffless Mechanical Works'),
  elevatorStandard('Elevator Standard Foundry');

  const ArtisanHallmark(this.label);
  final String label;
}

enum SieveMeshGeometry {
  triangularBuckwheat('Triangular buckwheat holes'),
  roundOneFourteenth('1/14-inch round perforations'),
  slottedFlax('Slotted flax screens'),
  oblongCorn('Oblong corn crib slots'),
  wireCloth('Nested wire-cloth square mesh'),
  notApplicable('Not applicable');

  const SieveMeshGeometry(this.label);
  final String label;
}

enum BalanceBeamGraduation {
  poundsPerBushel('Pounds per Bushel'),
  kilogramsPerHectoliter('Kilograms per Hectoliter'),
  rawGrainOunces('Raw grain ounces'),
  dockagePercent('Dockage percent'),
  kernelCountIndex('Kernel count index'),
  notStamped('No stamped graduation');

  const BalanceBeamGraduation(this.label);
  final String label;
}

enum Metallurgy {
  sheetBrass('Sheet brass jacket'),
  copperHopper('Polished copper hopper'),
  whiteOak('Oil-rubbed white oak frame'),
  castIron('Blackened cast-iron gearing'),
  nickelSteel('Nickel steel beam and pans'),
  ceramicGlass('Ceramic vial and inspection glass');

  const Metallurgy(this.label);
  final String label;
}

enum PreservationSoundness {
  museumGrade('Museum grade - certified stable'),
  displayCondition('Display condition - calibrated visually'),
  meshTensionWeak('Screen mesh tension weakened'),
  bubbleVialCompromised('Level-bubble vial compromised'),
  seasoningCracks('Wood seasoning cracks present'),
  brassTarnished('Heavy brass tarnish');

  const PreservationSoundness(this.label);
  final String label;
}
