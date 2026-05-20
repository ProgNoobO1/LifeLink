package com.lifelink.servlet;

import com.lifelink.dao.BloodStockDAO;
import com.lifelink.dao.HospitalDashboardDAO;
import com.lifelink.dao.NotificationDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/hospital/stock")
public class BloodStockServlet extends HttpServlet {

    private final BloodStockDAO dao = new BloodStockDAO();
    private final HospitalDashboardDAO dashboardDAO = new HospitalDashboardDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        String action = valueOrDefault(request.getParameter("action"), "list");

        if ("add".equalsIgnoreCase(action)) {
            prepareFormPage(request, hospitalId, false, null);
            request.getRequestDispatcher("/hospital/add_stock.jsp").forward(request, response);
            return;
        }

        if ("edit".equalsIgnoreCase(action)) {
            Integer stockId = parseInteger(request.getParameter("id"));
            if (stockId == null) {
                response.sendRedirect(request.getContextPath() + "/hospital/stock");
                return;
            }

            Map<String, Object> existingStock = dao.getStockById(stockId, hospitalId);
            if (existingStock == null) {
                response.sendRedirect(request.getContextPath() + "/hospital/stock");
                return;
            }

            prepareFormPage(request, hospitalId, true, existingStock);
            request.getRequestDispatcher("/hospital/add_stock.jsp").forward(request, response);
            return;
        }

