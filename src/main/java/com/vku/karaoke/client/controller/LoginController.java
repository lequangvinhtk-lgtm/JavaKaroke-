package com.vku.karaoke.client.controller;

import com.vku.karaoke.client.MainClientApp;
import com.vku.karaoke.client.network.ClientConnection;
import com.vku.karaoke.model.Request;
import com.vku.karaoke.model.Response;
import com.vku.karaoke.model.User;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

public class LoginController {
    @FXML
    private TextField txtUsername;

    @FXML
    private PasswordField txtPassword;

    @FXML
    private Label lblError;

    @FXML
    void handleLogin(ActionEvent event) {
        String username = txtUsername.getText().trim();
        String password = txtPassword.getText().trim();

        if (username.isEmpty() || password.isEmpty()) {
            lblError.setText("Vui lòng nhập đầy đủ tài khoản và mật khẩu.");
            return;
        }

        ClientConnection connection = null;

        try {
            connection = new ClientConnection();

            Response response = connection.send(new Request(
                    "LOGIN",
                    new String[]{username, password}
            ));

            if (!response.isSuccess()) {
                lblError.setText(response.getMessage());
                connection.close();
                return;
            }

            User user = (User) response.getData();

            FXMLLoader loader = new FXMLLoader(MainClientApp.class.getResource("/dashboard.fxml"));
            Scene scene = new Scene(loader.load(), 1100, 720);
            scene.getStylesheets().add(MainClientApp.class.getResource("/style.css").toExternalForm());

            KaraokeDashboardController controller = loader.getController();
            controller.initUserData(connection, user);

            Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
            stage.setTitle("Hệ thống quản lý bài hát Karaoke");
            stage.setScene(scene);
            stage.centerOnScreen();
        } catch (Exception e) {
            lblError.setText("Không kết nối được Server. Hãy chạy MainServer trước.");
            if (connection != null) {
                connection.close();
            }
            e.printStackTrace();
        }
    }
}
