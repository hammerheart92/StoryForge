package dev.laszlo.controller;

import dev.laszlo.dto.CreateStoryRequest;
import dev.laszlo.dto.StoryDto;
import dev.laszlo.dto.UpdateStoryRequest;
import dev.laszlo.security.SecurityContextHelper;
import dev.laszlo.service.StoryAdminService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Admin endpoints for story management
 * All endpoints require CREATOR role
 */
@RestController
@RequestMapping("/api/admin/stories")
public class StoryAdminController {

    private final StoryAdminService storyAdminService;
    private final SecurityContextHelper securityContextHelper;

    public StoryAdminController(StoryAdminService storyAdminService, SecurityContextHelper securityContextHelper) {
        this.storyAdminService = storyAdminService;
        this.securityContextHelper = securityContextHelper;
    }

    /**
     * Create a new story
     *
     * POST /api/admin/stories
     * Body: { "title": "string", "description": "string", "coverImageUrl": "string" }
     */
    @PreAuthorize("hasRole('CREATOR')")
    @PostMapping
    public ResponseEntity<?> createStory(@Valid @RequestBody CreateStoryRequest request) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            StoryDto story = storyAdminService.createStory(request, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(story);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to create story: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Get all stories created by the authenticated user
     *
     * GET /api/admin/stories
     */
    @PreAuthorize("hasRole('CREATOR')")
    @GetMapping
    public ResponseEntity<?> getMyStories() {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            List<StoryDto> stories = storyAdminService.getStoriesByCreator(userId);
            return ResponseEntity.ok(stories);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to get stories: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Get a single story by ID
     *
     * GET /api/admin/stories/{id}
     */
    @PreAuthorize("hasRole('CREATOR')")
    @GetMapping("/{id}")
    public ResponseEntity<?> getStory(@PathVariable Long id) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            StoryDto story = storyAdminService.getStoryById(id, userId);
            return ResponseEntity.ok(story);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }

    /**
     * Update a story
     *
     * PUT /api/admin/stories/{id}
     * Body: { "title": "string", "description": "string", "coverImageUrl": "string", "isPublished": boolean }
     */
    @PreAuthorize("hasRole('CREATOR')")
    @PutMapping("/{id}")
    public ResponseEntity<?> updateStory(@PathVariable Long id, @Valid @RequestBody UpdateStoryRequest request) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            StoryDto story = storyAdminService.updateStory(id, request, userId);
            return ResponseEntity.ok(story);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }

    /**
     * Delete a story
     *
     * DELETE /api/admin/stories/{id}
     */
    @PreAuthorize("hasRole('CREATOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteStory(@PathVariable Long id) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            storyAdminService.deleteStory(id, userId);
            return ResponseEntity.noContent().build();
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }

    /**
     * Toggle publish status of a story
     *
     * PATCH /api/admin/stories/{id}/publish
     */
    @PreAuthorize("hasRole('CREATOR')")
    @PatchMapping("/{id}/publish")
    public ResponseEntity<?> togglePublish(@PathVariable Long id) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            StoryDto story = storyAdminService.togglePublishStatus(id, userId);
            return ResponseEntity.ok(story);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }
}
