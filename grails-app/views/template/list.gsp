<%@ page import="au.org.ala.volunteer.Template" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
        <g:set var="entityName" value="${message(code: 'template.label', default: 'Template')}" />
        <r:require module="jquery-ui" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
        <style type="text/css">

            table.bvp-expeditions thead th {
                text-align: left;
            }

        </style>
        <r:script type="text/javascript">

            $(function() {

                $(".btnDeleteTemplate").click(function(e) {
                    e.preventDefault();
                    var templateId = $(this).parents("[templateId]").attr("templateId");
                    var templateName = $(this).parents("[templateName]").attr("templateName");
                    if (templateId && templateName) {
                        if (confirm("Are you sure you wish to delete template " + templateName + "?")) {
                            window.location = "${createLink(controller:'template', action:'delete')}/" + templateId;
                        }
                    }
                });

                $(".btnCloneTemplate").click(function(e) {
                    e.preventDefault();
                    var oldTemplateId = $(this).parents("[templateId]").attr("templateId");
                    var oldTemplateName = $(this).parents("[templateName]").attr("templateName");

                    if (oldTemplateId && oldTemplateName) {
                        bvp.showModal({
                            url:"${createLink(action:'cloneTemplateFragment')}?sourceTemplateId=" + oldTemplateId,
                            title:"Clone template '" + oldTemplateName + "'"
                        });
                    }
                });

            });

        </r:script>
    </head>
    <body>

        <cl:headerContent title="${message(code: 'default.list.label', args: [entityName])}">
            <%
                pageScope.crumbs = [
                    [link: createLink(controller: 'admin', action: 'index'), label: 'Administration']
                ]
            %>
            <div>
                <a href="${createLink(action:'create')}" class="btn">Create new template</a>
            </div>
        </cl:headerContent>

        <div class="row" id="content">
            <div class="span12">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <g:sortableColumn property="name" title="${message(code: 'template.name.label', default: 'Name')}" />
                            <g:sortableColumn property="author" title="${message(code: 'template.author.label', default: 'Author')}" />
                            <g:sortableColumn property="viewName" title="${message(code: 'template.viewName.label', default: 'View Name')}" />
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${templateInstanceList}" status="i" var="templateInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}" templateId="${templateInstance.id}" templateName="${templateInstance.name}" >

                            <td>${fieldValue(bean: templateInstance, field: "name")}</td>
                            <td>${cl.emailForUserId(id: templateInstance.author)}</td>
                            <td>${fieldValue(bean: templateInstance, field: "viewName")}</td>

                            <td>
                                <a class="btn btnCloneTemplate" href="#" style="margin-top: 6px">Clone</a>
                                <a class="btn" style="margin-top: 6px" href="${createLink(controller:'template', action:'edit', id:templateInstance.id)}">Edit</a>
                                <a class="btn" style="margin-top: 6px" href="${createLink(controller:'template', action:'preview', id:templateInstance.id)}">Preview</a>
                                <a class="btn btn-danger btnDeleteTemplate" href="#" style="margin-top: 6px">Delete</a>
                            </td>
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="pagination">
                <g:paginate total="${templateInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
