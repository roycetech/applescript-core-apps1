# Makefile.app1.mk
# @Created: Fri, Jul 19, 2024 at 1:14:29 PM
# Contains targets for first-party app wrappers (see $(APP_WRAPPERS)).

APP_WRAPPERS := app-wrappers

# @NOTE:
#   Versions of scripts indicate the app and OS version when the script was created.
#   New functionalities were only added to the latest version of the script at the time.
#
# @Change Logs:
# - 2026-03-29: Simplified by using the common build-app-scripts function.
# - 2026-02-20: Added echo statements to the build targets to make the output more readable.

build-all: \
	build \
	build-extras \
	build-apps-first-party


build-apps-first-party: \
	build-automator \
	build-calendar \
	build-console \
	build-finder \
	build-image-capture \
	build-passwords \
	build-preview \
	install-safari \
	build-system-settings \
	build-terminal


# 1st Party Apps Library ------------------------------------------------------

build-activity-monitor:
	@echo "Building Activity Monitor scripts..."
	$(call _build-script, $(APP_WRAPPERS)/Activity Monitor/10.14/activity-monitor)
	@echo "Build Activity Monitor completed\n"

install-activity-monitor: build-activity-monitor
	mkdir -p /Applications/AppleScript
	# cp -n plist.template ~/applescript-core/config-system.plist || true
	osascript scripts/setup-apps-applescript-path.applescript
	

build-automator:
	@echo "Building Automator scripts..."
	$(call _build-script, $(APP_WRAPPERS)/Automator/2.10/dec-automator-applescript)
	$(call _build-script, $(APP_WRAPPERS)/Automator/2.10/automator)

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_SEQUOIA) ] && echo yes),yes)
	@echo "\nBuilding Automator 2.10-Tahoe scripts..."
	$(call _build-script, $(APP_WRAPPERS)/Automator/2.10-Tahoe/automator)
endif
	@echo "Build Automator completed\n"

install-automator: build-automator
	mkdir -p /Applications/AppleScript
	# cp -n plist.template ~/applescript-core/config-system.plist || true
	osascript scripts/setup-apps-applescript-path.applescript

uninstall-automator:
	@echo "TODO"


build-calendar: build-base-app build-process
	@echo "Building Calendar scripts..."
	$(call _build-script, $(APP_WRAPPERS)/Calendar/11.0/dec-calendar-view)
	$(call _build-script, $(APP_WRAPPERS)/Calendar/15.0/calendar-event)
	$(call _build-script, $(APP_WRAPPERS)/Calendar/15.0/dec-calendar-meetings)
	$(call _build-script, $(APP_WRAPPERS)/Calendar/15.0/calendar)
	@echo "Build Calendar completed\n"

install-calendar: build-calendar
	osascript ./scripts/enter-user-country.applescript


build-console:
	$(call _build-app-scripts,Console 1.1,$(APP_WRAPPERS)/Console/v1.1)


build-finder:
ifeq ($(shell [ $(OS_VERSION_MAJOR) -lt $(OS_MONTEREY) ] && echo yes),yes)
	@echo "Untested macOS version for Finder. Development started at least on macOS Monterey (v12)."
endif
	$(call _build-script,$(APP_WRAPPERS)/Finder/12.5/finder)

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_MONTEREY) ] && echo yes),yes)
	$(call _build-app-version-scripts,Finder 15.2,$(APP_WRAPPERS)/Finder/15.2)
endif

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_SEQUOIA) ] && echo yes),yes)
	$(call _build-script,$(APP_WRAPPERS)/Finder/26.0/dec-finder-view)
	$(call _build-script,$(APP_WRAPPERS)/Finder/26.1/dec-finder-dialog)
	$(call _build-script,$(APP_WRAPPERS)/Finder/26.1/finder)
endif
	@echo "Build Finder completed\n"


build-home:
	$(call _build-app-scripts,Home 7.0,$(APP_WRAPPERS)/Home/7.0)


build-image-capture:
	$(call _build-app-scripts,Image Capture 26.3,$(APP_WRAPPERS)/Image Capture/26.3)


build-mail:
	$(call _build-app-scripts,Mail 16.0,$(APP_WRAPPERS)/Mail/16.0)


build-passwords:
	$(call _build-app-scripts,Passwords 2.0,$(APP_WRAPPERS)/Passwords/2.0)


build-preview:
	@echo "Building Preview scripts..."
	$(call _build-script,core/decorators/dec-preview-markup)
	$(call _build-script,$(APP_WRAPPERS)/Preview/v11/preview)

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_SEQUOIA) ] && echo yes),yes)
	$(call _build-script,$(APP_WRAPPERS)/Preview/v11-Tahoe/preview)
endif
	@echo "Build Preview completed\n"


VERSION_SAFARI_MAJOR_MINOR = $(shell osascript -e "tell application \"Safari\" to version" | awk -F. '{print $$1 "." $$2}')
$(debug     VERSION_SAFARI_MAJOR_MINOR: $(VERSION_SAFARI_MAJOR_MINOR))

