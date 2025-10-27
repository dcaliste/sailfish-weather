// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause
//
// @author Anton Turko <turok@duck.com>

pragma Singleton
import QtQuick 2.2
import Nemo.Configuration 1.0

import "ForecaToken.js" as ForecaToken

ConfigurationValue {
    key: "/sailfish/weather/data_provider"
    defaultValue: "foreca"

    property string token;

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
            return '&api_key=';
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
            return '';
        }
    }

    function latestObservation(weather) {
        switch (getProviderName()) {
        case 'foreca':
            return "https://pfa.foreca.com/api/v1/observation/latest/";
        case 'open_weather':
            return '';
        default:
            console.log("Last observation url doesn't support for ", value);
        }
    }

    function forecastUrl(weather, isHourly) {
        switch (getProviderName()) {
        case 'foreca':
            return 'https://pfa.foreca.com/api/v1/forecast/' + (hourly ? "hourly/" : "daily/") + root.locationId;
        case 'open_weather':
            return '';
        default:
            console.log("Forecast url doesn't support for provider: ", value)
        }
    }

    function externalUrl() {
        switch (getProviderName()) {
        case 'foreca':
            return "http://foreca.mobi/spot.php?l=";
        case 'open_weather':
            return '';
        default:
            console.log("External URL doesn't support for provider: ", value);
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
