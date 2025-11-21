# Design Reference: Mobile App Settings Page

## Overview
This document captures the design patterns, styling approach, and component structure from the reference Mobile App Settings Page design.

## Key Design Patterns

### 1. Layout Structure
- **Max Width**: 430px (mobile-optimized)
- **Padding**: Consistent 4px (16px) horizontal padding
- **Sections**: Grouped into logical sections (Account, Preferences, Support)
- **Section Headers**: Gray text labels above each section group
- **Spacing**: 5px (20px) margin between sections

### 2. Color Scheme (Light Mode)
- **Background**: `#ffffff` (white)
- **Page Background**: `#f3f3f5` (light gray)
- **Primary Text**: `#030213` (dark/black)
- **Secondary Text**: `#717182` (gray)
- **Borders**: `rgba(0, 0, 0, 0.1)` (subtle gray)
- **Accent**: `#e9ebef` (very light gray)
- **Destructive**: `#d4183d` (red for logout)

### 3. Color Scheme (Dark Mode)
- **Background**: `oklch(0.145 0 0)` (dark)
- **Text**: `oklch(0.985 0 0)` (light)
- **Destructive**: `oklch(0.396 0.141 25.723)` (adjusted red)

### 4. Border Radius
- **Primary Radius**: `0.625rem` (10px)
- **Rounded Containers**: `rounded-3xl` (24px) for cards and buttons
- **Subtle Radius**: `rounded-md` for smaller elements

### 5. Typography
- **Font Size**: 16px base
- **Headings (h1)**: Medium weight, 1.5 line height
- **Body Text**: Normal weight, 1.5 line height
- **Font Weights**: 400 (normal), 500 (medium)

### 6. Component Patterns

#### Profile Card
- Rounded container with padding (5px = 20px)
- Circular avatar (size-14 = 56px)
- Name and email stacked vertically
- Chevron icon on right for navigation
- Shadow: `shadow-sm`

#### Settings Item (Navigation)
- Flex layout with icon, label, optional value, and chevron
- Padding: `py-3.5 px-4` (14px vertical, 16px horizontal)
- Hover state: `hover:bg-gray-50`
- Active state: `active:bg-gray-100`
- Smooth transitions: `transition-colors`

#### Settings Toggle Item
- Similar layout to Settings Item
- Switch component on right instead of chevron
- Same padding and spacing

#### Section Container
- White background
- Rounded corners (`rounded-3xl`)
- Shadow (`shadow-sm`)
- Overflow hidden (for separator lines)
- Items separated by `<Separator />`

#### Buttons
- Full width: `w-full`
- Height: `h-14` (56px)
- Rounded: `rounded-3xl`
- Gap between icon and text: `gap-2`
- Destructive variant for logout

### 7. Icon Usage
- **Icon Library**: Lucide React
- **Icon Size**: `size-5` (20px) for most icons
- **Icon Color**: `text-gray-700` for primary, `text-gray-400` for secondary
- **Icons Used**:
  - Bell (notifications)
  - Mail (email)
  - Moon (dark mode)
  - Globe (language)
  - Lock (privacy)
  - Shield (security)
  - User (profile)
  - DollarSign (currency)
  - HelpCircle (help)
  - LogOut (logout)
  - ChevronRight (navigation)

### 8. Spacing System
- **Horizontal Padding**: 4px (16px) for page, 4px (16px) for items
- **Vertical Padding**: 3.5 (14px) for items, 5 (20px) for cards
- **Gap Between Elements**: 3 (12px) for flex items
- **Section Margin**: 5 (20px) between sections

### 9. Interactive States
- **Hover**: `hover:bg-gray-50` (subtle background change)
- **Active**: `active:bg-gray-100` (slightly darker)
- **Transitions**: `transition-colors` for smooth state changes
- **Switch**: Custom switch component with toggle animation

### 10. Responsive Design
- **Max Width**: 430px (mobile-first)
- **Centered**: `mx-auto` for centering
- **Full Width**: Items use `w-full` for full container width
- **Flex Layout**: Used throughout for responsive alignment

## Component Structure

### Main Sections
1. **Status Bar**: Time display (9:41)
2. **Header**: "Settings" title
3. **Profile Section**: User avatar, name, email
4. **Account Settings**: Edit Profile, Currency, Privacy & Security, Account Security
5. **Preferences**: Push Notifications, Email Notifications, Dark Mode, Language
6. **Support**: Help & Support, Terms & Privacy Policy
7. **Logout Button**: Prominent red button with icon
8. **Version Footer**: App version display

### Reusable Components
- `SettingsItem`: Navigation items with icon, label, optional value, and chevron
- `SettingsToggleItem`: Toggle items with icon, label, and switch
- `Avatar`: User profile picture with fallback
- `Switch`: Toggle switch for boolean preferences
- `Separator`: Divider between items
- `Button`: Action button with variants

## Implementation Notes for Flutter

### Equivalent Flutter Patterns
1. **Rounded Containers**: Use `BorderRadius.circular(24)` for `rounded-3xl`
2. **Shadows**: Use `BoxShadow` with subtle blur for `shadow-sm`
3. **Hover/Active States**: Use `GestureDetector` with state management
4. **Icons**: Use `flutter_svg` or `flutter_icons` packages
5. **Separators**: Use `Divider` widget
6. **Switches**: Use Flutter's built-in `Switch` widget
7. **Avatars**: Use `CircleAvatar` with `backgroundImage`
8. **Spacing**: Use `SizedBox` and `Padding` widgets
9. **Colors**: Define in a theme file for consistency
10. **Typography**: Use `TextStyle` with consistent font sizes and weights

### Color Mapping for Flutter
```dart
const lightColors = {
  'background': Color(0xFFFFFFFF),
  'pageBackground': Color(0xFFF3F3F5),
  'primary': Color(0xFF030213),
  'secondary': Color(0xFF717182),
  'border': Color.fromARGB(26, 0, 0, 0),
  'accent': Color(0xFFE9EBEF),
  'destructive': Color(0xFFD4183D),
};
```

### Spacing Constants for Flutter
```dart
const spacing = {
  'xs': 4.0,
  'sm': 8.0,
  'md': 12.0,
  'lg': 16.0,
  'xl': 20.0,
  'xxl': 24.0,
};

const borderRadius = {
  'sm': 8.0,
  'md': 10.0,
  'lg': 24.0,
};
```

## Key Takeaways

1. **Minimalist Design**: Clean, simple interface with plenty of whitespace
2. **Consistent Spacing**: Uniform padding and margins throughout
3. **Clear Hierarchy**: Section headers and grouped items create visual structure
4. **Interactive Feedback**: Hover and active states provide user feedback
5. **Accessibility**: Large touch targets (56px buttons), clear labels
6. **Dark Mode Support**: Full dark mode theme with adjusted colors
7. **Mobile-First**: Optimized for mobile with max-width constraint
8. **Component Reusability**: Consistent patterns for settings items and toggles
9. **Icon Usage**: Lucide icons for clear visual communication
10. **Rounded Aesthetics**: Generous border radius creates modern, friendly feel

