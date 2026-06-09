package com.vku.karaoke.client.controller;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

/**
 * TRẢ LỜI VẤN ĐÁP: Điều khiển màn hình đăng nhập Đảm bảo tính bảo mật của hệ thống.
 * Kết nối tạm thời thời đến cổng máy chủ gửi yêu cầu xác thực tài khoản.
 */
public class LoginController {

    @FXML private TextField txtUsername;
    @FXML private PasswordField txtPassword;
    @FXML private Label lblError;

    @FXML
    void handleLogin(ActionEvent event) {
        String username = txtUsername.getText().trim();
        String password = txtPassword.getText().trim();

        if (username.isEmpty() || password.isEmpty()) {
            lblError.setText("Vui lòng không để trống thông tin đăng nhập!");
            return;
        }

        // Mở kết nối mạng gửi lệnh xác thực tài khoản đăng nhập trực tiếp lên máy chủ máy chủ
        try (Socket socket = new Socket("localhost", 9999);
             ObjectOutputStream out = new ObjectOutputStream(socket.getOutputStream());
             ObjectInputStream in = new ObjectInputStream(socket.getInputStream())) {

            // Gửi dữ liệu định dạng giao thức: COMMAND|param1|param2
            out.writeObject("LOGIN|" + username + "|" + password);
            out.flush();

            String response = (String) in.readObject();
            if (response.startsWith("LOGIN_SUCCESS")) {
                String role = response.split("\\|")[1]; // Bóc tách chuỗi nhận về Vai trò của user

                // Chuyển màn hình và nạp dữ liệu phân quyền sang trang Dashboard chính
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/dashboard.fxml"));
                Parent root = loader.load();

                // Gửi dữ liệu trạng thái đăng nhập sang controller Dashboard
                KaraokeDashboardController dashboardController = loader.getController();
                dashboardController.initUserData(username, role);

                // Thao tác hiển thị Window giao diện mới
                Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
                stage.setScene(new Scene(root, 850, 600));
                stage.setTitle("Hệ Thống Karaoke VKU - Quản Lý");
                stage.centerOnScreen();
            } else {
                lblError.setText("Tài khoản hoặc mật khẩu không chính xác!");
            }
        } catch (Exception e) {
            lblError.setText("Lỗi kết nối máy chủ mạng Server sập!");
            e.printStackTrace();
        }
    }
}