<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<script>
  // Mobile sidebar toggle
  document.addEventListener('DOMContentLoaded', function() {
    const toggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('sidebar');
    if (toggle && sidebar) {
      toggle.addEventListener('click', () => sidebar.classList.toggle('open'));
    }
    // Auto-dismiss alerts
    document.querySelectorAll('.alert').forEach(function(el) {
      setTimeout(() => { el.style.opacity='0'; el.style.transition='opacity 0.5s'; }, 4000);
    });

    // Automatic high-fidelity styling for blood badges and progress bars
    document.querySelectorAll('.blood-badge').forEach(function(badge) {
      const text = badge.textContent.trim().toUpperCase();
      let colorClass = '';
      if (text.includes('AB')) {
        colorClass = 'badge-ab';
      } else if (text.includes('A')) {
        colorClass = 'badge-a';
      } else if (text.includes('B')) {
        colorClass = 'badge-b';
      } else if (text.includes('O')) {
        colorClass = 'badge-o';
      }
      if (colorClass) {
        badge.classList.add(colorClass);
      }
      
      // Find associated progress bar in the same row or container
      const row = badge.closest('tr') || badge.closest('.d-flex') || badge.parentElement;
      if (row) {
        const progressBar = row.querySelector('.progress-bar');
        if (progressBar) {
          // Check if status is Low (warning or danger badge)
          const isLow = row.querySelector('.badge-danger, .badge-warning') || 
                        progressBar.classList.contains('red') || 
                        progressBar.classList.contains('yellow');
          if (isLow) {
            progressBar.classList.add('bg-low');
          } else {
            let bgClass = '';
            if (text.includes('AB')) bgClass = 'bg-ab';
            else if (text.includes('A')) bgClass = 'bg-a';
            else if (text.includes('B')) bgClass = 'bg-b';
            else if (text.includes('O')) bgClass = 'bg-o';
            if (bgClass) progressBar.classList.add(bgClass);
          }
        }
      }
    });
  });
</script>
</body>
</html>
