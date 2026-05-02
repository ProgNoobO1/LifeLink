package com.lifelink.dao;

import com.lifelink.models.Donor;
import com.lifelink.models.BloodRequest;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * MOCK DAO for Frontend Development
 * This version does not require a database connection.
 */
public class DonorDAO {

    private static Donor mockDonor;
    private static List<BloodRequest> mockRequests;

    static {
        // Initialize sample data
        mockDonor = new Donor();
        mockDonor.setId(1);
        mockDonor.setName("Alex Morgan");
        mockDonor.setEmail("alex.morgan@example.com");
        mockDonor.setPhone("+1 (555) 234-7890");
        mockDonor.setBloodGroup("O+");
        mockDonor.setLocation("Downtown, New York");
        mockDonor.setAvailable(true);

        mockRequests = new ArrayList<>();
        
        BloodRequest r1 = new BloodRequest();
        r1.setId(101);
        r1.setHospitalName("City General Hospital");
        r1.setBloodGroup("O+");
        r1.setLocation("Central District");
        r1.setStatus("Pending");
        r1.setRequestDate(new Timestamp(System.currentTimeMillis() - 3600000));
        mockRequests.add(r1);

        BloodRequest r2 = new BloodRequest();
        r2.setId(102);
        r2.setHospitalName("Saint Mary's Medical Center");
        r2.setBloodGroup("O+");
        r2.setLocation("North Side");
        r2.setStatus("Accepted");
        r2.setRequestDate(new Timestamp(System.currentTimeMillis() - 86400000));
        mockRequests.add(r2);

        BloodRequest r3 = new BloodRequest();
        r3.setId(103);
        r3.setHospitalName("Children's Health Clinic");
        r3.setBloodGroup("O+");
        r3.setLocation("East Wing");
        r3.setStatus("Completed");
        r3.setRequestDate(new Timestamp(System.currentTimeMillis() - 172800000));
        mockRequests.add(r3);
    }

    public Donor getDonorById(int id) {
        return mockDonor;
    }

    public boolean updateProfile(Donor donor) {
        mockDonor.setName(donor.getName());
        mockDonor.setPhone(donor.getPhone());
        mockDonor.setBloodGroup(donor.getBloodGroup());
        mockDonor.setLocation(donor.getLocation());
        return true;
    }

    public boolean updateAvailability(int donorId, boolean isAvailable) {
        mockDonor.setAvailable(isAvailable);
        return true;
    }

    public List<BloodRequest> getRequestsForDonor(int donorId) {
        List<BloodRequest> active = new ArrayList<>();
        for (BloodRequest r : mockRequests) {
            if (!"Completed".equals(r.getStatus())) {
                active.add(r);
            }
        }
        return active;
    }

    public boolean updateRequestStatus(int requestId, String status) {
        for (BloodRequest r : mockRequests) {
            if (r.getId() == requestId) {
                r.setStatus(status);
                return true;
            }
        }
        return false;
    }

    public List<BloodRequest> getDonationHistory(int donorId) {
        List<BloodRequest> history = new ArrayList<>();
        for (BloodRequest r : mockRequests) {
            if ("Completed".equals(r.getStatus())) {
                history.add(r);
            }
        }
        return history;
    }
}
