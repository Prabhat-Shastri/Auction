package auction.dao;

import auction.dbo.DBConnection;
import auction.models.Person;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PersonDAO{

    private static final String INSERT_SQL =
            "insert into person(person_id, full_name, username, email, phone_number, password, birthday) " +
            "values(?, ?, ?, ?, ?, ?, ?)";
    private static final String SELECT_BY_USERNAME =
            "select * from person where username = ?";
    private static final String SELECT_ALL =
            "select * from person";
    private static final String UPDATE_SQL =
            "update person set full_name=?, username=?, email=?, phone_number=?, password=?, birthday=? " +
            "where person_id=?";
    private static final String DELETE_SQL =
            "delete from person where person_id=?";
    private static final String VALIDATE_SQL =
            "select 1 from person where username=? and password=?";

    public boolean createPerson(Person person) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(INSERT_SQL)) {

            ps.setString(1, person.getPersonId());
            ps.setString(2, person.getFullName());
            ps.setString(3, person.getUsername());
            ps.setString(4, person.getEmail());
            ps.setString(5, person.getPhoneNumber());
            ps.setString(6, person.getPassword());
            ps.setDate(7, person.getBirthday()); // java.sql.Date

            return ps.executeUpdate() == 1;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean validateLogin(String username, String password) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(VALIDATE_SQL)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Person findByUsername(String username) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_BY_USERNAME)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
            return null;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    public List<Person> findAll() {
        List<Person> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return list;
        }
    }

    public boolean updatePerson(Person p) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE_SQL)) {

            ps.setString(1, p.getFullName());
            ps.setString(2, p.getUsername());
            ps.setString(3, p.getEmail());
            ps.setString(4, p.getPhoneNumber());
            ps.setString(5, p.getPassword());
            ps.setDate(6, p.getBirthday());
            ps.setString(7, p.getPersonId());

            return ps.executeUpdate() == 1;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteById(String personId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(DELETE_SQL)) {

            ps.setString(1, personId);
            return ps.executeUpdate() == 1;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Person mapRow(ResultSet rs) throws SQLException {
        Person p = new Person();
        p.setPersonId(rs.getString("person_id"));
        p.setFullName(rs.getString("full_name"));
        p.setUsername(rs.getString("username"));
        p.setEmail(rs.getString("email"));
        p.setPhoneNumber(rs.getString("phone_number"));
        p.setPassword(rs.getString("password"));
        p.setBirthday(rs.getDate("birthday"));
        return p;
    }
}
