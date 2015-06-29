$(document).ready(function() {
    var time_frame = 'year'
    var date = ($.urlParam('date') == null ? new Date().toJSON().slice(0,10) : $.urlParam('date'))
    var options = {

        chart: {
            renderTo: 'dashboard-chart',
            zoomType: 'x'
        },
        title: { text: 'Dashboard' },
        yAxis: [{ title: { text: '' },
                    min: 0
                },
                { title: { text: '' },
                    min: 0
                },
                { title: { text: '' },
                    min: 0,
                    opposite: true
                }
        ],
        xAxis: {
            type: 'datetime',
            min: new Date().setMonth(new Date().getMonth() - 3),
            max: new Date().setMonth(new Date().getMonth() + 1)
        },
        credits: { enabled: false },
        plotOptions: {
            spline: {
                connectNulls: true
            }
        }
    };

    function get_and_show_graph_from_json(url, index, array) {
        $.getJSON(url, function (data) {
            data.yAxis = index;
            chart.addSeries(data);
            if (data.unit == 'no_unit'){ data.unit = data.name }
            chart.yAxis[index].setTitle({text: data.unit})
        });
    }
    function collect_jsons(urls) {
        chart = new Highcharts.Chart(options);
        urls.forEach(get_and_show_graph_from_json)
    }
    function show_tlf()
    {
        var url = "/statistics/fatigue/no_unit/" + time_frame + "/" + date + "/by_days";
        var url2 = "/statistics/load/load/" + time_frame + "/" + date + "/by_days";
        var url3 = "/statistics/trimp/imp/" + time_frame + "/" + date + "/by_days";
        collect_jsons([url, url2, url3]);
    };

    function show_add() {
        var url = "/statistics/distance/km/" + time_frame + "/" + date + "/by_days";
        var url2 = "/statistics/duration/h/" + time_frame + "/" + date + "/by_days";
        var url3 ="/statistics/avghr/bpm/" + time_frame + "/" + date + "/by_days";
        collect_jsons([url, url2, url3])
    };

    function set_time_frame(tf) {
        time_frame = tf;
        show_tlf();
    };

    show_tlf()
    $('#tlf').click(function(){show_tlf()});
    $('#add').click(function(){show_add()});
    $('#standard_range').click(function(){
        var min = new Date().setMonth(new Date().getMonth() - 3);
        var max = new Date().setMonth(new Date().getMonth() + 1)
        chart.xAxis[0].setExtremes(min,max);
    });
    $('#this_year').click(function(){
        var min = new Date(new Date().getFullYear(), 0, 1);
        var max = new Date(new Date().getFullYear(), 11, 31);
        chart.xAxis[0].setExtremes(min,max);
    });
    $('#last_year').click(function(){
        var min = new Date((new Date().getFullYear() - 1), 0, 1);
        var max = new Date((new Date().getFullYear() - 1), 11, 31);
        chart.xAxis[0].setExtremes(min,max);
    });
    $('#this_month').click(function(){
        var min = new Date();
        min.setDate(1);
        var max = new Date();
        max.setMonth(max.getMonth()+1)
        max.setDate(1);
        chart.xAxis[0].setExtremes(min,max);
    });
    $('#last_month').click(function(){
        var min = new Date();
        min.setDate(1);
        min.setMonth(min.getMonth()-1);
        var max = new Date();
        max.setDate(1);
        chart.xAxis[0].setExtremes(min,max);
    });
    $('#last_three_months').click(function(){
        var x = new Date();
        x.setMonth(x.getMonth()-3);
        chart.xAxis[0].setExtremes(x,Date.now());
    });

});
