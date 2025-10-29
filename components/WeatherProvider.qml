// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause
//
// @author Anton Turko <turok@duck.com>

pragma Singleton
import QtQuick 2.2
import Nemo.Configuration 1.0

import "ForecaToken.js" as ForecaToken
import "OpenWeatherModel.js" as OpenWeatherModel
import "WeatherModel.js" as ForecaWeatherModel

ConfigurationValue {
    key: "/sailfish/weather/data_provider"
    defaultValue: "foreca"

    property string token;
    property var lastUpdate: new Date()

    function fetchToken(model) {
        switch (getProviderName()) {
        case 'foreca':
            return ForecaToken.fetchToken(model)
        case 'open_weather':
            model.token = getApiKey();
            return true;
        default:
            console.log("Wether Provider doesn't support fetching token.")
            return false;
        }
    }

    function getUriTokenParam() {
        switch (getProviderName()) {
        case 'foreca':
            return '&token=';
        case 'open_weather':
            return '&appId=';
        default:
            console.log("Uri token parameter doesn't support for value: ", value)
            return '';
        }
    }

    function currentWeatherUrl(weather) {
        switch (getProviderName()) {
        case 'foreca':
            return 'https://pfa.foreca.com/api/v1/current/' + weather.locationId;
        case 'open_weather':
            return 'https://api.openweathermap.org/data/2.5/weather?units=metric&lat=' + weather.lat + "&lon=" + weather.lon;
        }
    }

    function latestObservation(weather) {
        switch (getProviderName()) {
        case 'foreca':
            return "https://pfa.foreca.com/api/v1/observation/latest/";
        case 'open_weather':
            return 'https://api.openweathermap.org/data/2.5/weather?units=metric&lon=' + weather.lon + "&lat=" + weather.lat;
        default:
            console.log("Last observation url doesn't support for ", value);
        }
    }

    function forecastUrl(weather, isHourly) {
        switch (getProviderName()) {
        case 'foreca':
            return 'https://pfa.foreca.com/api/v1/forecast/' + (hourly ? "hourly/" : "daily/") + weather.locationId;
        case 'open_weather':
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
        case 'foreca':
            return ForecaWeatherModel.handleCurrentWeatherResult(result);
        case 'open_weather':
            return OpenWeatherModel.handleCurrentWeatherResult(result);
        default:
            console.log("Get weather data doesn't support for ", getProviderName());
        }
    }

    function handleObservationResult(result) {
        switch (getProviderName()) {
        case 'foreca':
            return ForecaWeatherModel.handleObservationResult(result);
        case 'open_weather':
            return OpenWeatherModel.handleObservationResult(result);
        default:
            console.log("Get weather data doesn't support for ", getProviderName());
        }
    }

    function handleForecastResult(result, isHourly, visibleCount, minimumHourlyRange) {
        switch (getProviderName()) {
        case 'foreca':
            return ForecaWeatherModel.handleForecastResult(result, isHourly, visibleCount, minimumHourlyRange);
        case 'open_weather':
            return OpenWeatherModel.handleForecastResult(result, isHourly, visibleCount, minimumHourlyRange);
        default:
            console.log("Get forecast weather data doesn't support for ", getProviderName());
        }
    }

    function getWeatherData(weather) {
        switch (getProviderName()) {
        case 'foreca':
            return ForecaWeatherModel.getWeatherData(weather);
        case 'open_weather':
            return OpenWeatherModel.getWeatherData(weather);
        default:
            console.log("Get weather data doesn't support for ", getProviderName());
        }
    }

    function externalUrl() {
        switch (getProviderName()) {
        case 'foreca':
            return "https://foreca.mobi/spot.php?l=";
        case 'open_weather':
            return 'https://openweathermap.org';
        default:
            console.log("External URL doesn't support for provider: ", value);
        }
    }

    function providerImage(color) {
        switch (getProviderName()) {
        case 'foreca':
            return "image://theme/graphic-foreca-large?" + color;
        case 'open_weather':
            return "logo_color_white.png";
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
