package lifelink.servlet;

import lifelink.dao.BloodStockDAO;
import lifelink.dao.HospitalDAO;
import lifelink.model.BloodStock;
import lifelink.model.Hospital;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class AddEditStockServlet extends HttpServlet {

    private BloodStockDAO stockDAO = new BloodStockDAO();
    private HospitalDAO hospitalDAO = new HospitalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String stockIdParam = request.getParameter("id");

        if (stockIdParam != null && !stockIdParam.isEmpty()) {
            // EDIT MODE: load existing stock
            BloodStock stock = stockDAO.getStockById(Integer.parseInt(stockIdParam));
            request.setAttribute("stock", stock);
            request.setAttribute("mode", "edit");
        } else {
            // ADD MODE: empty form
            request.setAttribute("mode", "add");
        }

        // Pass list of already-added blood groups to prevent duplicates in add mode
        int hospitalId = getHospitalId(request);
        List<BloodStock> existing = stockDAO.getAllStock(hospitalId);
        request.setAttribute("existingGroups", existing);
        request.setAttribute("hospital", hospitalDAO.getHospitalByUserId(lifelink.utils.SessionUtil.getUserId(request)));

        request.getRequestDispatcher("/views/Hospital/add_edit_stock.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String mode = request.getParameter("mode");
        String bloodGroup = request.getParameter("bloodGroup");
        String unitsStr = request.getParameter("units");
        int hospitalId = getHospitalId(request);

        // Server-side validation
        if (bloodGroup == null || bloodGroup.isEmpty() || unitsStr == null || unitsStr.isEmpty()) {
            request.setAttribute("error", "Invalid input. Please check your values.");
            doGet(request, response);
            return;
        }

        int units;
        try {
            units = Integer.parseInt(unitsStr);
            if (units < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Units must be a non-negative number.");
            doGet(request, response);
            return;
        }

        if ("add".equals(mode)) {
            boolean added = stockDAO.addStock(hospitalId, bloodGroup, units);
            if (added) {
                response.sendRedirect(request.getContextPath() + "/hospital/stock?msg=added");
            } else {
                request.setAttribute("error", "Failed to add stock. Please check your hospital profile is set up.");
                doGet(request, response);
                return;
            }
        } else {
            // EDIT mode
            int stockId = Integer.parseInt(request.getParameter("stockId"));
            stockDAO.updateStock(stockId, bloodGroup, units);
            response.sendRedirect(request.getContextPath() + "/hospital/stock?msg=updated");
        }
    }

    private int getHospitalId(HttpServletRequest request) {
        int userId = lifelink.utils.SessionUtil.getUserId(request);
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        return hospital != null ? hospital.getId() : -1;
    }
}
