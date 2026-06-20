package com.vku.karaoke.utils;

import com.vku.karaoke.model.SystemConfig;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.File;

public class ConfigXMLUtil {
    private static final String CONFIG_FILE = "config.xml";

    private ConfigXMLUtil() {
    }

    public static SystemConfig loadConfig() {
        try {
            File file = new File(CONFIG_FILE);
            if (!file.exists()) {
                SystemConfig config = SystemConfig.defaultConfig();
                saveConfig(config);
                return config;
            }

            Document doc = DocumentBuilderFactory.newInstance()
                    .newDocumentBuilder()
                    .parse(file);

            doc.getDocumentElement().normalize();

            return new SystemConfig(
                    getText(doc, "serverHost", "localhost"),
                    Integer.parseInt(getText(doc, "serverPort", "9999")),
                    getText(doc, "dbHost", "localhost"),
                    Integer.parseInt(getText(doc, "dbPort", "3306")),
                    getText(doc, "dbName", "karaoke_db"),
                    getText(doc, "dbUser", "root"),
                    getText(doc, "dbPassword", "Admin@123")
            );
        } catch (Exception e) {
            System.err.println("Không đọc được config.xml, dùng cấu hình mặc định: " + e.getMessage());
            return SystemConfig.defaultConfig();
        }
    }

    public static void saveConfig(SystemConfig config) {
        try {
            Document doc = DocumentBuilderFactory.newInstance()
                    .newDocumentBuilder()
                    .newDocument();

            Element root = doc.createElement("config");
            doc.appendChild(root);

            append(doc, root, "serverHost", config.getServerHost());
            append(doc, root, "serverPort", String.valueOf(config.getServerPort()));
            append(doc, root, "dbHost", config.getDbHost());
            append(doc, root, "dbPort", String.valueOf(config.getDbPort()));
            append(doc, root, "dbName", config.getDbName());
            append(doc, root, "dbUser", config.getDbUser());
            append(doc, root, "dbPassword", config.getDbPassword());

            javax.xml.transform.Transformer transformer =
                    TransformerFactory.newInstance().newTransformer();

            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

            transformer.transform(new DOMSource(doc), new StreamResult(new File(CONFIG_FILE)));
        } catch (Exception e) {
            throw new RuntimeException("Không ghi được file config.xml", e);
        }
    }

    private static String getText(Document doc, String tag, String defaultValue) {
        if (doc.getElementsByTagName(tag).getLength() == 0) {
            return defaultValue;
        }

        String value = doc.getElementsByTagName(tag).item(0).getTextContent();
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }

        return value.trim();
    }

    private static void append(Document doc, Element root, String tag, String value) {
        Element element = doc.createElement(tag);
        element.appendChild(doc.createTextNode(value));
        root.appendChild(element);
    }
}