# dir — build when VERSION_SAFARI_MAJOR_MINOR >= dir (subfolders of Safari/, excluding 16.0)
SAFARI_VERSION_BUILDS := $(filter-out 16.0,$(patsubst $(APP_WRAPPERS)/Safari/%/,%,$(wildcard $(APP_WRAPPERS)/Safari/*/)))

build-safari: build-base-app
	# Older versions of scripts are built first and overwritten by newer versions.
	@echo "Building Safari 16.0 scripts"
	$(call _build-script,core/Level_5/javascript)
	$(call _build-script,$(APP_WRAPPERS)/Safari/16.0/safari-tab)

	@for file in $(wildcard $(APP_WRAPPERS)/Safari/16.0/*.applescript); do \
		no_ext=$${file%.applescript}; \
		echo "Building $$file"; \
		yes y | ./scripts/build-lib.sh "$$no_ext"; \
	done

	@for dir in $(SAFARI_VERSION_BUILDS); do \
		dir_mm=$$(echo "$$dir" | awk -F. '{print $$1 "." $$2}'); \
		if echo "$(VERSION_SAFARI_MAJOR_MINOR) $$dir_mm" | awk '{exit !($$1 >= $$2)}'; then \
			echo "\nBuilding Safari $$dir scripts..."; \
			for file in "$(APP_WRAPPERS)/Safari/$$dir"/*.applescript; do \
				[ -e "$$file" ] || continue; \
				no_ext=$${file%.applescript}; \
				echo "Building $$file"; \
				yes y | ./scripts/build-lib.sh "$$no_ext"; \
			done; \
		fi; \
	done
	osascript "$(APP_WRAPPERS)/Safari/26.1/allow-javascript-from-apple-events.applescript"
	@echo "Build Safari completed\n"

install-safari: build-safari
	osascript ./scripts/allow-apple-events-in-safari.applescript
	plutil -replace 'FIND_RETRY_MAX' -integer 90 ~/applescript-core/config-system.plist
	plutil -replace 'FIND_RETRY_SLEEP' -integer 1 ~/applescript-core/config-system.plist


build-safari-technology-preview:  # Broken
	@echo "Building Safari Technology Preview scripts..."
	$(call _build-script,$(APP_WRAPPERS)/Safari Technology Preview/r168/dec-safari-technology-preview-javascript)
	$(call _build-script,$(APP_WRAPPERS)/Safari Technology Preview/r168/safari-technology-preview)
	@echo "Build Safari Technology Preview completed\n"

install-safari-technology-preview: build-safari-technology-preview
	osascript ./scripts/allow-apple-events-in-safari-technology-preview.applescript


build-script-editor:
	$(call _build-app-scripts-if-exists,Script Editor,$(APP_WRAPPERS)/Script Editor/2.11)

# OS_VERSION_MAJOR = $(OS_TAHOE) # Debugging only.
# $(info     DEBUG: OS_VERSION_MAJOR: $(OS_VERSION_MAJOR))

build-system-settings:
	@echo "Building System Settings scripts..."
ifeq ($(shell [ $(OS_VERSION_MAJOR) -lt $(OS_MONTEREY) ] && echo yes),yes)
	@echo "WARNING:Untested macOS version for system settings. Development started at least on macOS Monterey (v12)."
endif
	./scripts/factory-remove.sh SystemSettingsInstance core/dec-system-settings-sonoma
	$(call _build-app-version-scripts,System Settings 15.0,$(APP_WRAPPERS)/System Settings/15.0)

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_VENTURA) ] && echo yes),yes)
	$(call _build-app-version-scripts,System Settings 15.0 macOS Sonoma,$(APP_WRAPPERS)/System Settings/15.0/macOS Sonoma)
	./scripts/factory-insert.sh SystemSettingsInstance core/dec-system-settings-sonoma
endif

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_SONOMA) ] && echo yes),yes)
	$(call _build-app-version-scripts,System Settings 15.0 macOS Sequoia,$(APP_WRAPPERS)/System Settings/15.0/macOS Sequoia)
endif

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_SEQUOIA) ] && echo yes),yes)
	$(call _build-app-version-scripts,System Settings 26.3,$(APP_WRAPPERS)/System Settings/26.3)
endif

	@echo "Build System Settings completed"


build-terminal:
	@echo "Building Terminal scripts..."
ifeq ($(shell [ $(OS_VERSION_MAJOR) -lt $(OS_MONTEREY) ] && echo yes),yes)
	@echo "Untested macOS version for terminal. Development started at least on macOS Monterey (v12)."
endif

	$(call _build-app-version-scripts,Terminal 2.12.x,$(APP_WRAPPERS)/Terminal/2.12.x)

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_MONTEREY) ] && echo yes),yes)
	$(call _build-app-version-scripts,Terminal 2.13.x,$(APP_WRAPPERS)/Terminal/2.13.x)
endif

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_VENTURA) ] && echo yes),yes)
	# For Sonoma and Sequoia
	$(call _build-app-version-scripts,Terminal 2.14.x,$(APP_WRAPPERS)/Terminal/2.14.x)
endif

ifeq ($(shell [ $(OS_VERSION_MAJOR) -gt $(OS_SEQUOIA) ] && echo yes),yes)
	$(call _build-app-version-scripts,Terminal 2.15.0,$(APP_WRAPPERS)/Terminal/2.15)
endif
	$(call _build-script,libs/sftp/dec-terminal-prompt-sftp)
	@echo "Build Terminal completed\n"


build-xcode:
	$(call _build-app-scripts-if-exists,Xcode,apps/3rd-party/Xcode/15.4)


# This is a helper function to build scripts for a specific app version.
# @1 - App name with version number for display purposes
# @2 - folder to build the scripts from
_build-app-version-scripts = \
	@echo "\nBuilding $(1) scripts..."; \
	find "$(2)" -maxdepth 1 -type f -name '*.applescript' -print0 \
	| while IFS= read -r -d '' file; do \
		echo "Building $$file"; \
		no_ext=$${file%.applescript}; \
		yes y | ./scripts/build-lib.sh "$$no_ext"; \
	done;