        prepareListPage(request, hospitalId);
        request.getRequestDispatcher("/hospital/blood_stock.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        String action = request.getParameter("action");

        if ("delete".equalsIgnoreCase(action)) {
            Integer stockId = parseInteger(request.getParameter("id"));
            Map<String, Object> existingStock = stockId != null ? dao.getStockById(stockId, hospitalId) : null;
            if (stockId != null && dao.deleteStock(stockId, hospitalId)) {
                queueStockNotifications(hospitalId, existingStock, 0);
                response.sendRedirect(request.getContextPath() + "/hospital/stock?success=deleted");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/hospital/stock?error=delete");
            return;
        }

        if ("save".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            handleSaveOrUpdate(request, response, hospitalId, "update".equalsIgnoreCase(action));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/hospital/stock");
    }

    private void handleSaveOrUpdate(HttpServletRequest request, HttpServletResponse response, int hospitalId, boolean editMode)
            throws ServletException, IOException {
        Integer stockId = editMode ? parseInteger(request.getParameter("id")) : null;
        if (editMode && stockId == null) {
            response.sendRedirect(request.getContextPath() + "/hospital/stock");
            return;
        }

        Map<String, String> formData = new LinkedHashMap<>();
        formData.put("bloodGroupId", trimToEmpty(request.getParameter("bloodGroupId")));
        formData.put("units", trimToEmpty(request.getParameter("units")));
        formData.put("collectionDate", trimToEmpty(request.getParameter("collectionDate")));
        formData.put("expiryDate", trimToEmpty(request.getParameter("expiryDate")));
        if (stockId != null) {
            formData.put("id", String.valueOf(stockId));
        }

        Map<String, String> errors = validateForm(formData);
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("formData", formData);
            if (editMode) {
                Map<String, Object> existingStock = dao.getStockById(stockId, hospitalId);
                if (existingStock == null) {
                    response.sendRedirect(request.getContextPath() + "/hospital/stock");
                    return;
                }
                prepareFormPage(request, hospitalId, true, existingStock);
            } else {
                prepareFormPage(request, hospitalId, false, null);
            }
            request.getRequestDispatcher("/hospital/add_stock.jsp").forward(request, response);
            return;
        }

        int bloodGroupId = Integer.parseInt(formData.get("bloodGroupId"));
        int units = Integer.parseInt(formData.get("units"));
        LocalDate collectionDate = LocalDate.parse(formData.get("collectionDate"));
        LocalDate expiryDate = LocalDate.parse(formData.get("expiryDate"));

        if (editMode) {
            Map<String, Object> existingStock = dao.getStockById(stockId, hospitalId);
            if (dao.updateStock(stockId, hospitalId, bloodGroupId, units, collectionDate, expiryDate)) {
                Map<String, Object> updatedStock = dao.getStockById(stockId, hospitalId);
                queueStockNotifications(hospitalId, updatedStock != null ? updatedStock : existingStock, units);
                response.sendRedirect(request.getContextPath() + "/hospital/stock?success=updated");
            } else {
                request.setAttribute("formError", "Unable to update this stock entry right now. Please try again.");
                prepareFormPage(request, hospitalId, true, existingStock);
                request.setAttribute("formData", formData);
                request.getRequestDispatcher("/hospital/add_stock.jsp").forward(request, response);
            }
        } else {
            if (dao.upsertStock(hospitalId, bloodGroupId, units, collectionDate, expiryDate)) {
                queueStockNotifications(hospitalId, bloodGroupId);
                response.sendRedirect(request.getContextPath() + "/hospital/stock?success=added");
            } else {
                request.setAttribute("formError", "Unable to save stock to the database right now. Please try again.");
                prepareFormPage(request, hospitalId, false, null);
                request.setAttribute("formData", formData);
                request.getRequestDispatcher("/hospital/add_stock.jsp").forward(request, response);
            }
        }
    }

    private Map<String, String> validateForm(Map<String, String> formData) {
        Map<String, String> errors = new LinkedHashMap<>();

        Integer bloodGroupId = parseInteger(formData.get("bloodGroupId"));
        if (bloodGroupId == null || bloodGroupId < 1 || bloodGroupId > 8) {
            errors.put("bloodGroupId", "Please select a valid blood group.");
        }

        Integer units = parseInteger(formData.get("units"));
        if (units == null || units <= 0 || units > 9999) {
            errors.put("units", "Units must be between 1 and 9999.");
        }

        LocalDate collectionDate = null;
        if (formData.get("collectionDate").isEmpty()) {
            errors.put("collectionDate", "Collection date is required.");
        } else {
            try {
                collectionDate = LocalDate.parse(formData.get("collectionDate"));
                if (collectionDate.isAfter(LocalDate.now())) {
                    errors.put("collectionDate", "Collection date cannot be in the future.");
                }
            } catch (DateTimeParseException e) {
                errors.put("collectionDate", "Please enter a valid collection date.");
            }
        }

        LocalDate expiryDate = null;
        if (formData.get("expiryDate").isEmpty()) {
            errors.put("expiryDate", "Expiry date is required.");
        } else {
            try {
                expiryDate = LocalDate.parse(formData.get("expiryDate"));
            } catch (DateTimeParseException e) {
                errors.put("expiryDate", "Please enter a valid expiry date.");
            }
        }

        if (collectionDate != null && expiryDate != null && !expiryDate.isAfter(collectionDate)) {
            errors.put("expiryDate", "Expiry date must be after collection date.");
        }

        return errors;
    }

    private void prepareListPage(HttpServletRequest request, int hospitalId) {
        List<Map<String, Object>> stockList = dao.getAllStock(hospitalId);
        Map<String, Object> stats = dao.getSummaryStats(hospitalId);

        request.setAttribute("stockList", stockList);
        request.setAttribute("stats", stats);
        request.setAttribute("hospitalName", dao.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(request.getSession(false)));
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("notificationCount", getNotificationCount(hospitalId));
        request.setAttribute("stockCount", stockList.size());
    }

    private void prepareFormPage(HttpServletRequest request, int hospitalId, boolean editMode, Map<String, Object> existingStock) {
        List<Map<String, Object>> sidebarStock = dao.getCurrentStockSidebar(hospitalId);
        List<String> lowStockNames = dao.getLowStockGroupNames(hospitalId);

        request.setAttribute("editMode", editMode);
        request.setAttribute("existingStock", existingStock);
        request.setAttribute("bloodGroups", dao.getAllBloodGroups());
        request.setAttribute("sidebarStock", sidebarStock);
        request.setAttribute("sidebarTotalUnits", sumUnits(sidebarStock));
        request.setAttribute("lowStockNames", lowStockNames);
        request.setAttribute("lowStockText", joinLowStockNames(lowStockNames));
        request.setAttribute("hospitalName", dao.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(request.getSession(false)));
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("notificationCount", getNotificationCount(hospitalId));
        request.setAttribute("stats", dao.getSummaryStats(hospitalId));
    }

    private int getNotificationCount(int hospitalId) {
        try {
            return notificationDAO.getUnreadCount(hospitalId);
        } catch (Exception e) {
            System.err.println("[BloodStockServlet] getNotificationCount: " + e.getMessage());
            return 0;
        }
    }

    private int sumUnits(List<Map<String, Object>> sidebarStock) {
        int total = 0;
        for (Map<String, Object> item : sidebarStock) {
            Object units = item.get("units");
            if (units instanceof Number) {
                total += ((Number) units).intValue();
            }
        }
        return total;
    }

    private String joinLowStockNames(List<String> lowStockNames) {
        if (lowStockNames == null || lowStockNames.isEmpty()) {
            return "";
        }
        if (lowStockNames.size() == 1) {
            return lowStockNames.get(0);
        }

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < lowStockNames.size(); i++) {
            if (i > 0) {
                builder.append(i == lowStockNames.size() - 1 ? " and " : ", ");
            }
            builder.append(lowStockNames.get(i));
        }
        return builder.toString();
    }

