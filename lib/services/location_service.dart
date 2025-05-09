class LocationService {
  // Static map of regions and their respective cities
  static Map<String, List<String>> regionsAndCities = {
    'Greater Accra': [
      'Ablekuma Central',
      'Ablekuma North',
      'Ablekuma West',
      'Adenta',
      'Ashaiman',
      'Ayawaso Central',
      'Ayawaso East',
      'Ayawaso North',
      'Ayawaso West',
      'Bortianor-Ngleshie-Amanfrom',
      'Ga Central',
      'Ga East',
      'Ga North',
      'Ga South',
      'Klottey Korle',
      'Krowor',
      'La Dade Kotopon',
      'La Nkwantanang Madina',
      'Ledzokuku',
      'Madina',
      'Manhean',
      'Okaikoi North',
      'Okaikoi South',
      'Osu Klottey',
      'Shai Osudoku',
      'Tema East',
      'Tema West',
      'Trobu',
      'Weija Gbawe',
      'Ayawaso North East',
      'Ayawaso North West',
      'Ayawaso South East',
      'Ayawaso South West',
    ],
    // Add other regions and cities here if needed
  };

  // Method to get cities for a specific region
  static List<String> getCitiesForRegion(String region) {
    return regionsAndCities[region] ?? []; // Return an empty list if the region is not found
  }
}