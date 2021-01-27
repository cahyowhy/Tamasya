# Tamasya
<div align="center">
<img src="./main-logo.svg" width="500" height="300"/>
</div>

<div style="margin-top: 18px" align="center">
      <a href="https://www.youtube.com/watch?v=JkSAdCM7dS0">
         <img src="https://img.youtube.com/vi/JkSAdCM7dS0/0.jpg" width="480">
      </a>
</div>

Flutter App to explore Flight, Hotel and Activities. This project use some API that require keys, so make sure you register first.
This project use
* [Amadeus](https://developers.amadeus.com/) to find cheapest hotel, flight and activities
* [Mapbox](https://docs.mapbox.com/) to render map and fetch city / country on autocomplete
* [Currency freak](https://currencyfreaks.com/) to get valid currency based on current country location

## Feature
* Search cheapest flight with given airport
* Search cheapest hotel with given city
* Search activities near you

## Dependencies
* [Get X](https://github.com/jonataslaw/getx) Awesome State mangement, Navigation Management & Dependency Manager
* [Catcher](https://github.com/jhomlala/catcher) Plugin which automatically catches error/exceptions and handle them
* [Flutter Map](https://github.com/johnpryan/flutter_map) For render map

## How to run this project
* clone this project
* copy .env.example to .env
* fill those property on .env
* You can run manually via terminal with
    
    prod
    ```bash 
    flutter run lib/main_prod.dart 
    ```

    dev
    ```bash 
    flutter run lib/main_dev.dart 
    ```

    or you can use this existing .vscode launch.json configuration