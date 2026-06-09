package com.vku.sales.controller;

import com.vku.karaoke.client.controller.KaraokeDashboardController; // FIX: thêm import đúng package

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

public class LoginController {

    @FXML private TextField txtUsername;
    @FXML private PasswordField txtPassword;
    @FXML private Label lblError;

    @FXML
    void handleLogin(ActionEvent event) {
        String username = txtUsername.getText().trim();
        String password = txtPassword.getText().trim();

        if (username.isEmpty() || password.isEmpty()) {
            lblError.setText("Vui lòng điền đầy đủ thông tin!");
            return;
        }

        try (Socket socket = new Socket("localhost", 9999)) {
            ObjectOutputStream out = new ObjectOutputStream(socket.getOutputStream());
            out.flush();
            ObjectInputStream in = new ObjectInputStream(socket.getInputStream());

            out.writeObject("LOGIN|" + username + "|" + password);
            out.flush();

            String response = (String) in.readObject();
            if (response.startsWith("LOGIN_SUCCESS")) {
                String role = response.split("\\|")[1];
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/dashboard.fxml"));
                Parent root = loader.load();

                KaraokeDashboardController dashboard = loader.getController();
                dashboard.initUserData(username, role);

                Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
                stage.setScene(new Scene(root, 850, 600));
                stage.setTitle("Hệ Thống Quản Lý Bài Hát Karaoke");
                stage.centerOnScreen();
            } else if (response.equals("DB_ERROR")) {
                lblError.setText("Máy chủ gặp lỗi Database. Kiểm tra Server!");
            } else {
                lblError.setText("Sai tài khoản hoặc mật khẩu!");
            }
        } catch (Exception e) {
            lblError.setText("Máy chủ Server chưa được bật hoặc đang lỗi!");
        }
    }
}