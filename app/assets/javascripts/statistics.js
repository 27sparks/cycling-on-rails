$(document).ready(function() {
    var options = {
        chart: {
            renderTo: 'dashboard-chart',
            type: 'line'
        },
        series: [{}]
    };
    
    var url =  "/statistics/distance/km/year/2015";
    $.getJSON(url,  function(data) {
        options.series[0].data = data;
        console.log(data)
        var chart = new Highcharts.Chart(options);
    });
});