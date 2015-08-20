angular.module \main, <[]>
  ..controller \main, <[$scope $http]> ++ ($scope, $http) ->
    $scope.method = do
      value: \GET
      set: -> @value = it
    $scope.payload = ""
    $scope.url = ""
    $scope.send = ->
      try
        payload = JSON.parse($scope.payload)
      catch
        payload = ""
      $http do
        url: "http://localhost:7000/x/#{$scope.url}"
        method: $scope.method.value
        headers: 'Content-Type': undefined
        data: payload
      .success (d) -> $scope.response = JSON.stringify(d)
      .error (d) -> $scope.response = d.toString!
