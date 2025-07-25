.PHONY: install uninstall backup

# Run full bootstrap: check tools, stow, GNOME setup
install:
	@echo "==> Running dotfiles bootstrap..."
	bash ~/dotfiles/bootstrap.sh

# Unstow all dotfile packages except 'gnome'
uninstall:
	@echo "==> Unstowing all dotfiles..."
	cd ~/dotfiles && \
	for pkg in */ ; do \
		pkg=$${pkg%/}; \
		if [ "$$pkg" != "gnome" ] && [ -d "$$pkg" ]; then \
			echo "Unstowing $$pkg..."; \
			stow -D "$$pkg"; \
		fi; \
	done
	@echo "==> Done!"

# Backup GNOME dconf and extensions list
backup:
	@echo "==> Backing up GNOME settings..."
	dconf dump / > ~/dotfiles/gnome/dconf-settings.ini
	gnome-extensions list > ~/dotfiles/gnome/extensions-list.txt
	@echo "==> GNOME settings and extensions list updated!"

# Pull latest dotfiles and re-run bootstrap
update:
	@echo "==> Updating dotfiles from Git..."
	cd ~/dotfiles && git pull
	@echo "==> Running bootstrap after update..."
	bash ~/dotfiles/bootstrap.sh
	@echo "==> Dotfiles updated and re-applied!"
