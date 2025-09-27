# 🎯 Mooja Mobile - Codebase Refactor Plan

## **Main Goal: Perfect 3-Dev Team Architecture**

Transform the current codebase into a clean, maintainable structure that's perfect for a 3-person development team.

### **Target Architecture:**

```
lib/
├── core/                           # ✅ Keep as is (already perfect)
│   ├── constants/
│   ├── di/
│   ├── domain/
│   ├── initialization/
│   ├── models/
│   ├── navigation/
│   ├── router/
│   ├── services/
│   ├── state/
│   ├── themes/
│   └── widgets/
├── features/
│   ├── auth/                      # ✅ Keep only actual auth (login/signup)
│   │   ├── bloc/
│   │   ├── login_page.dart
│   │   └── signup_page.dart
│   ├── intro/                     # ✅ Keep as is (shared)
│   │   ├── intro_page.dart
│   │   └── widgets/
│   ├── organization/              # 🎯 NEW: Organization-specific features
│   │   ├── verification/          # Moved from features/auth/
│   │   │   ├── pages/
│   │   │   ├── widgets/
│   │   │   └── bloc/
│   │   └── dashboard/             # Moved from features/home/
│   │       └── pages/
│   └── protestor/                 # 🎯 NEW: Protestor-specific features
│       └── feed/                  # Moved from features/home/
│           ├── pages/
│           ├── widgets/
│           └── bloc/
└── main.dart
```

### **Benefits After Refactor:**
- ✅ Clear user type separation (org vs protestor)
- ✅ Maximum 3-level imports (no more 4-level hell)
- ✅ Predictable file locations for new devs
- ✅ Easy maintenance and feature addition
- ✅ Professional structure ready for team growth

---

## **📋 REFACTOR TASKS**

### **Phase 1: Preparation & Setup**
- [x] **Task 1.1**: Create new folder structure (organization/ and protestor/ directories)
- [ ] **Task 1.2**: Backup current state and verify git status
- [ ] **Task 1.3**: Document current file locations for reference

### **Phase 2: Organization Verification Flow**
- [ ] **Task 2.1**: Move organization verification pages from auth/ to organization/verification/pages/
- [ ] **Task 2.2**: Move organization verification widgets from auth/ to organization/verification/widgets/
- [ ] **Task 2.3**: Move organization verification bloc/cubit from auth/ to organization/verification/bloc/
- [ ] **Task 2.4**: Update all imports in organization verification files
- [ ] **Task 2.5**: Test organization verification flow works

### **Phase 3: Organization Dashboard**
- [ ] **Task 3.1**: Move organization dashboard from home/ to organization/dashboard/pages/
- [ ] **Task 3.2**: Update all imports in organization dashboard files
- [ ] **Task 3.3**: Test organization dashboard works

### **Phase 4: Protestor Feed**
- [ ] **Task 4.1**: Move protestor feed pages from home/ to protestor/feed/pages/
- [ ] **Task 4.2**: Move protestor feed widgets from home/ to protestor/feed/widgets/
- [ ] **Task 4.3**: Move protestor feed bloc from home/ to protestor/feed/bloc/
- [ ] **Task 4.4**: Update all imports in protestor feed files
- [ ] **Task 4.5**: Test protestor feed works

### **Phase 5: Cleanup & Verification**
- [ ] **Task 5.1**: Remove empty directories from old structure
- [ ] **Task 5.2**: Update router configuration if needed
- [ ] **Task 5.3**: Run flutter analyze and fix any remaining issues
- [ ] **Task 5.4**: Test complete app functionality
- [ ] **Task 5.5**: Update documentation and README

---

## **📊 Current Structure (Before Refactor):**

```
lib/
├── core/                    # ✅ Perfect as is
├── features/
│   ├── auth/               # ❌ Contains org verification (should be in organization/)
│   │   ├── bloc/
│   │   ├── code_verification_page.dart
│   │   ├── country_selection_page.dart
│   │   ├── login_page.dart
│   │   ├── org_registration_page.dart
│   │   ├── organization_name_page.dart
│   │   ├── signup_page.dart
│   │   ├── social_media_selection_page.dart
│   │   ├── social_username_page.dart
│   │   ├── status_lookup_page.dart
│   │   ├── timeline_cubit.dart
│   │   ├── verification_cubit.dart
│   │   └── verification_timeline_page.dart
│   ├── home/               # ❌ Contains both org and protestor feeds
│   │   ├── bloc/
│   │   ├── organization_feed_page.dart
│   │   ├── protestor_feed_page.dart
│   │   └── widgets/
│   ├── intro/              # ✅ Perfect as is
│   └── placeholder/        # ✅ Perfect as is
└── main.dart
```

---

## **🔄 Workflow Rules**

1. **Pick one task** from the list above
2. **Read the current implementation and codebase** to make sure I don't lose context
3. **Complete the task** fully while following @cursorrules
4. **Check it off** the TODO list
5. **Read remaining tasks** and analyze what's next
6. **Report back** with: "I did task X, checked it off, read remaining tasks, and now we should pick task Y because [reason]. Should I proceed?"
7. **Wait for confirmation** before proceeding to next task
8. **Follow YAGNI principles**
9. **Follow DRY principles**
10. **When checking for errors in a task ignore the ones that are related to tasks that have not yet been implemented**
11. **Before starting a task make an assessment whether it is best to do it all at once or to do it one sub task at a time**

---

## **🎯 Success Criteria**

- [ ] All files moved to logical locations
- [ ] Maximum import depth is 3 levels (no 4-level imports)
- [ ] Clear separation between organization and protestor features
- [ ] All features work exactly as before (no functionality changes)
- [ ] New developers can easily understand where to put new code
- [ ] Codebase follows consistent patterns and conventions

---

**Status: Ready to begin refactor** 🚀
