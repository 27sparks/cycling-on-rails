$(document).ready(function() {
    var time_frame = 'year'
    var options = {
        chart: {
            renderTo: 'dashboard-chart',
            zoomType: 'x'
        },
        title: { text: 'Dashboard' },
        yAxis: [{ title: { text: '' }},
                { title: { text: '' },
                    opposite: true
                },
                { title: { text: '' }}
        ],
        xAxis: { type: 'datetime' },
        credits: { enabled: false }
    };

    function get_and_show_graph_from_json(url, index, array) {
        $.getJSON(url, function (data) {
            chart.addSeries(data);
            chart.yAxis[index].setTitle({text: data.unit})
        });
    }
    function collect_jsons(urls) {
        chart = new Highcharts.Chart(options);
        urls.forEach(get_and_show_graph_from_json)
    }
    function show_tlf()
    {
        time_frame = 'year'
        var url = "/statistics/fatigue/no_unit/" + time_frame + "/" + $.urlParam('date') + "/by_days";
        var url2 = "/statistics/load/load/" + time_frame + "/" + $.urlParam('date') + "/by_days";
        var url3 = "/statistics/trimp/imp/" + time_frame + "/" + $.urlParam('date') + "/by_days";
        collect_jsons([url, url2, url3]);
    };

    function show_add() {
        time_frame = 'month'
        var url = "/statistics/distance/km/" + time_frame + "/" + $.urlParam('date') + "/by_days";
        var url2 = "/statistics/duration/h/" + time_frame + "/" + $.urlParam('date') + "/by_days";
        var url3 ="/statistics/avghr/bpm/" + time_frame + "/" + $.urlParam('date') + "/by_days";
        collect_jsons([url, url2, url3])
    };

    function set_time_frame(tf) {
        time_frame = tf;
        show_tlf();
    };

    show_tlf()
    $('#tlf').click(function(){show_tlf()});
    $('#add').click(function(){show_add()});
    $('#year').click(function(){set_time_frame('year')});
    $('#month').click(function(){set_time_frame('month')});

});
