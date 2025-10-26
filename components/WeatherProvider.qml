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
        var splitValues = value.split(':');
        switch (splitValues[0]) {
        case 'foreca':
            return ForecaToken.fetchToken(model)
        case 'open_weather':
            model.token = splitValues[1];
            return true;
        default:
            console.log("Wether Provider doesn't support fetching token.")
            return false;
        }
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

//    function get
}
