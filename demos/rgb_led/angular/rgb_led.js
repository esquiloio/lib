// RGB LED Demo (AngularJS version)
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

var app = angular.module('rgbLedApp', ['ui.bootstrap-slider', 'frapontillo.bootstrap-switch']);

app.controller('MainController', ['$scope', '$http',
    function($scope, $http) {
        $scope.sliders = {
            red:   0,
            green: 0,
            blue:  0
        };

        $scope.isDiscoOn = false;

        $scope.$watch('sliders', function() {
            setLedColors($scope.sliders.red, $scope.sliders.green, $scope.sliders.blue);
        }, true); // deep watch

        $scope.$watch('isDiscoOn', function() {
            $http.post('/erpc', {
                method:'setIsDiscoOn',
                params: $scope.isDiscoOn
            });
        });

        function setLedColors(red, green, blue) {
            $http.post('/erpc', {
                method:'setLedColors',
                params: {
                    red:   red,
                    green: green,
                    blue:  blue
                }
            });
        }

        // Init to Esquilo blue
        setLedColors(0x03, 0x9d, 0xeb);

        var COLOR_UPDATE_MS = 75;
        function getLedColors() {
            $http.post('/erpc', {method:'getLedColors'}).
                success(function(data) {
                    if (data.result)
                        $scope.sliders = data.result;

                    setTimeout(getLedColors, COLOR_UPDATE_MS);
                }).
                error(function(data, status) {
                    console.log('error:', status);
                    setTimeout(getLedColors, COLOR_UPDATE_MS);
                });
        }
        getLedColors();
    }]);
