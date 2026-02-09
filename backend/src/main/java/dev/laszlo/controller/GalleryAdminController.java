package dev.laszlo.controller;

import dev.laszlo.dto.CreateGalleryItemRequest;
import dev.laszlo.dto.GalleryItemDto;
import dev.laszlo.dto.UpdateGalleryItemRequest;
import dev.laszlo.security.SecurityContextHelper;
import dev.laszlo.service.GalleryAdminService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Admin endpoints for gallery item (story_content) management
 * All endpoints require CREATOR role
 */
@RestController
@RequestMapping("/api/admin/gallery")
public class GalleryAdminController {

    private final GalleryAdminService galleryAdminService;
    private final SecurityContextHelper securityContextHelper;

    public GalleryAdminController(GalleryAdminService galleryAdminService, SecurityContextHelper securityContextHelper) {
        this.galleryAdminService = galleryAdminService;
        this.securityContextHelper = securityContextHelper;
    }

    /**
     * Create a new gallery item
     *
     * POST /api/admin/gallery
     */
    @PreAuthorize("hasRole('CREATOR')")
    @PostMapping
    public ResponseEntity<?> createGalleryItem(@Valid @RequestBody CreateGalleryItemRequest request) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            GalleryItemDto item = galleryAdminService.createGalleryItem(request, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(item);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to create gallery item: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Get all gallery items for the authenticated creator
     *
     * GET /api/admin/gallery
     */
    @PreAuthorize("hasRole('CREATOR')")
    @GetMapping
    public ResponseEntity<?> getMyGalleryItems() {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            List<GalleryItemDto> items = galleryAdminService.getGalleryItemsByCreator(userId);
            return ResponseEntity.ok(items);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to get gallery items: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Get gallery items for a specific story
     *
     * GET /api/admin/gallery/story/{storyId}
     */
    @PreAuthorize("hasRole('CREATOR')")
    @GetMapping("/story/{storyId}")
    public ResponseEntity<?> getGalleryItemsByStory(@PathVariable String storyId) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            List<GalleryItemDto> items = galleryAdminService.getGalleryItemsByStory(storyId, userId);
            return ResponseEntity.ok(items);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }

    /**
     * Get a single gallery item by ID
     *
     * GET /api/admin/gallery/{id}
     */
    @PreAuthorize("hasRole('CREATOR')")
    @GetMapping("/{id}")
    public ResponseEntity<?> getGalleryItem(@PathVariable Long id) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            GalleryItemDto item = galleryAdminService.getGalleryItemById(id, userId);
            return ResponseEntity.ok(item);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }

    /**
     * Update a gallery item
     *
     * PUT /api/admin/gallery/{id}
     */
    @PreAuthorize("hasRole('CREATOR')")
    @PutMapping("/{id}")
    public ResponseEntity<?> updateGalleryItem(@PathVariable Long id, @Valid @RequestBody UpdateGalleryItemRequest request) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            GalleryItemDto item = galleryAdminService.updateGalleryItem(id, request, userId);
            return ResponseEntity.ok(item);
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }

    /**
     * Delete a gallery item
     *
     * DELETE /api/admin/gallery/{id}
     */
    @PreAuthorize("hasRole('CREATOR')")
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteGalleryItem(@PathVariable Long id) {
        try {
            Long userId = Long.parseLong(securityContextHelper.getCurrentUserId());
            galleryAdminService.deleteGalleryItem(id, userId);
            return ResponseEntity.noContent().build();
        } catch (NumberFormatException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid user authentication");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
        // Let ResponseStatusException propagate for 403/404
    }
}
