package com.vku.sales.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    // Đã thêm serverTimezone=Asia/Ho_Chi_Minh chống lỗi giờ hệ thống trên Ubuntu
    private static final String URL = "jdbc:mysql://localhost:3306/karaoke_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh";
    private static final String USER = "root";
    private static final String PASS = "Admin@123"; // ĐẢM BẢO ĐIỀN ĐÚNG PASS CỦA BẠN VÀO ĐÂY

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("Lỗi: Chưa tìm thấy Thư viện Driver MySQL!");
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}