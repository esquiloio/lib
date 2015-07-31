// Weather Station Demo (AngularJS version)
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

var app = angular.module('app', []);

app.controller('MainController',['$scope', '$http',
    function($scope, $http) {
        $scope.values = {
            temp: 0,
            humidity: 0,
            pressure: 0
        };

        function getWeather() {
            $http.post('/erpc', {method:'getWeather'}).
                success(function(data) {
                    var result = data.result;

                    // Convert Celsius to Fahrenheit
                    $scope.values.temp =
                        result.temp * 1.9 + 32;

                    // Humidity already in percent
                    $scope.values.humidity =
                        result.humidity;

                    // Convert to inHg
                    $scope.values.pressure =
                        result.pressure * 0.000295299830714;

                    setTimeout(getWeather, 1000);
                }).
                error(function(data, status) {
                    console.log('error:', status);
                    setTimeout(getWeather, 1000);
                });
        }
        getWeather();
    }]);

app.directive('gauge', function() {
    // This directive is ported from Marco Schweighauser's project here:
    // https://github.com/Schweigi/espruino-examples
    function polarToCartesian(centerX, centerY, radius, rad) {
        return {
            x: centerX + (radius * Math.cos(rad)),
            y: centerY + (radius * Math.sin(rad))
        };
    }

    function arc(x, y, radius, val, minVal, maxVal){
        var start = polarToCartesian(x, y, radius, -Math.PI);
        var end = polarToCartesian(x, y, radius, -Math.PI*(1 - 1/(maxVal-minVal) * (val-minVal)));

        var d = [
            "M", start.x, start.y,
            "A", radius, radius, 0, 0, 1, end.x, end.y
        ].join(" ");

        return d;
    }

    return {
        scope: {
            title:  '@',
            label:  '@',
            min:    '=',
            max:    '=',
            value:  '='
        },
        restrict: 'E',
        replace: true,
        template:
        '<div>'+
            '<h3>{{ title }}</h3>'+
            '<svg class="gauge" viewBox="0 0 200 145">'+
                '<path class="gauge-base" stroke-width="30" ng-attr-d="{{ baseArc }}" />'+
                '<path class="gauge-progress" stroke-width="30" stroke="#039deb" ng-attr-d="{{ progressArc }}" />'+
                '<text class="gauge-value" x="100" y="105" text-anchor="middle">{{ value | number:1 }} {{ label }}</text>'+
                '<text class="gauge-min" x="40" y="125" text-anchor="middle">{{ min }}</text>'+
                '<text class="gauge-max" x="160" y="125" text-anchor="middle">{{ max }}</text>'+
            '</svg>'+
        '</div>',
        link: function(scope, element, attrs) {
            scope.baseArc = arc(100, 100, 60, 1, 0, 1);
            scope.progressArc = arc(100, 100, 60, scope.min, scope.min, scope.max);
            scope.$watch('value', function() {
                // Range-bound the value and update the gauge
                var value = scope.value;
                if (value < scope.min) value = scope.min;
                else if (value > scope.max) value = scope.max;

                scope.progressArc = arc(100, 100, 60, value, scope.min, scope.max);
            });
        }
    }
});
