import 'package:domain/controller/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app/ui/pages/common_widgets/display_weather_fetch_state.dart';
import 'package:weather_app/ui/pages/weather_home/widgets/dropdown_menu.dart';

//Widget that displays whole page composed by the dropdown menu for city selection and weather report (WeatherSection)
class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherController = GetIt.instance.get<WeatherController>();

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => weatherController.refreshWeatherData(),
          // call API
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 35),
                  child: Column(
                    children: const [
                      DropdownMenu(),
                      Expanded(child: DisplayWeatherFetch(page: PageName.home)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
