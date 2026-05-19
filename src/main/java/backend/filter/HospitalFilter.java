package backend.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filter for /hospital/* URLs.
 * For now, allows all access (login will be added by Member 1).
 */
@WebFilter("/hospital/*")
public class HospitalFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpSession session = request.getSession();
        
        // Auto-populate session for modular hospital testing if empty
        if (session.getAttribute("role") == null) {
            session.setAttribute("role", "hospital");
            session.setAttribute("userId", 1);
            session.setAttribute("fullName", "City Hospital");
        }
        
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
    }
}
