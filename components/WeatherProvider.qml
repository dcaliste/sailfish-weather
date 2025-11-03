// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause
//
// @author Anton Turko <turok@duck.com>

pragma Singleton
import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import "ForecaToken.js" as ForecaToken
import "OpenWeatherModel.js" as OpenWeatherModel
import "WeatherModel.js" as ForecaWeatherModel
import "Provider.js" as Provider

ConfigurationValue {
    key: "/sailfish/weather/data_provider"
    defaultValue: Provider.Name.FORECA

    function fetchToken(model) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return ForecaToken.fetchToken(model)
        case Provider.Name.OPEN_WEATHER:
            model.token = getApiKey();
            return true;
        default:
            console.log("Wether Provider doesn't support fetching token.")
            return false;
        }
    }

    function getUriTokenParam() {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return '&token=';
        case Provider.Name.OPEN_WEATHER:
            return '&appId=';
        default:
            console.log("Uri token parameter doesn't support by provider: ", getProviderName())
            return '';
        }
    }

    function currentWeatherUrl(weather) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return 'https://pfa.foreca.com/api/v1/current/' + weather.locationId;
        case Provider.Name.OPEN_WEATHER:
            return 'https://api.openweathermap.org/data/2.5/weather?units=metric&lat=' + weather.lat + "&lon=" + weather.lon;
        }
    }

    function latestObservation(weather) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return "https://pfa.foreca.com/api/v1/observation/latest/";
        case Provider.Name.OPEN_WEATHER:
            return 'https://api.openweathermap.org/data/2.5/weather?units=metric&lon=' + weather.lon + "&lat=" + weather.lat;
        default:
            console.log("Last observation url doesn't support by provider: ", getProviderName());
        }
    }

    function forecastUrl(weather, isHourly) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return 'https://pfa.foreca.com/api/v1/forecast/' + (hourly ? "hourly/" : "daily/") + weather.locationId;
        case Provider.Name.OPEN_WEATHER:
            return 'https://api.openweathermap.org/data/2.5/forecast?units=metric&lat=' + weather.lat + "&lon=" + weather.lon + (isHourly ? "&cnt=7" : "");
        default:
            console.log("Forecast url doesn't support by provider: ", getProviderName())
        }
    }

    function searchLocationUrl(filter, language) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return "https://pfa.foreca.com/api/v1/location/search/" + filter.toLowerCase() + "&lang=" + language;
        case Provider.Name.OPEN_WEATHER:
            return "https://nominatim.openstreetmap.org/search?format=json&accept-language=" + language + "&city=" + filter.toLowerCase() ;
        default:
            console.log("search location url doesn't support by provider: ", getProviderName());
        }
    }

    function handleCurrentWeatherResult(result) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return ForecaWeatherModel.handleCurrentWeatherResult(result);
        case Provider.Name.OPEN_WEATHER:
            return OpenWeatherModel.handleCurrentWeatherResult(result);
        default:
            console.log("Get weather data doesn't support for ", getProviderName());
        }
    }

    function handleObservationResult(result) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return ForecaWeatherModel.handleObservationResult(result);
        case Provider.Name.OPEN_WEATHER:
            return OpenWeatherModel.handleObservationResult(result);
        default:
            console.log("Get weather data doesn't support for ", getProviderName());
        }
    }

    function handleForecastResult(result, isHourly, visibleCount, minimumHourlyRange) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return ForecaWeatherModel.handleForecastResult(result, isHourly, visibleCount, minimumHourlyRange);
        case Provider.Name.OPEN_WEATHER:
            return OpenWeatherModel.handleForecastResult(result, isHourly, visibleCount, minimumHourlyRange);
        default:
            console.log("Handler forecast weather data doesn't support for ", getProviderName());
        }
    }

    function handleSearchLocationResult(result) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return ForecaWeatherModel.handleSearchLocationResult(result);
        case Provider.Name.OPEN_WEATHER:
            return OpenWeatherModel.handleSearchLocationResult(result);
        default:
            console.log("Handler search location doesn't support by ", getProviderName());
        }
    }

    function getWeatherData(weather) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return ForecaWeatherModel.getWeatherData(weather);
        case Provider.Name.OPEN_WEATHER:
            return OpenWeatherModel.getWeatherData(weather);
        default:
            console.log("Get weather data doesn't support for ", getProviderName());
        }
    }

    function externalUrl(weather) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return "https://foreca.mobi/spot.php?l=" + weather.locationId;
        case Provider.Name.OPEN_WEATHER:
            return 'https://openweathermap.org';
        default:
            console.log("External URL doesn't support for provider: ", value);
        }
    }

    function providerImage(isWhite) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return "image://theme/graphic-foreca-large?" + isWhite ? Theme.highlightColor : Theme.primaryColor;
        case Provider.Name.OPEN_WEATHER:
            return !isWhite ? "qrc:/images/open_weather_white" : "qrc:/images/open_weather_black";
        }
    }

    function smallProviderImage(isWhite) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return "image://theme/graphic-foreca-small?" + isWhite ? Theme.highlightColor : Theme.primaryColor;
        case Provider.Name.OPEN_WEATHER:
            return !isWhite ? "qrc:/images/open_weather_small_white" : "qrc:/images/open_weather_small_black";
        }
    }

    function getProviderName() {
        const splitValues = value.split(':');
        return splitValues[0];
    }

    function getApiKey() {
        const separatorIndex = value.indexOf(':')
        if (separatorIndex === -1) {
            return '';
        }

        return value.substring(separatorIndex + 1);
    }
}
