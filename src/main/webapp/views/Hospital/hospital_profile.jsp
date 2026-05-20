<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% request.setAttribute("pageTitle", "Hospital Profile"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div>
                <div class="page-title">Hospital Profile</div>
                <div class="page-subtitle">Manage your hospital's public information and contact details</div>
            </div>
            <div class="header-actions">
                <div class="user-pill">
                    <div class="user-avatar">🏥</div>
                    <div><div class="user-name">${hospital.hospitalName != null ? hospital.hospitalName : 'Hospital User'}</div><div class="user-role">Hospital</div></div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <c:if test="${param.msg == 'success'}">
                <div class="alert alert-success">✅ Profile updated successfully!</div>
            </c:if>

            <c:if test="${param.error == 'failed'}">
                <div class="alert alert-danger">
                    ❌ Failed to update profile. 
                    <c:if test="${not empty param.detail}">
                        <br><small><strong>Error:</strong> ${param.detail}</small>
                    </c:if>
                </div>
            </c:if>

            <!-- Current Active Profile Details View Card -->
            <div class="card fade-in mb-28" style="max-width: 900px; margin: 0 auto 28px auto; background: var(--bg-surface); border: 1px solid var(--border);">
                <div class="card-header border-bottom pb-16 mb-20" style="border-bottom: 1px solid var(--border);">
                    <div class="card-title" style="display:flex; align-items:center; gap:8px;">🏥 Current Profile Details</div>
                </div>
                <div class="card-body">
                    <div class="grid-2" style="gap: 20px;">
                        <div>
                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">Hospital Name</div>
                            <div class="fs-15 fw-600 mb-16" style="color:var(--text);">${not empty hospital.hospitalName ? hospital.hospitalName : 'Not set'}</div>

                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">License No</div>
                            <div class="fs-15 fw-600 mb-16" style="color:var(--text);">${not empty hospital.licenseNo ? hospital.licenseNo : 'Not set'}</div>

                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">Contact Person</div>
                            <div class="fs-15 fw-600 mb-16" style="color:var(--text);">${not empty hospital.contactPerson ? hospital.contactPerson : 'Not set'}</div>

                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">Website</div>
                            <div class="fs-15 fw-600 mb-16">
                                <c:choose>
                                    <c:when test="${not empty hospital.website}">
                                        <a href="${hospital.website}" target="_blank" style="color:var(--accent); text-decoration:none; font-weight:600;">${hospital.website}</a>
                                    </c:when>
                                    <c:otherwise><span class="text-muted">Not set</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div>
                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">District / Region</div>
                            <div class="fs-15 fw-600 mb-16" style="color:var(--text);">
                                <span id="activeDistrictDisplay">Loading...</span>
                            </div>

                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">Full Address</div>
                            <div class="fs-15 fw-600 mb-16" style="color:var(--text);">${not empty hospital.address ? hospital.address : 'Not set'}</div>

                            <div class="fs-12 text-muted uppercase fw-600 mb-4" style="font-size: 11px; letter-spacing: 0.5px;">Coordinates</div>
                            <div class="fs-14 text-muted mb-16" style="line-height:1.5;">
                                Latitude: <strong style="color:var(--text);">${not empty hospital.latitude ? hospital.latitude : '—'}</strong><br>
                                Longitude: <strong style="color:var(--text);">${not empty hospital.longitude ? hospital.longitude : '—'}</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card fade-in" style="max-width: 900px; margin: 0 auto;">
                <div class="card-header border-bottom pb-16 mb-20" style="border-bottom: 1px solid var(--border);">
                    <div class="card-title">
                        <c:choose>
                            <c:when test="${not empty hospital.hospitalName}">Update Profile Details</c:when>
                            <c:otherwise>Create Profile Setup</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <form action="${pageContext.request.contextPath}/hospital/profile" method="POST">
                    
                    <div class="grid-2 mb-28">
                        <!-- Basic Information -->
                        <div class="form-group">
                            <label class="form-label">Hospital Name *</label>
                            <input type="text" name="hospitalName" class="form-control" value="${hospital.hospitalName}" required>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">License No (Unique) *</label>
                            <input type="text" name="licenseNo" class="form-control" value="${hospital.licenseNo}" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Contact Person</label>
                            <input type="text" name="contactPerson" class="form-control" value="${hospital.contactPerson}">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Website</label>
                            <input type="url" name="website" class="form-control" placeholder="https://..." value="${hospital.website}">
                        </div>
                    </div>

                    <!-- Location Information -->
                    <div class="mt-28 mb-16 pb-8" style="border-bottom: 1px solid var(--border);">
                        <h5 class="fs-16 fw-600">Location Details</h5>
                    </div>

                    <div class="grid-2 mb-28">
                        <div class="form-group">
                            <label class="form-label">District *</label>
                            <select name="districtId" id="districtSelect" class="form-control" required onchange="autoFillCoordinates()">
                                <option value="">Select District</option>
                                <%
                                   String[][] provinces = {
                                       {"Koshi Province", "Bhojpur", "Dhankuta", "Ilam", "Jhapa", "Khotang", "Morang", "Okhaldhunga", "Panchthar", "Sankhuwasabha", "Solukhumbu", "Sunsari", "Taplejung", "Terhathum", "Udayapur"},
                                       {"Madhesh Province", "Bara", "Dhanusha", "Mahottari", "Parsa", "Rautahat", "Saptari", "Sarlahi", "Siraha"},
                                       {"Bagmati Province", "Bhaktapur", "Chitwan", "Dhading", "Dolakha", "Kathmandu", "Kavrepalanchok", "Lalitpur", "Makwanpur", "Nuwakot", "Ramechhap", "Rasuwa", "Sindhuli", "Sindhupalchok"},
                                       {"Gandaki Province", "Baglung", "Gorkha", "Kaski", "Lamjung", "Manang", "Mustang", "Myagdi", "Nawalparasi (East)", "Parbat", "Syangja", "Tanahu"},
                                       {"Lumbini Province", "Arghakhanchi", "Banke", "Bardiya", "Dang", "Eastern Rukum", "Gulmi", "Kapilvastu", "Nawalparasi (West)", "Palpa", "Pyuthan", "Rolpa", "Rupandehi"},
                                       {"Karnali Province", "Dailekh", "Dolpa", "Humla", "Jajarkot", "Jumla", "Kalikot", "Mugu", "Salyan", "Surkhet", "Western Rukum"},
                                       {"Sudurpashchim Province", "Achham", "Baitadi", "Bajhang", "Bajura", "Dadeldhura", "Darchula", "Doti", "Kailali", "Kanchanpur"}
                                   };
                                   lifelink.model.Hospital h = (lifelink.model.Hospital) request.getAttribute("hospital");
                                   int selectedId = h != null ? h.getDistrictId() : 0;
                                   int distId = 1;
                                   for (String[] province : provinces) {
                                       out.print("<optgroup label='" + province[0] + "'>");
                                       for (int i = 1; i < province.length; i++) {
                                           String selected = (selectedId == distId) ? "selected" : "";
                                           out.print("<option value='" + distId + "' " + selected + ">" + province[i] + "</option>");
                                           distId++;
                                       }
                                       out.print("</optgroup>");
                                   }
                                %>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Full Address</label>
                            <input type="text" name="address" class="form-control" placeholder="Street, Ward No, Municipality" value="${hospital.address}">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Latitude <span class="text-muted fs-12">(auto-filled from district)</span></label>
                            <input type="number" step="0.0000001" name="latitude" id="latitudeField" class="form-control" placeholder="27.7172" value="${hospital.latitude}" readonly style="background-color: var(--bg-primary); opacity:0.7;">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Longitude <span class="text-muted fs-12">(auto-filled from district)</span></label>
                            <input type="number" step="0.0000001" name="longitude" id="longitudeField" class="form-control" placeholder="85.3240" value="${hospital.longitude}" readonly style="background-color: var(--bg-primary); opacity:0.7;">
                        </div>
                    </div>

                    <div class="d-flex justify-between pt-20" style="border-top: 1px solid var(--border);">
                        <a href="${pageContext.request.contextPath}/hospital/dashboard" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">
                            <c:choose>
                                <c:when test="${not empty hospital.hospitalName}">Update Profile</c:when>
                                <c:otherwise>Create Profile</c:otherwise>
                            </c:choose>
                        </button>
                    </div>
                    
                </form>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/hospital_footer.jsp" %>
<script>
// District coordinates — IDs match province-grouped order (1-77)
const districtCoords = {
    // ─── Koshi Province (1-14) ───
    1:  {lat: 27.1700, lng: 87.0500},  // Bhojpur
    2:  {lat: 26.9800, lng: 87.3500},  // Dhankuta
    3:  {lat: 26.9100, lng: 87.9200},  // Ilam
    4:  {lat: 26.5400, lng: 87.8900},  // Jhapa
    5:  {lat: 27.0200, lng: 86.8200},  // Khotang
    6:  {lat: 26.6600, lng: 87.4700},  // Morang
    7:  {lat: 27.3200, lng: 86.5000},  // Okhaldhunga
    8:  {lat: 27.1300, lng: 87.7000},  // Panchthar
    9:  {lat: 27.4000, lng: 87.2000},  // Sankhuwasabha
    10: {lat: 27.7900, lng: 86.5800},  // Solukhumbu
    11: {lat: 26.6600, lng: 87.1700},  // Sunsari
    12: {lat: 27.3500, lng: 87.6700},  // Taplejung
    13: {lat: 27.1000, lng: 87.5500},  // Terhathum
    14: {lat: 26.9300, lng: 86.9800},  // Udayapur

    // ─── Madhesh Province (15-22) ───
    15: {lat: 27.0800, lng: 85.0600},  // Bara
    16: {lat: 26.8600, lng: 86.0100},  // Dhanusha
    17: {lat: 26.9200, lng: 85.9200},  // Mahottari
    18: {lat: 27.1400, lng: 84.9900},  // Parsa
    19: {lat: 27.0700, lng: 85.2700},  // Rautahat
    20: {lat: 26.7300, lng: 86.7400},  // Saptari
    21: {lat: 26.9800, lng: 85.6100},  // Sarlahi
    22: {lat: 26.6500, lng: 86.2100},  // Siraha

    // ─── Bagmati Province (23-35) ───
    23: {lat: 27.6710, lng: 85.4298},  // Bhaktapur
    24: {lat: 27.5291, lng: 84.3542},  // Chitwan
    25: {lat: 27.8700, lng: 84.9200},  // Dhading
    26: {lat: 27.6500, lng: 86.0700},  // Dolakha
    27: {lat: 27.7172, lng: 85.3240},  // Kathmandu
    28: {lat: 27.5500, lng: 85.6200},  // Kavrepalanchok
    29: {lat: 27.6588, lng: 85.3247},  // Lalitpur
    30: {lat: 27.4100, lng: 85.0300},  // Makwanpur
    31: {lat: 27.9100, lng: 85.1600},  // Nuwakot
    32: {lat: 27.5400, lng: 86.0600},  // Ramechhap
    33: {lat: 28.0600, lng: 85.3800},  // Rasuwa
    34: {lat: 27.2100, lng: 85.9700},  // Sindhuli
    35: {lat: 27.9500, lng: 85.7100},  // Sindhupalchok

    // ─── Gandaki Province (36-46) ───
    36: {lat: 28.2700, lng: 83.5900},  // Baglung
    37: {lat: 28.3800, lng: 84.6300},  // Gorkha
    38: {lat: 28.2096, lng: 83.9856},  // Kaski
    39: {lat: 28.2700, lng: 84.4100},  // Lamjung
    40: {lat: 28.6700, lng: 84.0200},  // Manang
    41: {lat: 28.8100, lng: 83.8600},  // Mustang
    42: {lat: 28.3700, lng: 83.4700},  // Myagdi
    43: {lat: 27.6400, lng: 84.1100},  // Nawalparasi (East)
    44: {lat: 28.2200, lng: 83.5700},  // Parbat
    45: {lat: 28.0900, lng: 83.8800},  // Syangja
    46: {lat: 28.0500, lng: 84.2300},  // Tanahu

    // ─── Lumbini Province (47-58) ───
    47: {lat: 27.9500, lng: 83.1500},  // Arghakhanchi
    48: {lat: 28.0500, lng: 81.5900},  // Banke
    49: {lat: 28.2300, lng: 81.2900},  // Bardiya
    50: {lat: 28.0000, lng: 82.3000},  // Dang
    51: {lat: 28.6000, lng: 82.4500},  // Eastern Rukum
    52: {lat: 28.0900, lng: 83.2800},  // Gulmi
    53: {lat: 27.5500, lng: 83.0500},  // Kapilvastu
    54: {lat: 27.4800, lng: 83.6700},  // Nawalparasi (West)
    55: {lat: 27.8800, lng: 83.5400},  // Palpa
    56: {lat: 28.1000, lng: 82.8700},  // Pyuthan
    57: {lat: 28.2700, lng: 82.6600},  // Rolpa
    58: {lat: 27.5000, lng: 83.4400},  // Rupandehi

    // ─── Karnali Province (59-68) ───
    59: {lat: 28.8500, lng: 81.7200},  // Dailekh
    60: {lat: 29.0500, lng: 82.8500},  // Dolpa
    61: {lat: 29.9700, lng: 81.8900},  // Humla
    62: {lat: 28.7100, lng: 82.1900},  // Jajarkot
    63: {lat: 29.2700, lng: 82.1900},  // Jumla
    64: {lat: 29.0300, lng: 81.7800},  // Kalikot
    65: {lat: 29.4800, lng: 82.0800},  // Mugu
    66: {lat: 28.3800, lng: 82.1600},  // Salyan
    67: {lat: 28.6000, lng: 81.6200},  // Surkhet
    68: {lat: 28.5900, lng: 82.2700},  // Western Rukum

    // ─── Sudurpashchim Province (69-77) ───
    69: {lat: 29.0400, lng: 81.2400},  // Achham
    70: {lat: 29.5200, lng: 80.7300},  // Baitadi
    71: {lat: 29.5400, lng: 81.1900},  // Bajhang
    72: {lat: 29.3800, lng: 81.6300},  // Bajura
    73: {lat: 29.3000, lng: 80.5800},  // Dadeldhura
    74: {lat: 29.8500, lng: 80.5500},  // Darchula
    75: {lat: 29.2500, lng: 80.9500},  // Doti
    76: {lat: 28.7000, lng: 80.9400},  // Kailali
    77: {lat: 28.8400, lng: 80.3200}   // Kanchanpur
};

function autoFillCoordinates() {
    const select = document.getElementById('districtSelect');
    const latField = document.getElementById('latitudeField');
    const lngField = document.getElementById('longitudeField');
    const distId = parseInt(select.value);

    if (districtCoords[distId]) {
        latField.value = districtCoords[distId].lat;
        lngField.value = districtCoords[distId].lng;
    } else {
        latField.value = '';
        lngField.value = '';
    }
}

document.addEventListener("DOMContentLoaded", function() {
    const select = document.getElementById('districtSelect');
    const display = document.getElementById('activeDistrictDisplay');
    if (select && display) {
        const selectedOption = select.options[select.selectedIndex];
        if (selectedOption && select.value) {
            display.innerText = selectedOption.text;
        } else {
            display.innerText = "Not set";
        }
    }
});
</script>
