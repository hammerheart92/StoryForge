package dev.laszlo.service;

import dev.laszlo.dto.CreateGalleryItemRequest;
import dev.laszlo.dto.GalleryItemDto;
import dev.laszlo.dto.UpdateGalleryItemRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for gallery item (story_content) CRUD operations for creators.
 * Uses JDBC with story ownership verification.
 */
@Service
public class GalleryAdminService {

    private static final Logger logger = LoggerFactory.getLogger(GalleryAdminService.class);
    private final JdbcTemplate jdbcTemplate;

    public GalleryAdminService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * RowMapper to convert SQL result to GalleryItemDto
     */
    private final RowMapper<GalleryItemDto> galleryItemRowMapper = (rs, rowNum) -> {
        GalleryItemDto dto = new GalleryItemDto();
        dto.setContentId(rs.getLong("content_id"));
        dto.setStoryId(rs.getString("story_id"));
        dto.setContentType(rs.getString("content_type"));
        dto.setContentCategory(rs.getString("content_category"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setUnlockCost(rs.getInt("unlock_cost"));
        dto.setRarity(rs.getString("rarity"));
        dto.setUnlockCondition(rs.getString("unlock_condition"));
        dto.setContentUrl(rs.getString("content_url"));
        dto.setThumbnailUrl(rs.getString("thumbnail_url"));
        dto.setDisplayOrder(rs.getInt("display_order"));

        // Handle nullable created_by_user_id
        long creatorId = rs.getLong("created_by_user_id");
        dto.setCreatedByUserId(rs.wasNull() ? null : creatorId);

        // Handle timestamp
        Timestamp createdAt = rs.getTimestamp("created_at");
        dto.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);

        return dto;
    };

    /**
     * Create a new gallery item for a story
     */
    public GalleryItemDto createGalleryItem(CreateGalleryItemRequest request, Long creatorUserId) {
        // Verify creator owns the story
        verifyStoryOwnership(request.getStoryId(), creatorUserId);

        String sql = """
            INSERT INTO story_content (story_id, content_type, content_category, title, description,
                unlock_cost, rarity, unlock_condition, content_url, thumbnail_url, display_order,
                created_by_user_id, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            RETURNING content_id, story_id, content_type, content_category, title, description,
                unlock_cost, rarity, unlock_condition, content_url, thumbnail_url, display_order,
                created_by_user_id, created_at
            """;

        GalleryItemDto item = jdbcTemplate.queryForObject(sql, galleryItemRowMapper,
                request.getStoryId(),
                request.getContentType(),
                request.getContentCategory(),
                request.getTitle(),
                request.getDescription(),
                request.getUnlockCost(),
                request.getRarity(),
                request.getUnlockCondition(),
                request.getContentUrl(),
                request.getThumbnailUrl(),
                request.getDisplayOrder() != null ? request.getDisplayOrder() : 0,
                creatorUserId);

        logger.info("🖼️ Created gallery item '{}' for story '{}' by user {}",
                request.getTitle(), request.getStoryId(), creatorUserId);
        return item;
    }

    /**
     * Get all gallery items created by a specific user (across all their stories)
     */
    public List<GalleryItemDto> getGalleryItemsByCreator(Long creatorUserId) {
        String sql = """
            SELECT sc.content_id, sc.story_id, sc.content_type, sc.content_category, sc.title,
                sc.description, sc.unlock_cost, sc.rarity, sc.unlock_condition, sc.content_url,
                sc.thumbnail_url, sc.display_order, sc.created_by_user_id, sc.created_at
            FROM story_content sc
            JOIN stories s ON sc.story_id = s.story_id
            WHERE s.created_by_user_id = ?
            ORDER BY sc.story_id, sc.display_order, sc.content_id
            """;

        return jdbcTemplate.query(sql, galleryItemRowMapper, creatorUserId);
    }

    /**
     * Get all gallery items for a specific story (with ownership check)
     */
    public List<GalleryItemDto> getGalleryItemsByStory(String storyId, Long creatorUserId) {
        // Verify creator owns the story
        verifyStoryOwnership(storyId, creatorUserId);

        String sql = """
            SELECT content_id, story_id, content_type, content_category, title, description,
                unlock_cost, rarity, unlock_condition, content_url, thumbnail_url, display_order,
                created_by_user_id, created_at
            FROM story_content
            WHERE story_id = ?
            ORDER BY display_order, content_id
            """;

        return jdbcTemplate.query(sql, galleryItemRowMapper, storyId);
    }

    /**
     * Get a single gallery item by ID (with ownership check)
     */
    public GalleryItemDto getGalleryItemById(Long contentId, Long creatorUserId) {
        String sql = """
            SELECT content_id, story_id, content_type, content_category, title, description,
                unlock_cost, rarity, unlock_condition, content_url, thumbnail_url, display_order,
                created_by_user_id, created_at
            FROM story_content
            WHERE content_id = ?
            """;

        try {
            GalleryItemDto item = jdbcTemplate.queryForObject(sql, galleryItemRowMapper, contentId);

            if (item == null) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Gallery item not found");
            }

            // Verify creator owns the story this item belongs to
            verifyStoryOwnership(item.getStoryId(), creatorUserId);

            return item;
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Gallery item not found");
        }
    }

