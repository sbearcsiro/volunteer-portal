<%@ page contentType="text/html;charset=UTF-8" import="org.codehaus.groovy.grails.commons.ConfigurationHolder" %>
<!DOCTYPE html>
<html>
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${ConfigurationHolder.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      %{--<link rel="icon" type="image/x-icon" href="${ConfigurationHolder.config.ala.baseURL}/wp-content/themes/ala/images/favicon.ico"/>--}%
      %{--<g:javascript library="jquery-1.5.1.min"/>--}%
      <g:javascript library="jquery.tools.min"/>
      <style type="text/css">

        div#wrapper > div#content {
            background-color: transparent !important;
        }

        .volunteerportal #page-header {
        	background:#f0f0e8 url(${resource(dir:'images/vp',file:'bg_volunteerportal.jpg')}) center top no-repeat;
        	padding-bottom:12px;
        	border:1px solid #d1d1d1;
        }

      </style>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="tutorials" />

    <header id="page-header">
      <div class="inner">
        <cl:messages />
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li><a href="${createLink(uri: '/tutorials.gsp')}"><g:message code="default.tutorials.label" default="Tutorials"/></a></li>
            <li class="last"><g:message code="default.fieldnotestutorial.label" default="Tutorials - Transcribing Field Notes" /></li>
          </ol>
        </nav>
        <h1>Transcribing Field Notes</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <h3>Login to the Biodiversity Volunteer Portal using your email and password.</h3>
        <h3>Join a virtual expedition.</h3>
        <br />
        <img src="${resource(dir: 'images/tutorials', file:'fieldnotes_01.png')}" />
        <h3>To join a field notes expedition choose an expedition with the field notes icon in the type column.
        Once in the expedition, click on <img src="${resource(dir:'images/tutorials', file:'fieldnotes_02.png')}" />
        </h3>

      </div>
    </div>
  </body>
</html>
