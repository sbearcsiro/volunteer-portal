<%
    def dateLayout = "YMD"
    if (field.layoutClass?.contains("DMY")) {
        dateLayout = "DMY"
    } else if (field.layoutClass?.contains("MDY")) {
        dateLayout = "MDY"
    } else if (field.layoutClass?.contains("YMD")) {
        dateLayout = "YMD"
    }

%>
<div class="dateWidget" targetField="${field.fieldType}" >

    <div class="row-fluid control-group" >
        <div class="span3">
            (from)
        </div>
        <g:set var="count" value="${0}" />

        <g:each var="letter" in="${dateLayout}">

            <g:set var="ti" value="${tabindex ? tabindex + count : null}" />

            <g:if test="${letter == 'Y'}">
                <div class="span3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.startYear" placeholder="Year" class="span12 startYear year" value="" />
                </div>
            </g:if>
            <g:elseif test="${letter == 'M'}">
                <div class="span3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.startMonth" placeholder="MM" class="span12 startMonth month" value="" />
                </div>
            </g:elseif>
            <g:elseif test="${letter == 'D'}">
                <div class="span3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.startDay" placeholder="DD" class="span12 startDay day" value="" />
                </div>
            </g:elseif>
            <g:set var="count" value="${count + 1}" />
        </g:each>
    </div>
    <div class="row-fluid control-group">
        <div class="span3">
            (to)
        </div>

        <g:each var="letter" in="${dateLayout}">
            <g:set var="ti" value="${tabindex ? tabindex + count : null}" />

            <g:if test="${letter == 'Y'}">
                <div class="span3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.endYear" placeholder="Year" class="span12 endYear year" value="" />
                </div>
            </g:if>
            <g:elseif test="${letter == 'M'}">
                <div class="span3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.endMonth" placeholder="MM" class="span12 endMonth month" value="" />
                </div>
            </g:elseif>
            <g:elseif test="${letter == 'D'}">
                <div class="span3">
                    <g:textField tabindex="${ti}" name="${field.fieldType}.endDay" placeholder="DD" class="span12 endDay day" value="" />
                </div>
            </g:elseif>
            <g:set var="count" value="${count + 1}" />
        </g:each>
    </div>
    <g:hiddenField id="recordValues.0.${field.fieldType}" name="recordValues.0.${field.fieldType}" value="${value}" validationRule="${field.validationRule}" />
</div>
