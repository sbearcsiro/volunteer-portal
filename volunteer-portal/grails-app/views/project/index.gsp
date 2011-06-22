<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<%@ page import="au.org.ala.volunteer.Task" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<%@ page import="au.org.ala.volunteer.FieldSyncService" %>
<g:set var="tasksDone" value="${Task.countByProjectAndFullyTranscribedByIsNotNull(Project.get(params.id))}"/>
<g:set var="tasksTotal" value="${taskCount}"/>
<g:set var="tasksDonePercent" value="${(tasksDone / tasksTotal) * 100}"/>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="main"/>
    <title>Volunteer Portal - Atlas of Living Australia</title>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>
    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script type='text/javascript'>
        google.load('visualization', '1', {packages:['gauge']});

        function loadChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Label');
            data.addColumn('number', 'Value');
            data.addRows(3);
            data.setValue(0, 0, '%');
            data.setValue(0, 1, <g:formatNumber number="${tasksDonePercent}" format="#"/>);

            var chart = new google.visualization.Gauge(document.getElementById('recordsChartWidget'));
            var options = {width: 150, height: 150, minorTicks: 5, majorTicks: ["0%","25%","50%","75%","100%"]};
            chart.draw(data, options);
        }

        google.load("maps", "3.5", {other_params:"sensor=false"});

        function loadMap() {
            var myOptions = {
                scaleControl: true,
                streetViewControl: false,
                scrollwheel: false,
                mapTypeControl: true,
                mapTypeControlOptions: {
                    style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
                },
                navigationControl: true,
                navigationControlOptions: {
                    style: google.maps.NavigationControlStyle.SMALL // DEFAULT
                },
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            var map = new google.maps.Map(document.getElementById("recordsMap"), myOptions);
            var latlngbounds = new google.maps.LatLngBounds();

            <g:each in="${taskListFields}" status="i" var="recordValues">
                <g:set var="lat" value="${recordValues?.get(0)?.decimalLatitude}"/>
                <g:set var="lng" value="${recordValues?.get(0)?.decimalLongitude}"/>
                <g:if test="${lat && lng}">
                    var latlng_${i} = new google.maps.LatLng(${lat}, ${lng});
                    var marker_${i} = new google.maps.Marker({
                        position: latlng_${i},
                        map: map,
                        title:"record: ${recordValues?.get(0)?.catalogNumber}"
                    });
                    var content = "<div style='font-size:11px;line-height:1.3em;'>Catalogue No.: ${recordValues?.get(0)?.catalogNumber}<br/>Taxa: ${recordValues?.get(0)?.scientificName}<br/>Transcribed by: ${recordValues?.get(0)?.transcribedBy}</div>";
                    var infowindow_${i} = new google.maps.InfoWindow({content: content, noCloseOnClick: false});
                    google.maps.event.addListener(marker_${i}, 'click', function() {
                        infowindow_${i}.open(map, marker_${i});
                    });
                    latlngbounds.extend(latlng_${i});
                </g:if>

            </g:each>
            //map.setCenter(latlngbounds.getCenter(), map.getBoundsZoomLevel(latlngbounds));
            map.fitBounds(latlngbounds);
        }

        $(document).ready(function() {
            // load chart
            //loadChart();
            $("#recordsChartWidget").progressbar({ value: <g:formatNumber number="${tasksDonePercent}" format="#"/> });
            //load map
            loadMap();
        });
    </script>
</head>

<body class="two-column-right">
<div class="body">
    <h1>Welcome to the ${projectInstance.name?:'Volunteer Portal'}</h1>
    <br/>

    <p>${projectInstance.description}</p>

    <div class='front-image'>
        <img src="${resource(dir: 'images', file: 'short-map.jpg')}"/>
    </div>

    <div class='front-buttons buttons-big'>
        <g:link controller="transcribe">
            <img src="${resource(dir: 'images', file: 'start-button.png')}"/>
        </g:link>
    </div>
    <div class='front-buttons buttons-small'>
        <g:link controller="user">
            <img src="${resource(dir: 'images', file: 'score.png')}"/>
        </g:link><br/>
        <g:link controller="user" action="myStats">
            <img src="${resource(dir: 'images', file: 'stats.png')}"/>
        </g:link>
    </div>

    <div id="expedition">
        <div id="personnel">
            <h2>Expedition Personnel</h2>
            <table>
                <thead style="display: none">
                    <tr><td>Role</td><td>Members</td></tr>
                </thead>
                <tbody>
                    <g:each in="${roles}" status="i" var="role">
                        <tr>
                            <td><img src='<g:resource file="${role.icon}"/>' alt="expedition person icon"/></td>
                            <td><strong>${role.name}: </strong><cl:listUsersInRole users="${role.members}"/></td>
                        </tr>
                    </g:each>
                </tbody>
            </table>
        </div>
        <div id="progress" class="">
            <h2>Expedition Progress</h2>
            <div id="recordsChart">
                Records captured: <span style="white-space: nowrap;">${tasksDone} of ${tasksTotal}</span> (<g:formatNumber number="${tasksDonePercent}" format="#"/>%)
            </div>
            <div id="recordsChartWidget"></div>
            <div style="clear: both"></div>
            <div id="recordMapLabel">Showing location of records transcribed to date</div>
            <div id="recordsMap"></div>
        </div>
    </div>
    <div style="clear: both">&nbsp;</div>
</div>
</body>
</html>