package dev.laszlo.service;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import java.sql.ResultSet;
import java.sql.Timestamp;

/**
 * Base service class providing shared database connection functionality.
 * Handles Railway DATABASE_URL to JDBC format conversion for all service classes.
 * ⭐ SESSION 36: DRY refactoring - extracted from 5 service classes
 */
public abstract class BaseService {

    /**
     * Get database connection URL.
     * - Production (Railway): Uses DATABASE_URL environment variable
     * - Local development: Uses localhost PostgreSQL
     */
    protected String getDatabaseUrl() {
        String railwayUrl = System.getenv("DATABASE_URL");
        if (railwayUrl != null && !railwayUrl.isEmpty()) {
            return convertToJdbcUrl(railwayUrl);
        }
        return "jdbc:postgresql://localhost:5432/storyforge?user=postgres&password=postgres";
    }

    /**
     * Convert DATABASE_URL to JDBC-compatible format.
     * Railway provides: postgresql://user:password@host:port/database
     * JDBC requires:    jdbc:postgresql://host:port/database?user=xxx&password=xxx
     */
    protected String convertToJdbcUrl(String url) {
        if (!url.startsWith("jdbc:")) {
            url = "jdbc:" + url;
        }
        if (url.contains("@")) {
            try {
                String withoutPrefix = url.substring("jdbc:postgresql://".length());
                int atIndex = withoutPrefix.indexOf("@");
                if (atIndex > 0) {
                    String credentials = withoutPrefix.substring(0, atIndex);
                    String hostAndDb = withoutPrefix.substring(atIndex + 1);
                    int colonIndex = credentials.indexOf(":");
                    if (colonIndex > 0) {
                        String user = credentials.substring(0, colonIndex);
                        String password = credentials.substring(colonIndex + 1);
                        String jdbcUrl = "jdbc:postgresql://" + hostAndDb;
                        return jdbcUrl + (jdbcUrl.contains("?") ? "&" : "?") + "user=" + user + "&password=" + password;
                    }
                }
            } catch (Exception e) {
                // Silent fail - return original URL
            }
        }
        return url;
    }

    /**
     * Get database connection.
     */
    protected Connection getConnection() throws SQLException {
        return DriverManager.getConnection(getDatabaseUrl());
    }

    /**
     * Safely read a timestamp column and convert to ISO string.
     * Returns null if timestamp is null.
     *
     * @param rs         ResultSet to read from
     * @param columnName Column name containing timestamp
     * @return ISO-formatted timestamp string or null
     * @throws SQLException if column access fails
     */
    protected String getTimestampAsString(ResultSet rs, String columnName) throws SQLException {
        Timestamp ts = rs.getTimestamp(columnName);
        return ts != null ? ts.toLocalDateTime().toString() : null;
    }
}