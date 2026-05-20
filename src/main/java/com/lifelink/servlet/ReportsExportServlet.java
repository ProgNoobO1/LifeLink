package com.lifelink.servlet;

import com.lifelink.dao.ReportDAO;
import com.lifelink.model.User;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.awt.Color;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

public class ReportsExportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        User admin = (User) session.getAttribute("currentUser");
        if (admin == null || admin.getRole() == null || admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String type = req.getParameter("type");
        String fromDateStr = req.getParameter("fromDate");
        String toDateStr = req.getParameter("toDate");

        LocalDate toDate = LocalDate.now();
        LocalDate fromDate = toDate.withDayOfMonth(1);
        try {
            if (fromDateStr != null && !fromDateStr.isEmpty()) fromDate = LocalDate.parse(fromDateStr, DATE_FMT);
            if (toDateStr != null && !toDateStr.isEmpty()) toDate = LocalDate.parse(toDateStr, DATE_FMT);
        } catch (java.time.format.DateTimeParseException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format. Please use yyyy-MM-dd.");
            return;
        }

        List<Map<String, Object>> data = reportDAO.getDonationsForExport(fromDate, toDate);

        if ("pdf".equalsIgnoreCase(type)) {
            exportPDF(resp, data, fromDate, toDate);
        } else {
            exportCSV(resp, data, fromDate, toDate);
        }
    }

    private void exportCSV(HttpServletResponse resp, List<Map<String, Object>> data, LocalDate from, LocalDate to) throws IOException {
        resp.setContentType("text/csv");
        resp.setHeader("Content-Disposition", "attachment; filename=donations_" + from + "_to_" + to + ".csv");

        PrintWriter out = resp.getWriter();
        out.println("Name,Email,Blood Group,Units,Date");
        for (Map<String, Object> row : data) {
            out.printf("\"%s\",\"%s\",%s,%s,%s%n",
                row.get("name"), row.get("email"), row.get("bloodGroup"),
                row.get("units"), row.get("date"));
        }
        out.flush();
    }

    private void exportPDF(HttpServletResponse resp, List<Map<String, Object>> data, LocalDate from, LocalDate to) throws IOException {
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "attachment; filename=donations_" + from + "_to_" + to + ".pdf");

        Document doc = new Document(PageSize.A4.rotate());
        try {
            PdfWriter.getInstance(doc, resp.getOutputStream());
            doc.open();

            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD, new Color(185, 28, 28));
            Font headerFont = new Font(Font.HELVETICA, 10, Font.BOLD, Color.WHITE);
            Font cellFont = new Font(Font.HELVETICA, 9, Font.NORMAL, new Color(17, 24, 39));

            doc.add(new Paragraph("LifeLink Donation Report", titleFont));
            doc.add(new Paragraph("Period: " + from + " to " + to, new Font(Font.HELVETICA, 10, Font.NORMAL, new Color(75, 85, 99))));
            doc.add(Chunk.NEWLINE);

            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            float[] cols = {3f, 4f, 2f, 1.5f, 2f};
            table.setWidths(cols);

            String[] headers = {"Name", "Email", "Blood Group", "Units", "Date"};
            Color headerBg = new Color(185, 28, 28);
            for (String h : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
                cell.setBackgroundColor(headerBg);
                cell.setPadding(8);
                table.addCell(cell);
            }

            for (Map<String, Object> row : data) {
                table.addCell(new PdfPCell(new Phrase(String.valueOf(row.get("name")), cellFont)));
                table.addCell(new PdfPCell(new Phrase(String.valueOf(row.get("email")), cellFont)));
                table.addCell(new PdfPCell(new Phrase(String.valueOf(row.get("bloodGroup")), cellFont)));
                table.addCell(new PdfPCell(new Phrase(String.valueOf(row.get("units")), cellFont)));
                table.addCell(new PdfPCell(new Phrase(String.valueOf(row.get("date")), cellFont)));
            }

            doc.add(table);
            doc.close();
        } catch (DocumentException e) {
            throw new IOException(e);
        }
    }
}
