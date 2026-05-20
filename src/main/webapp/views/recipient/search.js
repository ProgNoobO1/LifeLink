(function () {
    const compatibility = {
        'A+': 'Can receive from: A+, A-, O+, O-',
        'A-': 'Can receive from: A-, O-',
        'B+': 'Can receive from: B+, B-, O+, O-',
        'B-': 'Can receive from: B-, O-',
        'AB+': 'Can receive from: all blood groups',
        'AB-': 'Can receive from: A-, B-, AB-, O-',
        'O+': 'Can receive from: O+, O-',
        'O-': 'Can receive from: O- only'
    };

    const form = document.getElementById('searchForm');
    const bloodSelect = document.getElementById('bloodGroup');
    const locationInput = document.getElementById('locationInput');
    const hospitalGrid = document.getElementById('landingHospitalGrid');
    const donorRow = document.getElementById('landingDonorRow');

    document.querySelectorAll('.quick-pill').forEach(button => {
        button.addEventListener('click', () => {
            if (bloodSelect) {
                bloodSelect.value = button.dataset.bloodGroup;
            }
            if (form) {
                form.submit();
            }
        });
    });

    let debounceTimer;
    if (form && (locationInput || bloodSelect)) {
        const debouncedPreview = () => {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(fetchPreviewResults, 300);
        };
        if (locationInput) {
            locationInput.addEventListener('input', debouncedPreview);
        }
        if (bloodSelect) {
            bloodSelect.addEventListener('change', debouncedPreview);
        }
    }

    function fetchPreviewResults() {
        if (!hospitalGrid && !donorRow) {
            return;
        }
        const bloodGroup = bloodSelect ? bloodSelect.value : '';
        const location = locationInput ? locationInput.value : '';
        if (!bloodGroup && location.trim().length < 2) {
            return;
        }
        const url = form.action + '?ajax=1&bloodGroup=' + encodeURIComponent(bloodGroup)
            + '&location=' + encodeURIComponent(location);
        showLandingSkeletons();
        fetch(url, { headers: { 'Accept': 'application/json' } })
            .then(response => response.ok ? response.json() : Promise.reject())
            .then(renderLandingPreview)
            .catch(() => renderLandingError())
            .finally(() => document.body.classList.remove('skeleton'));
    }

    function showLandingSkeletons() {
        document.body.classList.add('skeleton');
        if (hospitalGrid) {
            hospitalGrid.innerHTML = '<div class="loading-card"></div><div class="loading-card"></div>';
        }
        if (donorRow) {
            donorRow.innerHTML = '<div class="loading-card" style="min-width:186px"></div><div class="loading-card" style="min-width:186px"></div><div class="loading-card" style="min-width:186px"></div>';
        }
    }

    function renderLandingPreview(payload) {
        const hospitals = Array.isArray(payload.hospitals) ? payload.hospitals.slice(0, 4) : [];
        const donors = Array.isArray(payload.donors) ? payload.donors.filter(donor => donor.available).slice(0, 5) : [];

        if (hospitalGrid) {
            hospitalGrid.innerHTML = hospitals.length
                ? hospitals.map(renderHospitalCard).join('')
                : emptyState('+', 'No hospitals with stock found.');
        }
        if (donorRow) {
            donorRow.innerHTML = donors.length
                ? donors.map(renderDonorCard).join('')
                : emptyState('0', 'No donors found for this blood group in your area.');
        }
    }

    function renderLandingError() {
        if (hospitalGrid) {
            hospitalGrid.innerHTML = emptyState('!', 'Unable to load hospitals right now.');
        }
        if (donorRow) {
            donorRow.innerHTML = emptyState('!', 'Unable to load donors right now.');
        }
    }

    function renderHospitalCard(hospital) {
        const stock = Array.isArray(hospital.stock) ? hospital.stock : [];
        const visibleStock = stock.slice(0, 3).map(item => {
            const low = Number(item.unitsAvailable) <= Number(item.lowStockThreshold);
            return '<span class="blood-pill ' + bgClass(item.bloodGroup) + '">' + esc(item.bloodGroup) + '</span>'
                + '<span class="stock-count ' + (low ? 'low' : 'ok') + '">' + Number(item.unitsAvailable || 0) + '</span>';
        }).join('');
        const more = stock.length > 3 ? '<span class="muted">+' + (stock.length - 3) + ' more</span>' : '';
        return '<article class="hospital-card">'
            + '<div class="hospital-top"><div class="hospital-main"><div class="hospital-icon"><svg viewBox="0 0 24 24"><path d="M19 3H5v18h14V3Zm-8 16H7v-4h4v4Zm6 0h-4v-4h4v4ZM9 5h6v2H9V5Z"/></svg></div>'
            + '<div><h3>' + esc(hospital.hospitalName) + '</h3><div class="muted">' + esc(hospital.district || 'Unknown') + '</div></div></div>'
            + '<span class="status ' + (hospital.open ? 'open' : 'busy') + '">' + (hospital.open ? 'Open' : 'Busy') + '</span></div>'
            + '<div class="stock">' + visibleStock + more + '</div>'
            + '<div class="card-foot"><span>' + distance(hospital.distanceKm) + ' km away</span>'
            + '<a class="contact" href="' + requestHref('', 'hospitalId', hospital.id) + '">Contact</a></div></article>';
    }

    function renderDonorCard(donor) {
        return '<article class="donor-card"><div class="donor-avatar">' + esc(initials(donor.fullName))
            + '<span class="blood-pill ' + bgClass(donor.bloodGroup) + '">' + esc(donor.bloodGroup) + '</span></div>'
            + '<h3>' + esc(donor.fullName) + '</h3><div class="muted">' + esc(donor.district || 'Unknown') + '</div>'
            + '<div class="muted" style="margin-top:.6rem;"><span class="dot ' + (donor.available ? '' : 'grey') + '"></span> '
            + (donor.available ? 'Available' : 'Busy') + ' &nbsp; ' + distance(donor.distanceKm) + ' km</div>'
            + '<a class="donor-action ' + (donor.available ? '' : 'disabled') + '" href="' + requestHref(donor.bloodGroup, 'donorId', donor.id) + '">'
            + (donor.available ? 'Request' : 'Unavailable') + '</a></article>';
    }

    const results = Array.from(document.querySelectorAll('[data-result-type]'));
    const empty = document.getElementById('emptyResults');
    let activeType = readActive('[data-side-type]', 'sideType') || readActive('.tab', 'type') || 'all';
    let activeAvailability = 'all';
    let activeDistance = readActive('[data-distance]', 'distance') || 'any';
    setMatchingActive('[data-availability]', 'availability', activeAvailability);

    document.querySelectorAll('.tab').forEach(tab => {
        tab.addEventListener('click', () => {
            activeType = tab.dataset.type || 'all';
            setActive('.tab', tab, 'type', activeType);
            setMatchingActive('[data-side-type]', 'sideType', activeType);
            filterResults();
        });
    });

    document.querySelectorAll('[data-side-type]').forEach(button => {
        button.addEventListener('click', () => {
            activeType = button.dataset.sideType || 'all';
            setActive('[data-side-type]', button, 'sideType', activeType);
            setMatchingActive('.tab', 'type', activeType);
            filterResults();
        });
    });

    document.querySelectorAll('[data-availability]').forEach(button => {
        button.addEventListener('click', () => {
            activeAvailability = button.dataset.availability || 'all';
            setActive('[data-availability]', button, 'availability', activeAvailability);
            filterResults();
        });
    });

    document.querySelectorAll('[data-distance]').forEach(button => {
        button.addEventListener('click', () => {
            activeDistance = button.dataset.distance || 'any';
            setActive('[data-distance]', button, 'distance', activeDistance);
            filterResults();
        });
    });

    const apply = document.getElementById('applyFilters');
    if (apply) {
        apply.addEventListener('click', event => {
            event.preventDefault();
            filterResults();
        });
    }

    function filterResults() {
        let visible = 0;
        results.forEach(row => {
            const typeOk = activeType === 'all' || row.dataset.resultType === activeType;
            const availabilityOk = activeAvailability === 'all' || row.dataset.available === 'true';
            const rowDistance = Number(row.dataset.distance || '0');
            const distanceOk = activeDistance === 'any' || rowDistance <= Number(activeDistance);
            const show = typeOk && availabilityOk && distanceOk;
            row.hidden = !show;
            if (show) {
                visible++;
            }
        });
        if (empty) {
            empty.hidden = visible !== 0;
        }
    }

    document.querySelectorAll('.request-btn:not(.disabled), .donor-action:not(.disabled), .contact').forEach(button => {
        button.addEventListener('click', () => {
            const row = button.closest('[data-result-type]');
            if (!row) {
                return;
            }
            const param = row.dataset.resultType === 'hospital' ? 'hospitalId' : 'donorId';
            button.setAttribute('href', requestHref(row.dataset.bloodGroup || '', param, row.dataset.id || ''));
        });
    });

    document.querySelectorAll('[data-relative-date]').forEach(item => {
        const value = item.dataset.relativeDate;
        if (!value) {
            item.textContent = 'Last donated N/A';
            return;
        }
        const date = new Date(value + 'T00:00:00');
        if (Number.isNaN(date.getTime())) {
            return;
        }
        const days = Math.max(0, Math.floor((Date.now() - date.getTime()) / 86400000));
        item.textContent = 'Last donated ' + days + ' days ago';
        item.title = date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
    });

    const compatibilityInfo = document.getElementById('compatibilityInfo');
    if (compatibilityInfo) {
        const aboutBlood = window.selectedBloodGroup || '';
        compatibilityInfo.textContent = compatibility[aboutBlood] || 'Select a blood group to see compatibility details.';
    }

    function requestHref(bloodGroup, idParam, idValue) {
        const base = (window.LifeLinkSearch && window.LifeLinkSearch.requestPath) || 'create_request.jsp';
        const params = new URLSearchParams();
        if (bloodGroup) {
            params.set('bloodGroup', bloodGroup);
        }
        if (idParam && idValue) {
            params.set(idParam, idValue);
        }
        return base + (params.toString() ? '?' + params.toString() : '');
    }

    function readActive(selector, key) {
        const node = document.querySelector(selector + '.active');
        return node ? node.dataset[key] : null;
    }

    function setActive(selector, activeNode, key, value) {
        document.querySelectorAll(selector).forEach(node => {
            node.classList.toggle('active', node === activeNode || node.dataset[key] === value);
        });
    }

    function setMatchingActive(selector, key, value) {
        document.querySelectorAll(selector).forEach(node => {
            node.classList.toggle('active', node.dataset[key] === value);
        });
    }

    function bgClass(bg) {
        if (bg === 'AB+') return 'bg-ab-pos';
        if (bg === 'AB-') return 'bg-ab-neg';
        if (bg === 'O+') return 'bg-o-pos';
        if (bg === 'O-') return 'bg-o-neg';
        if (bg === 'B+') return 'bg-b-pos';
        if (bg === 'B-') return 'bg-b-neg';
        if (bg === 'A-') return 'bg-a-neg';
        return 'bg-a-pos';
    }

    function initials(name) {
        const parts = String(name || 'U').trim().split(/\s+/).filter(Boolean);
        if (parts.length > 1) {
            return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
        }
        return parts[0].slice(0, 2).toUpperCase();
    }

    function distance(value) {
        return Number(value || 0).toFixed(1);
    }

    function emptyState(mark, message) {
        return '<div class="empty"><div class="empty-illustration">' + esc(mark) + '</div>' + esc(message) + '</div>';
    }

    function esc(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }
})();
