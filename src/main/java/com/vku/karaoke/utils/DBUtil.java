package com.vku.karaoke.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * TRẢ LỜI VẤN ĐÁP: Lớp này chịu trách nhiệm nạp Driver và cấu hình chuỗi kết nối MySQL Database.
 * Sử dụng mô hình Single-Responsibility, tập trung một nơi kết nối để dễ bảo trì hệ thống database.
 */
public class DBUtil {
    // Cấu hình chuỗi kết nối (Thay đổi tên database, user, password tương ứng với máy của bạn)
    private static final String URL = "jdbc:mysql://localhost:3306/karaoke_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    // Sửa thành mật khẩu mới khớp với MySQL
    private static final String PASS = "Admin@123"; // Điền mật khẩu MySQL của bạn vào đây

    /**
     * Hàm lấy kết nối đến MySQL.
     * @return Connection đối tượng dùng để thực thi các câu lệnh SQL.
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Nạp driver MySQL vào bộ nhớ hệ thống trước khi mở kết nối
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("Chưa thêm thư viện MySQL Connector vào project!");
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}