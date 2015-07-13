$(document).ready(function() {
    var time_frame = 'year'
    var date = ($.urlParam('date') == null ? new Date().toJSON().slice(0,10) : $.urlParam('date'))
    var userStatistics
    var options
    var options_overview = {
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
            type: 'datetime'
            //min: new Date().setMonth(new Date().getMonth() - 3),
            //max: new Date().setMonth(new Date().getMonth() + 1)
        },
        credits: { enabled: false },
        plotOptions: {
            spline: {
                connectNulls: true
            }
        }
    };
    var options_activity = {
            chart: {
                renderTo: 'dashboard-chart',
                zoomType: 'x'
            },
            title: { text: 'Activity' },
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
                type: 'linear'
            },
            credits: { enabled: false },
            plotOptions: {
                spline: {
                    connectNulls: true,
                    connectEnds: true
                }
            }
        };



    function set_up_graph(graphData, i) {
        graphData.yAxis = i;
        chart.yAxis[i].setTitle({ text: graphData.unit });
        chart.addSeries(graphData);
    }
    function set_up_chart(seriesArray) {
        chart = new Highcharts.Chart(options);
        seriesArray.forEach(function(graphData, i){
            set_up_graph(graphData, i)
        });
    }

    function show_tlf() {
        options = options_overview;
        seriesArray = [userStatistics.trimp, userStatistics.load, userStatistics.fatique]
        set_up_chart(seriesArray)
    };

    function show_add() {
        options = options_overview
        seriesArray = [userStatistics.avghr, userStatistics.distance, userStatistics.duration]
        set_up_chart(seriesArray)
    };

    function get_user_statistics() {
        var url = "/statistics/user/2015"
        $.getJSON(url, function(data){
            userStatistics = data;
            show_tlf();
        });
    }

    get_user_statistics();

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

    function show_activity(data) {
        seriesArray = [data.hrbpm, data.alt, data.speed];
        options = options_activity;
        options.title.text = "Activity " + data.start_time;
        var min = new Date(data.start_time)
        var max = new Date(data.end_time)
        set_up_chart(seriesArray)
        //chart.xAxis[0].setExtremes(0,200);
    }

    function get_activity(id){
        var url = "/statistics/activity/" + id;
        $.getJSON(url, function(data){
            show_activity(data);
        });
    }

    $('.activity').click(function(e){
        e.preventDefault();
        get_activity($(this).data('id'));
    })
});
