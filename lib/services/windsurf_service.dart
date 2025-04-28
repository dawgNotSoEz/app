import '../models/windsurf_spot.dart';

class WindsurfService {
  // In a real app, this would come from an API
  List<WindsurfSpot> getSpots() {
    return [
      WindsurfSpot(
        id: '1',
        name: 'Tarifa',
        location: 'Spain',
        imageUrl: 'https://images.unsplash.com/photo-1560088939-aef002610ff3?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
        rating: 4.8,
        difficulty: 'Advanced',
        conditions: {
          'wind': '15-35 knots',
          'waves': '1-3 meters',
          'bestSeason': 'April to October',
        },
        description: 'Tarifa is known as the wind capital of Europe, offering consistent strong winds and a variety of conditions suitable for all levels of windsurfers.',
      ),
      WindsurfSpot(
        id: '2',
        name: 'Maui',
        location: 'Hawaii, USA',
        imageUrl: 'https://images.unsplash.com/photo-1505159940484-eb2b9f2588e2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
        rating: 4.9,
        difficulty: 'Expert',
        conditions: {
          'wind': '20-40 knots',
          'waves': '2-5 meters',
          'bestSeason': 'Year-round, best from May to October',
        },
        description: 'Maui is a world-renowned windsurfing destination with powerful winds and challenging waves, particularly at Ho\'okipa Beach Park.',
      ),
      WindsurfSpot(
        id: '3',
        name: 'Bonaire',
        location: 'Caribbean',
        imageUrl: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1626&q=80',
        rating: 4.7,
        difficulty: 'Beginner to Intermediate',
        conditions: {
          'wind': '15-25 knots',
          'waves': 'Flat to small chop',
          'bestSeason': 'December to August',
        },
        description: 'Bonaire offers flat water conditions in Lac Bay, making it perfect for beginners and freestyle enthusiasts. Consistent trade winds provide reliable conditions.',
      ),
      WindsurfSpot(
        id: '4',
        name: 'Jericoacoara',
        location: 'Brazil',
        imageUrl: 'https://images.unsplash.com/photo-1599571234909-29ed5d1321d6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
        rating: 4.6,
        difficulty: 'Intermediate',
        conditions: {
          'wind': '15-30 knots',
          'waves': 'Flat to 1 meter',
          'bestSeason': 'August to December',
        },
        description: 'Jericoacoara is a paradise for windsurfers with its lagoons and ocean spots. The consistent cross-shore winds and warm waters make it an ideal destination.',
      ),
      WindsurfSpot(
        id: '5',
        name: 'Leucate',
        location: 'France',
        imageUrl: 'https://images.unsplash.com/photo-1575423204492-7e4929227d9f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80',
        rating: 4.5,
        difficulty: 'All levels',
        conditions: {
          'wind': '15-35 knots',
          'waves': 'Flat to 2 meters',
          'bestSeason': 'March to October',
        },
        description: 'Leucate is one of the windiest spots in France, hosting the annual Mondial du Vent. It offers both flat water and wave conditions depending on the area.',
      ),
    ];
  }
}
