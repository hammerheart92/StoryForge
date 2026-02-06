package dev.laszlo.service;

import dev.laszlo.dto.CreateStoryRequest;
import dev.laszlo.dto.StoryDto;
import dev.laszlo.dto.UpdateStoryRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.util.List;

/**
 * Service for story CRUD operations for creators.
 * Uses JDBC with ownership verification.
 */
@Service
public class StoryAdminService {

    private static final Logger logger = LoggerFactory.getLogger(StoryAdminService.class);
    private final JdbcTemplate jdbcTemplate;

    public StoryAdminService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * RowMapper to convert SQL result to StoryDto
     */
    private final RowMapper<StoryDto> storyRowMapper = (rs, rowNum) -> {
        StoryDto dto = new StoryDto();
        dto.setId(rs.getLong("id"));
        dto.setStoryId(rs.getString("story_id"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setCoverImageUrl(rs.getString("cover_image_url"));
        dto.setPublished(rs.getBoolean("is_published"));

        // Handle nullable created_by_user_id
        long creatorId = rs.getLong("created_by_user_id");
        dto.setCreatedByUserId(rs.wasNull() ? null : creatorId);

        // Handle timestamps
        Timestamp createdAt = rs.getTimestamp("created_at");
        dto.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        dto.setUpdatedAt(updatedAt != null ? updatedAt.toLocalDateTime() : null);

        return dto;
    };

    /**
     * Create a new story for a creator
     */
    public StoryDto createStory(CreateStoryRequest request, Long creatorUserId) {
        String storyId = generateUniqueStoryId(request.getTitle());

        String sql = """
            INSERT INTO stories (story_id, title, description, cover_image_url, is_published, created_by_user_id, created_at, updated_at)
            VALUES (?, ?, ?, ?, FALSE, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            RETURNING id, story_id, title, description, cover_image_url, is_published, created_by_user_id, created_at, updated_at
            """;

        StoryDto story = jdbcTemplate.queryForObject(sql, storyRowMapper,
                storyId,
                request.getTitle(),
                request.getDescription(),
                request.getCoverImageUrl(),
                creatorUserId);

        logger.info("📚 Created story '{}' (storyId: {}) for user {}", request.getTitle(), storyId, creatorUserId);
        return story;
    }

    /**
     * Get all stories created by a specific user
     */
    public List<StoryDto> getStoriesByCreator(Long creatorUserId) {
        String sql = """
            SELECT id, story_id, title, description, cover_image_url, is_published, created_by_user_id, created_at, updated_at
            FROM stories
            WHERE created_by_user_id = ?
            ORDER BY created_at DESC
            """;

        return jdbcTemplate.query(sql, storyRowMapper, creatorUserId);
    }

    /**
     * Get a single story by ID (with ownership check)
     */
    public StoryDto getStoryById(Long storyId, Long creatorUserId) {
        String sql = """
            SELECT id, story_id, title, description, cover_image_url, is_published, created_by_user_id, created_at, updated_at
            FROM stories
            WHERE id = ?
            """;

        try {
            StoryDto story = jdbcTemplate.queryForObject(sql, storyRowMapper, storyId);

            // Verify ownership
            if (story == null) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Story not found");
            }

            if (story.getCreatedByUserId() == null || !story.getCreatedByUserId().equals(creatorUserId)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permission to access this story");
            }

            return story;
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Story not found");
        }
    }

    /**
     * Update a story (with ownership check)
     */
    public StoryDto updateStory(Long storyId, UpdateStoryRequest request, Long creatorUserId) {
        // Verify ownership first
        verifyOwnership(storyId, creatorUserId);

        // Build dynamic update SQL based on non-null fields
        StringBuilder sqlBuilder = new StringBuilder("UPDATE stories SET updated_at = CURRENT_TIMESTAMP");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (request.getTitle() != null) {
            sqlBuilder.append(", title = ?");
            params.add(request.getTitle());
        }
        if (request.getDescription() != null) {
            sqlBuilder.append(", description = ?");
            params.add(request.getDescription());
        }
        if (request.getCoverImageUrl() != null) {
            sqlBuilder.append(", cover_image_url = ?");
            params.add(request.getCoverImageUrl());
        }
        if (request.getIsPublished() != null) {
            sqlBuilder.append(", is_published = ?");
            params.add(request.getIsPublished());
        }

        sqlBuilder.append(" WHERE id = ? RETURNING id, story_id, title, description, cover_image_url, is_published, created_by_user_id, created_at, updated_at");
        params.add(storyId);

        StoryDto story = jdbcTemplate.queryForObject(sqlBuilder.toString(), storyRowMapper, params.toArray());

        logger.info("📝 Updated story {} for user {}", storyId, creatorUserId);
        return story;
    }

    /**
     * Delete a story (with ownership check)
     */
    public void deleteStory(Long storyId, Long creatorUserId) {
        // Verify ownership first
        verifyOwnership(storyId, creatorUserId);

        String sql = "DELETE FROM stories WHERE id = ?";
        int rowsAffected = jdbcTemplate.update(sql, storyId);

        if (rowsAffected > 0) {
            logger.info("🗑️ Deleted story {} for user {}", storyId, creatorUserId);
        }
    }

    /**
     * Toggle publish status of a story (with ownership check)
     */
    public StoryDto togglePublishStatus(Long storyId, Long creatorUserId) {
        // Verify ownership first
        verifyOwnership(storyId, creatorUserId);

        String sql = """
            UPDATE stories
            SET is_published = NOT is_published, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
            RETURNING id, story_id, title, description, cover_image_url, is_published, created_by_user_id, created_at, updated_at
            """;

        StoryDto story = jdbcTemplate.queryForObject(sql, storyRowMapper, storyId);

        logger.info("🔄 Toggled publish status for story {} to {} for user {}",
                storyId, story != null ? story.isPublished() : "unknown", creatorUserId);
        return story;
    }

    /**
     * Generate a unique URL-friendly story ID from title
     * - Lowercase
     * - Replace spaces with hyphens
     * - Remove special characters
     * - Max 50 characters
     * - Append counter if duplicate exists
     */
    private String generateUniqueStoryId(String title) {
        // Sanitize: lowercase, replace spaces with hyphens, remove special chars
        String baseId = title.toLowerCase()
                .replaceAll("[^a-z0-9\\s-]", "")  // Remove special chars
                .replaceAll("\\s+", "-")          // Replace spaces with hyphens
                .replaceAll("-+", "-")            // Collapse multiple hyphens
                .replaceAll("^-|-$", "");         // Trim leading/trailing hyphens

        // Limit to 45 chars to leave room for counter
        if (baseId.length() > 45) {
            baseId = baseId.substring(0, 45);
        }

        // Check if exists and append counter if needed
        String candidateId = baseId;
        int counter = 1;

        while (storyIdExists(candidateId)) {
            counter++;
            candidateId = baseId + "-" + counter;

            // Safety limit
            if (counter > 1000) {
                candidateId = baseId + "-" + System.currentTimeMillis();
                break;
            }
        }

        return candidateId;
    }

    /**
     * Check if a story_id already exists
     */
    private boolean storyIdExists(String storyId) {
        String sql = "SELECT COUNT(*) FROM stories WHERE story_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, storyId);
        return count != null && count > 0;
    }

    /**
     * Verify that the user owns the story
     * Throws ResponseStatusException(FORBIDDEN) if not owner
     * Throws ResponseStatusException(NOT_FOUND) if story doesn't exist
     */
    private void verifyOwnership(Long storyId, Long creatorUserId) {
        String sql = "SELECT created_by_user_id FROM stories WHERE id = ?";

        try {
            Long ownerId = jdbcTemplate.queryForObject(sql, Long.class, storyId);

            if (ownerId == null || !ownerId.equals(creatorUserId)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permission to modify this story");
            }
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Story not found");
        }
    }
}
