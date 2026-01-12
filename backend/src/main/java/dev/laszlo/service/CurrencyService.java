package dev.laszlo.service;

import dev.laszlo.model.UserCurrency;
import dev.laszlo.model.GemTransaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class CurrencyService {
    private static final Logger logger = LoggerFactory.getLogger(CurrencyService.class);
    private static final String DB_URL = "jdbc:sqlite:storyforge.db";

    /**
     * 💎 Award gems to a user for completing actions
     *
     * @param userId User identifier
     * @param amount Number of gems to award
     * @param source Source of gems (e.g., "choice_made", "story_completed")
     * @param storyId Story context for the transaction
     * @return true if successful, false otherwise
     */
    public boolean awardGems(String userId, int amount, String source, String storyId) {
        String updateBalanceSql = """
                UPDATE user_currency
                SET gem_balance = gem_balance + ?,
                    total_earned = total_earned + ?,
                    last_updated = ?
                WHERE user_id = ?
                """;

        String insertTransactionSql = """
                INSERT INTO gem_transactions (user_id, amount, transaction_type, source, story_id)
                VALUES (?, ?, 'earn', ?, ?)
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL)) {
            conn.setAutoCommit(false); // Start transaction

            // Update user balance
            try (PreparedStatement pstmt = conn.prepareStatement(updateBalanceSql)) {
                pstmt.setInt(1, amount);
                pstmt.setInt(2, amount);
                pstmt.setString(3, LocalDateTime.now().toString());
                pstmt.setString(4, userId);

                int updated = pstmt.executeUpdate();
                if (updated == 0) {
                    logger.error("❌ User {} not found in user_currency table", userId);
                    conn.rollback();
                    return false;
                }
            }

            // Log transaction
            try (PreparedStatement pstmt = conn.prepareStatement(insertTransactionSql)) {
                pstmt.setString(1, userId);
                pstmt.setInt(2, amount);
                pstmt.setString(3, source);
                pstmt.setString(4, storyId);
                pstmt.executeUpdate();
            }

            conn.commit();
            logger.info("💎 Awarded {} gems to {} (source: {})", amount, userId, source);
            return true;

        } catch (SQLException e) {
            logger.error("❌ Failed to award gems: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 💰 Spend gems for unlocking content
     *
     * @param userId User identifier
     * @param amount Number of gems to spend
     * @param contentId Content being unlocked
     * @return true if successful, false if insufficient balance or error
     */
    public boolean spendGems(String userId, int amount, int contentId) {
        // First check if user has enough gems
        int currentBalance = getGemBalance(userId);
        if (currentBalance < amount) {
            logger.warn("⚠️ User {} has insufficient gems (has: {}, needs: {})", userId, currentBalance, amount);
            return false;
        }

        String updateBalanceSql = """
                UPDATE user_currency
                SET gem_balance = gem_balance - ?,
                    total_spent = total_spent + ?,
                    last_updated = ?
                WHERE user_id = ?
                """;

        String insertTransactionSql = """
                INSERT INTO gem_transactions (user_id, amount, transaction_type, source, content_id)
                VALUES (?, ?, 'spend', 'unlock_content', ?)
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL)) {
            conn.setAutoCommit(false); // Start transaction

            // Deduct gems from balance
            try (PreparedStatement pstmt = conn.prepareStatement(updateBalanceSql)) {
                pstmt.setInt(1, amount);
                pstmt.setInt(2, amount);
                pstmt.setString(3, LocalDateTime.now().toString());
                pstmt.setString(4, userId);
                pstmt.executeUpdate();
            }

            // Log transaction
            try (PreparedStatement pstmt = conn.prepareStatement(insertTransactionSql)) {
                pstmt.setString(1, userId);
                pstmt.setInt(2, amount);
                pstmt.setInt(3, contentId);
                pstmt.executeUpdate();
            }

            conn.commit();
            logger.info("💰 User {} spent {} gems (new balance: {})", userId, amount, currentBalance - amount);
            return true;

        } catch (SQLException e) {
            logger.error("❌ Failed to spend gems: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 💵 Get user's current gem balance
     *
     * @param userId User identifier
     * @return Current gem balance, or 0 if user not found
     */
    public int getGemBalance(String userId) {
        String sql = "SELECT gem_balance FROM user_currency WHERE user_id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("gem_balance");
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to get gem balance: {}", e.getMessage());
        }

        return 0;
    }

    /**
     * 📊 Get user's complete currency information
     *
     * @param userId User identifier
     * @return UserCurrency object or null if not found
     */
    public UserCurrency getUserCurrency(String userId) {
        String sql = "SELECT * FROM user_currency WHERE user_id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return new UserCurrency(
                        rs.getString("user_id"),
                        rs.getInt("gem_balance"),
                        rs.getInt("total_earned"),
                        rs.getInt("total_spent"),
                        rs.getString("last_updated"),
                        rs.getString("created_at")
                );
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to get user currency: {}", e.getMessage());
        }

        return null;
    }

    /**
     * 📜 Get transaction history for a user
     *
     * @param userId User identifier
     * @param limit Maximum number of transactions to return
     * @return List of recent transactions
     */
    public List<GemTransaction> getTransactionHistory(String userId, int limit) {
        List<GemTransaction> transactions = new ArrayList<>();
        String sql = """
                SELECT * FROM gem_transactions
                WHERE user_id = ?
                ORDER BY timestamp DESC
                LIMIT ?
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setInt(2, limit);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                GemTransaction transaction = new GemTransaction(
                        rs.getInt("transaction_id"),
                        rs.getString("user_id"),
                        rs.getInt("amount"),
                        rs.getString("transaction_type"),
                        rs.getString("source"),
                        rs.getString("story_id"),
                        rs.getObject("content_id") != null ? rs.getInt("content_id") : null,
                        rs.getString("timestamp")
                );
                transactions.add(transaction);
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to get transaction history: {}", e.getMessage());
        }

        return transactions;
    }
}