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
    id: weatherDataProvider
    key: "/sailfish/weather/data_provider"
    defaultValue: "open_weather"

    property string token;

    function fetchToken(model) {
        if (value === 'foreca') {
            return ForecaToken.fetchToken(model)
        }
        model.token = WeatherProviderApiKey.value;
        return true;
    }

    function getUriTokenParam() {
        switch (value) {
        case 'foreca':
            return '&token=';
        case 'open_weather':
            return '&api_key=';
        default:
            console.log("Uri token parameter doesn't support for value: ", value)
            return '';
        }
    }
}
