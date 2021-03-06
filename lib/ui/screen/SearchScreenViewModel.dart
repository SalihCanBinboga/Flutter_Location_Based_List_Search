import 'package:flutter/material.dart';
import 'package:flutter_location_based_search/data/local/SearchRepositroy.dart';
import 'package:flutter_location_based_search/data/local/models/CityDistrictModel.dart';
import 'package:geocoding/geocoding.dart';

enum SearchState { Idle, Searching, Seached }
enum LocationState { NotFound, Found }

class SearchScreenViewModel with ChangeNotifier {
  SearchState _state = SearchState.Idle;

  SearchState get state => _state;

  LocationState _locationState = LocationState.NotFound;

  LocationState get locationState => _locationState;

  List<String> _searchResultList;

  List<String> get searchResultList => _searchResultList;

  String _resultLocationCity;

  String get resultLocationCity => _resultLocationCity;

  SearchRepoSitory _repo;

  SearchScreenViewModel(BuildContext context) {
    _repo = SearchRepoSitory(context);
    _searchResultList = List();
  }

  void searchText(String searchText) async {
    _state = SearchState.Searching;
    notifyListeners();
    if (searchText.isEmpty) {
      _state = SearchState.Seached;
      _searchResultList.clear();
      notifyListeners();
    } else {
      List<CityDistrictModel> cityDistrictList = await _repo.getCityDistrictList();
      _searchResultList.clear();

      cityDistrictList.forEach((element) {
        String lowerText = element.cityName.toLowerCase();
        String upperText = element.cityName.toUpperCase();

        if (lowerText.contains(searchText.toLowerCase()) || upperText.contains(searchText.toUpperCase())) {
          _searchResultList.add(element.cityName);
        }

        element.districtList.forEach((district) {
          String _lowerText = district.toLowerCase();
          String _upperText = district.toUpperCase();

          if (_lowerText.contains(searchText.toLowerCase()) || _upperText.contains(searchText.toUpperCase())) {
            _searchResultList.add("${element.cityName}/$district");
          }
        });
      });

      _state = SearchState.Seached;
      notifyListeners();
    }
  }

  void setLocationNotFound() {
    _locationState = LocationState.NotFound;
    notifyListeners();
  }

  void getCityNameBasedLocation() async {
    try {
      List<Placemark> placeList = await _repo.getAddress();

      placeList.forEach((element) => _resultLocationCity = element.administrativeArea);

      _locationState = LocationState.Found;
      notifyListeners();
    } catch (e) {
      _locationState = LocationState.NotFound;
      notifyListeners();
    }
  }
}
