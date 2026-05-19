package backend.service;

import backend.dao.BloodRequestDAO;
import backend.dao.BloodStockDAO;
import backend.dao.HospitalDAO;
import backend.model.BloodRequest;
import backend.model.BloodStock;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class HospitalService {

    private HospitalDAO hospitalDAO = new HospitalDAO();
    private BloodStockDAO stockDAO = new BloodStockDAO();
    private BloodRequestDAO requestDAO = new BloodRequestDAO();

    /**
     * Accept a blood request:
     * 1. Check stock availability
     * 2. Deduct stock atomically
     * 3. Update request status to 'accepted'
     * 4. Insert usage_history record
     *
     * @return "success" | "insufficient_stock" | "error"
     */
    public String acceptRequest(int requestId, int hospitalId) {
        try {
            BloodRequest req = requestDAO.getRequestById(requestId);
            if (req == null) return "error";

            // Atomic deduction — returns false if not enough units
            boolean hasStock = stockDAO.deductStock(hospitalId, req.getBloodGroup(), req.getUnitsNeeded());
            if (!hasStock) return "insufficient_stock";

            // Update request status
            boolean updated = requestDAO.updateStatus(requestId, "accepted");
            if (!updated) return "error";

            // Record usage history
            requestDAO.addUsageHistory(hospitalId, req.getBloodGroup(),
                    req.getUnitsNeeded(), requestId, "Request fulfilled");

            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }

    /**
     * Reject a request — just update status.
     */
    public boolean rejectRequest(int requestId) {
        return requestDAO.updateStatus(requestId, "rejected");
    }

    /**
     * Mark a request as completed.
     */
    public boolean completeRequest(int requestId) {
        return requestDAO.updateStatus(requestId, "completed");
    }

    /**
     * Get all dashboard summary data in one call.
     */
    public Map<String, Object> getDashboardData(int hospitalId) {
        Map<String, Object> data = new HashMap<>();
        data.put("totalUnits", stockDAO.getTotalUnits(hospitalId));
        data.put("lowStockCount", stockDAO.getLowStockCount(hospitalId));
        data.put("pendingRequests", requestDAO.getPendingCount(hospitalId));
        data.put("stockList", stockDAO.getAllStock(hospitalId));

        // Recent requests — limit to 5
        List<BloodRequest> allRequests = requestDAO.getRequestsByHospital(hospitalId);
        List<BloodRequest> recentRequests = allRequests.stream()
                .limit(5)
                .collect(Collectors.toList());
        data.put("recentRequests", recentRequests);

        data.put("lowStockAlerts", stockDAO.getLowStock(hospitalId));
        return data;
    }
}
