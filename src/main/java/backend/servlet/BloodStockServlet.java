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

public class BloodStockServlet extends HttpServlet {

    private BloodStockDAO stockDAO = new BloodStockDAO();
    private HospitalDAO hospitalDAO = new HospitalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int hospitalId = getHospitalId(request);
        List<BloodStock> stockList = stockDAO.getAllStock(hospitalId);
        List<BloodStock> lowStock = stockDAO.getLowStock(hospitalId);
        int totalUnits = stockDAO.getTotalUnits(hospitalId);
        int lowStockCount = stockDAO.getLowStockCount(hospitalId);

        // Count normal groups
        int normalGroups = 0;
        for (BloodStock s : stockList) {
            if ("normal".equals(s.getStockLevel())) normalGroups++;
        }

        request.setAttribute("stockList", stockList);
        request.setAttribute("lowStockAlerts", lowStock);
        request.setAttribute("totalUnits", totalUnits);
        request.setAttribute("lowStockCount", lowStockCount);
        request.setAttribute("normalGroups", normalGroups);
        request.setAttribute("hospital", hospitalDAO.getHospitalByUserId(
                1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */));

        request.getRequestDispatcher("/views/Hospital/manage_stock.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            int stockId = Integer.parseInt(request.getParameter("stockId"));
            stockDAO.deleteStock(stockId);
            response.sendRedirect(request.getContextPath() + "/hospital/stock?msg=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/hospital/stock");
        }
    }

    private int getHospitalId(HttpServletRequest request) {
        int userId = 1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */;
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        return hospital != null ? hospital.getId() : -1;
    }
}
