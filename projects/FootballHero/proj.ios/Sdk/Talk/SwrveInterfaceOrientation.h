/**
 * Supported orientations for Swrve Talk.
 */
typedef enum {
    /// App supports landscape only.
    SWRVE_ORIENTATION_LANDSCAPE = 0x1,
    
    /// App supports portrait only.
    SWRVE_ORIENTATION_PORTRAIT  = 0x2,
    
    /// App supports both landscape and portrait.
    SWRVE_ORIENTATION_BOTH      = 0x3
} SwrveInterfaceOrientation;