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

    property string token;
    property var lastUpdate: new Date()

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
            console.log("Uri token parameter doesn't support for value: ", value)
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
            console.log("Last observation url doesn't support for ", value);
        }
    }

    function forecastUrl(weather, isHourly) {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return 'https://pfa.foreca.com/api/v1/forecast/' + (hourly ? "hourly/" : "daily/") + weather.locationId;
        case Provider.Name.OPEN_WEATHER:
            return 'https://api.openweathermap.org/data/2.5/forecast?units=metric&lat=' + weather.lat + "&lon=" + weather.lon + (isHourly ? "&cnt=7" : "");
        default:
            console.log("Forecast url doesn't support for provider: ", value)
        }
    }

    function updateAllowed(interval) {
        // only update automatically if more than <interval> minutes has
        // passed since the last update (default 30mins: 30*60*1000)
        // or the date has changed
        interval = interval === undefined ? 30*60*1000 : interval
        var now = new Date()
        var updateAllowed = now.getDate() != lastUpdate.getDate() || (now - interval > lastUpdate)
        if (updateAllowed) {
            lastUpdate = now
        }
        return updateAllowed
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
            console.log("Get forecast weather data doesn't support for ", getProviderName());
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

    function externalUrl() {
        switch (getProviderName()) {
        case Provider.Name.FORECA:
            return "https://foreca.mobi/spot.php?l=";
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
