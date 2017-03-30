<%
    ui.includeJavascript("ugandaemrfingerprint", "patientsearch/sockjs-0.3.4.js")
    ui.includeJavascript("ugandaemrfingerprint", "patientsearch/stomp.js")
    ui.decorateWith("appui", "standardEmrPage", [title: ui.message("Patients From Other Health Centers")])

    def htmlSafeId = { extension ->
        "${extension.id.replace(".", "-")}-${extension.id.replace(".", "-")}-extension"
    }

    def breadcrumbMiddle = breadcrumbOverride ?: '';
%>
<script type="text/javascript">

    var breadcrumbs = [
        {icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm'},
        {
            label: "${ ui.escapeJs(ui.message("Find Patient From other Facility.")) }",
        }
    ];


    var socket = new SockJS('http://192.168.1.186:8084/complete/search');
    stompClient = Stomp.over(socket);
    stompClient.connect({}, function (frame) {
        stompClient.subscribe('/topic/showResult', function (calResult) {
            showResult(JSON.parse(calResult.body));
        });
    });


    function search() {
        document.getElementById('calResponse').innerHTML = "";
        document.getElementById('images').innerHTML = "";
        document.getElementById('fingerprint').value = '';
        document.getElementById('onlinesearch').value = '';
        document.getElementById('onlinesearch').disabled = true;
        stompClient.send("/calcApp/fingerprint", {});
    }

    function showResult(message) {
        var response = document.getElementById('calResponse');
        var imageDiv = document.getElementById('images');
        if (message.type === "image") {
            document.getElementById('calResponse').innerHTML = "";
            var imageTag = document.createElement('img');
            document.getElementById('fingerprint').value = message.result;
            document.getElementById('onlinesearch').value = '';
            imageTag.src = "data:image/png;base64," + message.result;
            imageDiv.appendChild(imageTag);
        }
        else {
            response.innerHTML = message.result;
        }
    }


    function remoteSearch() {
        jq.post("http://192.168.1.28/api/query",
                {query: '{patient(attribute:{t:"8d871f2a-c2cc-11de-8d13-0010c6dffd0f",v:"1056"}){uuid,facility,birthdate,gender}}'},
                function (response) {
                    console.log(response.data);
                });
    }
</script>
<style type="text/css">
#death-date-display {
    min-width: 35%;
}

span.field-error {
    padding: 1px 6px 1px 6px;
    margin-left: 4px;
    margin-right: 4px;
    vertical-align: middle;
    color: red;
}

img {
    width: 100px;
    height: auto;
}
</style>

<h3>Locate Patient From other Facility</h3>

<form method="post">
    <fieldset style="min-width:100%">
        <input type="hidden" name="fingerprint" id="fingerprint">

        <div class="scan-input">
            <input type="text" name="onlinesearch" id="onlinesearch" class="field-display ui-autocomplete-input left"
                   placeholder="Type National Id" size="100">
        </div>

        <div><input type="button" value="Read Fingerprint" id="search" ></div>

        <p id="calResponse"></p>

        <div id="images"></div>

        <div class="left"><input type="button" value="Search" onclick="remoteSearch()"></div>
        <br>
    </fieldset>
</form>

<% if (searched == true && connectionStatus != "") { %>
<div class="toast-item-wrapper">
    <div class="toast-item toast-type-error">
        <div class="toast-item-image toast-item-image-error"></div>

        <div class="toast-item-close"></div>

        <p>${connectionStatus}</p>
    </div>
</div>


<% } %>

<% if (searched == true && patientFound == false) { %>
<div class="toast-item-wrapper">
    <div class="toast-item toast-type-error">
        <div class="toast-item-image toast-item-image-error"></div>

        <div class="toast-item-close"></div>

        <p>${patientNotFound}</p>
    </div>
</div>
<% } %>

<% if (patientFound == true && searched == true) { %>
<fieldset>
    <table>
        <thead>
        <td>Facility Name</td>
        <td>Facility Id</td>
        <td>Patient Id</td>
        <td>Patient Summary</td>
        </thead>
        <tbody>
        <td><% facilityName ?: "No Results" %></td>
        <td><% facilityId ?: "No Results" %></td>
        <td><% patientId ?: "No Results" %></td>
        <td><% patientSummary ?: "No Results" %></td>

        </tbody>
    </table>
</fieldset>
<% } %>