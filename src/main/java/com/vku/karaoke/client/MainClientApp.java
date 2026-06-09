package com.vku.karaoke.client;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class MainClientApp extends Application {
    @Override
    public void start(Stage primaryStage) throws Exception {
        // Nạp thử file fxml từ thư mục resources
        Parent root = FXMLLoader.load(getClass().getResource("/login.fxml"));
        primaryStage.setTitle("Kiểm tra JavaFX Maven");
        primaryStage.setScene(new Scene(root, 350, 250));
        primaryStage.centerOnScreen();
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}