    private void queueStockNotifications(int hospitalId, int bloodGroupId) {
        List<Map<String, Object>> currentStock = dao.getAllStock(hospitalId);
        for (Map<String, Object> stockItem : currentStock) {
            if (((Number) stockItem.get("bloodGroupId")).intValue() == bloodGroupId) {
                queueStockNotifications(hospitalId, stockItem, ((Number) stockItem.get("units")).intValue());
                break;
            }
        }
    }

    private void queueStockNotifications(int hospitalId, Map<String, Object> stockItem, int latestUnits) {
        if (stockItem == null) {
            return;
        }

        try {
            int bloodGroupId = ((Number) stockItem.get("bloodGroupId")).intValue();
            String bloodGroup = String.valueOf(stockItem.get("bloodGroupName"));
            int threshold = ((Number) stockItem.get("threshold")).intValue();
            int units = latestUnits >= 0 ? latestUnits : ((Number) stockItem.get("units")).intValue();

            if (units <= threshold) {
                dashboardDAO.createOrUpdateLowStockAlert(hospitalId, bloodGroupId, units);
                String subject = "Low stock alert: " + bloodGroup;
                String body = "Your " + bloodGroup + " stock is at " + units +
                        " units, which is at or below the low-stock threshold. Please restock soon.";
                if (!notificationDAO.hasQueuedNotification(hospitalId, subject)) {
                    notificationDAO.insertNotification(hospitalId, subject, body);
                }
            } else {
                dashboardDAO.resolveLowStockAlert(hospitalId, bloodGroupId);
                String subject = "Stock restored: " + bloodGroup;
                String body = "Your " + bloodGroup + " stock has been restored to " + units +
                        " units and is now above the low-stock threshold.";
                if (!notificationDAO.hasQueuedNotification(hospitalId, subject)) {
                    notificationDAO.insertNotification(hospitalId, subject, body);
                }
            }
        } catch (Exception e) {
            System.err.println("[BloodStockServlet] queueStockNotifications: " + e.getMessage());
        }
    }

    private Integer requireHospital(HttpSession session, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        Object roleValue = session.getAttribute("role");
        if (roleValue == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"hospital".equalsIgnoreCase(String.valueOf(roleValue))) {
            response.sendRedirect(request.getContextPath() + "/403");
            return null;
        }

        Object userIdValue = session.getAttribute("userId");
        if (userIdValue != null) {
            try {
                return Integer.valueOf(String.valueOf(userIdValue));
            } catch (NumberFormatException e) {
                System.err.println("[BloodStockServlet] Invalid session userId: " + e.getMessage());
            }
        }

        Object currentUser = session.getAttribute("currentUser");
        if (currentUser instanceof User) {
            User user = (User) currentUser;
            if (user.getId() != null) {
                return user.getId().intValue();
            }
        }

        response.sendRedirect(request.getContextPath() + "/login");
        return null;
    }

    private String resolveHospitalEmail(HttpSession session) {
        if (session == null) {
            return "";
        }

        Object email = session.getAttribute("email");
        if (email != null) {
            return String.valueOf(email);
        }

        Object currentUser = session.getAttribute("currentUser");
        if (currentUser instanceof User) {
            return ((User) currentUser).getEmail();
        }

        return "";
    }

    private Integer parseInteger(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String valueOrDefault(String value, String defaultValue) {
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }
}
