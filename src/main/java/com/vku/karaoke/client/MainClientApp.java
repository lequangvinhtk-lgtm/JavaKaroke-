package com.vku.karaoke.client;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class MainClientApp extends Application {
    @Override
    public void start(Stage stage) throws Exception {
        FXMLLoader loader = new FXMLLoader(MainClientApp.class.getResource("/login.fxml"));

        Scene scene = new Scene(loader.load(), 520, 520);
        scene.getStylesheets().add(MainClientApp.class.getResource("/style.css").toExternalForm());

        stage.setTitle("Đăng nhập hệ thống Karaoke");
        stage.setScene(scene);

        stage.setMinWidth(520);
        stage.setMinHeight(520);
        stage.setResizable(false);

        stage.centerOnScreen();
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