    /**
     * Update a gallery item (with ownership check)
     */
    public GalleryItemDto updateGalleryItem(Long contentId, UpdateGalleryItemRequest request, Long creatorUserId) {
        // Get item to verify story ownership
        GalleryItemDto existing = getGalleryItemById(contentId, creatorUserId);

        // Build dynamic update SQL based on non-null fields
        StringBuilder sqlBuilder = new StringBuilder("UPDATE story_content SET content_id = content_id");
        List<Object> params = new ArrayList<>();

        if (request.getContentType() != null) {
            sqlBuilder.append(", content_type = ?");
            params.add(request.getContentType());
        }
        if (request.getContentCategory() != null) {
            sqlBuilder.append(", content_category = ?");
            params.add(request.getContentCategory());
        }
        if (request.getTitle() != null) {
            sqlBuilder.append(", title = ?");
            params.add(request.getTitle());
        }
        if (request.getDescription() != null) {
            sqlBuilder.append(", description = ?");
            params.add(request.getDescription());
        }
        if (request.getUnlockCost() != null) {
            sqlBuilder.append(", unlock_cost = ?");
            params.add(request.getUnlockCost());
        }
        if (request.getRarity() != null) {
            sqlBuilder.append(", rarity = ?");
            params.add(request.getRarity());
        }
        if (request.getUnlockCondition() != null) {
            sqlBuilder.append(", unlock_condition = ?");
            params.add(request.getUnlockCondition());
        }
        if (request.getContentUrl() != null) {
            sqlBuilder.append(", content_url = ?");
            params.add(request.getContentUrl());
        }
        if (request.getThumbnailUrl() != null) {
            sqlBuilder.append(", thumbnail_url = ?");
            params.add(request.getThumbnailUrl());
        }
        if (request.getDisplayOrder() != null) {
            sqlBuilder.append(", display_order = ?");
            params.add(request.getDisplayOrder());
        }

        sqlBuilder.append("""
             WHERE content_id = ?
            RETURNING content_id, story_id, content_type, content_category, title, description,
                unlock_cost, rarity, unlock_condition, content_url, thumbnail_url, display_order,
                created_by_user_id, created_at
            """);
        params.add(contentId);

        GalleryItemDto item = jdbcTemplate.queryForObject(sqlBuilder.toString(), galleryItemRowMapper, params.toArray());

        logger.info("📝 Updated gallery item {} for user {}", contentId, creatorUserId);
        return item;
    }

    /**
     * Delete a gallery item (with ownership check)
     */
    public void deleteGalleryItem(Long contentId, Long creatorUserId) {
        // Verify ownership by loading item and checking story
        getGalleryItemById(contentId, creatorUserId);

        String sql = "DELETE FROM story_content WHERE content_id = ?";
        int rowsAffected = jdbcTemplate.update(sql, contentId);

        if (rowsAffected > 0) {
            logger.info("🗑️ Deleted gallery item {} for user {}", contentId, creatorUserId);
        }
    }

    /**
     * Verify that the creator owns the story.
     * Uses simplified SELECT 1 approach.
     * Throws ResponseStatusException(FORBIDDEN) if not owner.
     * Throws ResponseStatusException(NOT_FOUND) if story doesn't exist.
     */
    private void verifyStoryOwnership(String storyId, Long creatorUserId) {
        String sql = "SELECT 1 FROM stories WHERE story_id = ? AND created_by_user_id = ?";

        try {
            Integer result = jdbcTemplate.queryForObject(sql, Integer.class, storyId, creatorUserId);

            if (result == null) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "You don't have permission to manage gallery items for this story");
            }
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            // Could be EmptyResultDataAccessException (no rows) - need to distinguish
            // Check if story exists at all
            String existsSql = "SELECT COUNT(*) FROM stories WHERE story_id = ?";
            Integer count = jdbcTemplate.queryForObject(existsSql, Integer.class, storyId);

            if (count == null || count == 0) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Story not found");
            } else {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "You don't have permission to manage gallery items for this story");
            }
        }
    }
}
