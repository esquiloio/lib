// Weather Station Demo (AngularJS version)
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

var app = angular.module('weatherApp', []);

app.controller('MainController',['$scope', '$http',
                                  function($scope, $http) {
    $scope.values = {
        temp: '--',
        humidity: '--',
        pressure: '--'
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
    return {
        scope: {
            title:  '@',
            label:  '@',
            value:  '='
        },
        restrict: 'E',
        replace: true,
        template:
            '<div class="box">' +
                '<h3>{{ title }}</h3>' +
                '<h2>{{ value | number:1 }} {{ label }}</h2>' +
            '</div>'
    }
});