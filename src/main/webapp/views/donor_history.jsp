<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donation History - LifeLink</title>
    <jsp:include page="partials/head_styles.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <!-- Summary Stats -->
            <div class="stats-grid">
                <div class="stat-card-white" style="flex-direction: row; align-items: center; gap: 1.5rem;">
                    <div class="stat-icon icon-red" style="width: 50px; height: 50px;"><i class="fas fa-tint"></i></div>
                    <div>
                        <span class="value" style="font-size: 1.5rem;">${totalDonations}</span>
                        <span class="label">Total Donations</span>
                    </div>
                </div>
            </div>

            <!-- History Table -->
            <div class="card-premium">
                <div class="card-title" style="flex-wrap: wrap; gap: 1rem;">
                    <span>Donation Records</span>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <button id="toggleFilterBtn" class="btn-premium btn-secondary" style="font-size: 0.75rem;"><i class="fas fa-filter"></i> Filter</button>
                    </div>
                </div>

                <!-- Expandable Date Filter Panel -->
                <div id="filterPanel" style="display: none; background: rgba(0,0,0,0.02); border: 1px solid rgba(0,0,0,0.05); padding: 1.2rem; border-radius: 12px; margin-bottom: 1.5rem;">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; align-items: flex-end;">
                        <div>
                            <label style="display: block; font-size: 0.75rem; font-weight: 600; color: #666; margin-bottom: 0.4rem;">From Date</label>
                            <input type="date" id="filterFromDate" style="width: 100%; padding: 0.6rem; border: 1px solid #ddd; border-radius: 8px; font-size: 0.85rem; outline: none; background: #fff;" />
                        </div>
                        <div>
                            <label style="display: block; font-size: 0.75rem; font-weight: 600; color: #666; margin-bottom: 0.4rem;">To Date</label>
                            <input type="date" id="filterToDate" style="width: 100%; padding: 0.6rem; border: 1px solid #ddd; border-radius: 8px; font-size: 0.85rem; outline: none; background: #fff;" />
                        </div>
                        <div style="display: flex; gap: 0.5rem;">
                            <button id="applyFilterBtn" class="btn-premium btn-primary" style="flex: 1; padding: 0.6rem 1rem; font-size: 0.8rem; height: 38px;"><i class="fas fa-check"></i> Apply</button>
                            <button id="resetFilterBtn" class="btn-premium btn-secondary" style="flex: 1; padding: 0.6rem 1rem; font-size: 0.8rem; height: 38px;"><i class="fas fa-undo"></i> Clear</button>
                        </div>
                    </div>
                </div>
                
                <div class="table-container">
                    <table class="table-premium">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Hospital / Center</th>
                                <th>Blood Group</th>
                                <th>Units</th>
                                <th>Status</th>
                                <th>Certificate</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${history}">
                                <tr data-date="<fmt:formatDate value="${item.requestDate}" pattern="yyyy-MM-dd" />">
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                                            <div style="background: rgba(217, 4, 41, 0.05); color: var(--active-red); padding: 0.4rem; border-radius: 6px; text-align: center; min-width: 45px;">
                                                <span style="display: block; font-size: 0.65rem; text-transform: uppercase;"><fmt:formatDate value="${item.requestDate}" pattern="MMM" /></span>
                                                <span style="display: block; font-size: 0.9rem; font-weight: 700;"><fmt:formatDate value="${item.requestDate}" pattern="dd" /></span>
                                            </div>
                                            <div style="font-size: 0.8rem;">
                                                <span style="display: block; font-weight: 600;"><fmt:formatDate value="${item.requestDate}" pattern="MMM dd, yyyy" /></span>
                                                <span style="color: var(--text-muted);"><fmt:formatDate value="${item.requestDate}" pattern="hh:mm a" /></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600;">${item.hospitalName}</span><br>
                                        <span style="font-size: 0.75rem; color: var(--text-muted);"><i class="fas fa-map-marker-alt"></i> ${item.location}</span>
                                    </td>
                                    <td><span style="font-weight: 700; color: var(--active-red);">${item.bloodGroup}</span></td>
                                    <td><div style="display: flex; align-items: center; gap: 0.5rem;"><i class="fas fa-flask" style="color: #3B82F6;"></i> 1 Unit</div></td>
                                    <td><span class="status-pill status-active"><i class="fas fa-check"></i> Completed</span></td>
                                    <td><button class="btn-premium btn-secondary" style="font-size: 0.75rem; color: var(--active-red); border-color: var(--active-red);"><i class="fas fa-download"></i> Download</button></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty history}">
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 2rem;">No donation records found.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const toggleFilterBtn = document.getElementById("toggleFilterBtn");
            const filterPanel = document.getElementById("filterPanel");
            const fromDateInput = document.getElementById("filterFromDate");
            const toDateInput = document.getElementById("filterToDate");
            const applyFilterBtn = document.getElementById("applyFilterBtn");
            const resetFilterBtn = document.getElementById("resetFilterBtn");
            const tableRows = document.querySelectorAll(".table-premium tbody tr:not(.no-records-row)");
            
            // Ensure we have a placeholder row for when no records match the filter
            const tbody = document.querySelector(".table-premium tbody");
            const noMatchRow = document.createElement("tr");
            noMatchRow.className = "no-records-row";
            noMatchRow.style.display = "none";
            noMatchRow.innerHTML = `<td colspan="6" style="text-align: center; color: var(--text-muted); padding: 2rem;"><i class="fas fa-search" style="font-size: 1.5rem; display: block; margin-bottom: 0.5rem; color: #ccc;"></i>No records match the selected date range.</td>`;
            tbody.appendChild(noMatchRow);

            // Toggle filter panel visibility
            toggleFilterBtn.addEventListener("click", function() {
                if (filterPanel.style.display === "none") {
                    filterPanel.style.display = "block";
                    toggleFilterBtn.style.background = "var(--active-red)";
                    toggleFilterBtn.style.color = "#fff";
                    toggleFilterBtn.style.borderColor = "var(--active-red)";
                } else {
                    filterPanel.style.display = "none";
                    toggleFilterBtn.style.background = "";
                    toggleFilterBtn.style.color = "";
                    toggleFilterBtn.style.borderColor = "";
                }
            });

            // Apply filter logic
            function applyFilter() {
                const fromVal = fromDateInput.value;
                const toVal = toDateInput.value;
                
                let visibleCount = 0;
                
                tableRows.forEach(row => {
                    const rowDateStr = row.getAttribute("data-date");
                    if (!rowDateStr) return;
                    
                    let show = true;
                    if (fromVal && rowDateStr < fromVal) {
                        show = false;
                    }
                    if (toVal && rowDateStr > toVal) {
                        show = false;
                    }
                    
                    if (show) {
                        row.style.display = "";
                        visibleCount++;
                    } else {
                        row.style.display = "none";
                    }
                });

                if (visibleCount === 0 && tableRows.length > 0) {
                    noMatchRow.style.display = "";
                } else {
                    noMatchRow.style.display = "none";
                }
            }

            applyFilterBtn.addEventListener("click", applyFilter);

            // Reset filter logic
            resetFilterBtn.addEventListener("click", function() {
                fromDateInput.value = "";
                toDateInput.value = "";
                tableRows.forEach(row => {
                    row.style.display = "";
                });
                noMatchRow.style.display = "none";
            });
        });
    </script>
</body>
</html>
