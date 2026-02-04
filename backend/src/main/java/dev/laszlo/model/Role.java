package dev.laszlo.model;

/**
 * User roles for role-based access control.
 *
 * USER: Regular users who can play stories, manage saves
 * CREATOR: Content creators who can create/edit/delete stories (Laszlo + Partner only)
 */
public enum Role {
    USER,     // Default role for new registrations
    CREATOR   // Manually assigned for content creators
}