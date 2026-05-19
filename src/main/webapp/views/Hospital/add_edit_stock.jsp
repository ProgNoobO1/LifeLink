<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% request.setAttribute("pageTitle", (request.getAttribute("mode") == "edit" ? "Edit" : "Add") + " Blood Stock"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div class="d-flex align-center gap-12">
                <a href="${pageContext.request.contextPath}/hospital/stock" class="text-muted" style="font-size:20px;">←</a>
                <div>
                    <div class="page-title">${mode == 'edit' ? 'Edit' : 'Add'} Blood Stock</div>
                    <div class="page-subtitle">Fill in the details to ${mode == 'edit' ? 'update' : 'add new'} blood units to inventory</div>
                </div>
            </div>
            <div class="header-actions">
                <div class="user-pill">
                    <div class="user-avatar">🏥</div>
                    <div><div class="user-name">${hospital.hospitalName}</div><div class="user-role">Hospital</div></div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <div class="grid-2">
                <!-- Main Form -->
                <div class="card fade-in">
                    <div class="card-header border-bottom pb-16 mb-20" style="border-bottom: 1px solid var(--border);">
                        <div class="d-flex align-center gap-12">
                            <div class="stat-icon red" style="width:40px;height:40px;font-size:20px;">🩸</div>
                            <div>
                                <div class="card-title">Stock Details</div>
                                <div class="card-subtitle">Enter the blood unit information below</div>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/hospital/stock/form" class="btn btn-secondary btn-sm">+ New Entry</a>
                    </div>

                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/hospital/stock/form" id="stockForm" novalidate>
                        <input type="hidden" name="mode" value="${mode}">
                        <c:if test="${mode == 'edit'}">
                            <input type="hidden" name="stockId" value="${stock.id}">
                        </c:if>

                        <!-- Blood Group -->
                        <div class="form-group">
                            <label for="bloodGroup" class="form-label">Blood Group <span class="text-danger">*</span></label>
                            <select name="bloodGroup" id="bloodGroup" class="form-control" ${mode == 'edit' ? 'readonly' : ''} required>
                                <option value="">Select blood group</option>
                                <c:forEach var="group" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                                    <option value="${group}" ${mode == 'edit' && stock.bloodGroup == group ? 'selected' : ''}>${group}</option>
                                </c:forEach>
                            </select>
                            <div class="form-hint">Select the ABO blood group and Rh factor</div>
                        </div>

                        <!-- Number of Units -->
                        <div class="form-group">
                            <label for="units" class="form-label">Number of Units <span class="text-danger">*</span></label>
                            <div class="d-flex align-center gap-8">
                                <input type="number" name="units" id="units" class="form-control"
                                       value="${mode == 'edit' ? stock.unitsAvailable : ''}"
                                       min="0" max="9999" placeholder="e.g. 25" required style="width: 150px;">
                                <span class="text-muted">units</span>
                            </div>
                            <div class="form-hint">Enter the total number of blood units being ${mode == 'edit' ? 'updated' : 'added'}</div>
                        </div>

                        <!-- Collection & Expiry Date (Visual/Mock fields for high-fidelity UI matching) -->
                        <div class="grid-2 mb-20">
                            <div class="form-group" style="margin-bottom:0;">
                                <label for="collectionDate" class="form-label">Collection Date <span class="text-danger">*</span></label>
                                <input type="date" name="collectionDate" id="collectionDate" class="form-control" required>
                                <div class="form-hint">Date blood was drawn</div>
                            </div>
                            <div class="form-group" style="margin-bottom:0;">
                                <label for="expiryDate" class="form-label">Expiry Date <span class="text-danger">*</span></label>
                                <input type="date" name="expiryDate" id="expiryDate" class="form-control" required>
                                <div class="form-hint">Typically 35 days standard shelf-life</div>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="d-flex gap-12 mt-28">
                            <button type="submit" class="btn btn-primary" id="submitBtn" style="background:#C51B27; border-color:#C51B27;">
                                💾 ${mode == 'edit' ? 'Update' : 'Save'} Stock
                            </button>
                            <a href="${pageContext.request.contextPath}/hospital/stock" class="btn btn-secondary">
                                ✕ Cancel
                            </a>
                        </div>
                    </form>
                </div>

                <!-- Right Sidebar -->
                <div style="display:flex; flex-direction:column; gap:20px;">
                    <!-- Quick Tips -->
                    <div class="card fade-in delay-1">
                        <div class="card-header">
                            <div class="card-title">💡 Quick Tips</div>
                        </div>
                        <div style="display:flex;flex-direction:column;gap:12px">
                            <div class="d-flex align-start gap-8">
                                <span class="text-success">✔</span>
                                <span>Double-check the blood group before saving.</span>
                            </div>
                            <div class="d-flex align-start gap-8">
                                <span class="text-success">✔</span>
                                <span>Whole blood typically expires in 35 days.</span>
                            </div>
                            <div class="d-flex align-start gap-8">
                                <span class="text-success">✔</span>
                                <span>Expiry date must be after collection date.</span>
                            </div>
                            <div class="d-flex align-start gap-8">
                                <span class="text-success">✔</span>
                                <span>All fields marked with * are required.</span>
                            </div>
                        </div>
                    </div>

                    <!-- Current Stock Overview -->
                    <div class="card fade-in delay-2">
                        <div class="card-header">
                            <div class="card-title">📊 Current Stock</div>
                        </div>
                        <div style="display:flex;flex-direction:column;gap:12px">
                            <c:forEach var="s" items="${existingGroups}">
                                <div class="d-flex align-center justify-between pb-8" style="border-bottom:1px solid var(--border);">
                                    <div class="d-flex align-center gap-12">
                                        <div class="blood-badge" style="width:32px;height:32px;font-size:11px;">${s.bloodGroup}</div>
                                        <span class="text-muted fs-13">Type ${s.bloodGroup}</span>
                                    </div>
                                    <div class="d-flex align-center gap-12">
                                        <div><span class="fw-700">${s.unitsAvailable}</span> <span class="text-muted fs-12">units</span></div>
                                        <div class="progress" style="width:50px;height:4px;">
                                            <div class="progress-bar ${s.unitsAvailable < 5 ? 'red' : s.unitsAvailable < 15 ? 'yellow' : 'green'}"
                                                 style="width: ${s.progressWidth}%"></div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${not empty existingGroups}">
                                <div class="d-flex justify-between mt-8">
                                    <span class="text-muted fw-600 fs-13">Total Inventory</span>
                                    <span class="fw-700">
                                        <c:set var="totalInv" value="0"/>
                                        <c:forEach var="s" items="${existingGroups}">
                                            <c:set var="totalInv" value="${totalInv + s.unitsAvailable}"/>
                                        </c:forEach>
                                        ${totalInv} units
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${empty existingGroups}">
                                <p class="text-muted text-center py-16">No stock entries yet</p>
                            </c:if>
                        </div>
                        
                        <!-- Low Stock Alert in sidebar -->
                        <c:set var="hasLow" value="false"/>
                        <c:forEach var="s" items="${existingGroups}">
                            <c:if test="${s.unitsAvailable < 5}"><c:set var="hasLow" value="true"/></c:if>
                        </c:forEach>
                        <c:if test="${hasLow == 'true'}">
                            <div class="alert alert-danger mt-20" style="padding:12px;">
                                <div class="d-flex align-center gap-8 mb-8">
                                    <span>⚠️</span>
                                    <strong>Low Stock Alert</strong>
                                </div>
                                <div class="fs-12 text-muted">
                                    <c:forEach var="s" items="${existingGroups}">
                                        <c:if test="${s.unitsAvailable < 5}">${s.bloodGroup} </c:if>
                                    </c:forEach>
                                    are critically low. Consider prioritizing these groups.
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/hospital_footer.jsp" %>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        var colInput = document.getElementById('collectionDate');
        var expInput = document.getElementById('expiryDate');
        if (colInput && expInput && !colInput.value) {
            // Fill collection date with today
            var today = new Date();
            var yyyy = today.getFullYear();
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var dd = String(today.getDate()).padStart(2, '0');
            colInput.value = yyyy + '-' + mm + '-' + dd;
            
            // Fill expiry date with today + 35 days
            var expiry = new Date();
            expiry.setDate(today.getDate() + 35);
            var e_yyyy = expiry.getFullYear();
            var e_mm = String(expiry.getMonth() + 1).padStart(2, '0');
            var e_dd = String(expiry.getDate()).padStart(2, '0');
            expInput.value = e_yyyy + '-' + e_mm + '-' + e_dd;
        }
    });

    document.getElementById('stockForm').addEventListener('submit', function(e) {
        var bloodGroup = document.getElementById('bloodGroup').value;
        var units = document.getElementById('units').value;
        var isValid = true;
        if (!bloodGroup) { document.getElementById('bloodGroup').style.borderColor = 'var(--danger)'; isValid = false; }
        else { document.getElementById('bloodGroup').style.borderColor = ''; }
        if (!units || parseInt(units) < 0 || isNaN(units)) { document.getElementById('units').style.borderColor = 'var(--danger)'; isValid = false; }
        else { document.getElementById('units').style.borderColor = ''; }
        if (!isValid) e.preventDefault();
    });
</script>
