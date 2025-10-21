# NoteGen AUR Package Maintenance Repository

This is the automated maintenance repository for the [NoteGen](https://github.com/codexu/note-gen) Arch Linux AUR package.

## 🔧 Automated Features

- ✅ **Version Monitoring**: Automatically checks for new upstream releases hourly
- ✅ **Auto Build**: Builds and tests when new versions are detected
- ✅ **PKGBUILD Updates**: Automatically updates version numbers and checksums
- ✅ **AUR Deployment**: Automatically commits updates to AUR repository
- ✅ **Error Notifications**: Provides detailed error information when builds fail

## 📦 Installation

Install from AUR (recommended):

```bash
paru -S note-gen
# or
yay -S note-gen
```

## 🚀 Automated Workflows

### 1. Version Monitoring (`check-upstream.yml`)
- Checks GitHub Releases hourly
- Compares current version with latest version
- Triggers build process when updates are found

### 2. Auto Update (`update-aur.yml`)
- Updates PKGBUILD version number
- Downloads source and generates checksums
- Builds package for validation
- Generates new .SRCINFO
- Commits changes to repository

### 3. AUR Deployment (`deploy-aur.yml`)
- Triggered when PKGBUILD or .SRCINFO changes
- Validates package build
- Automatically deploys to AUR repository

## 🛠️ Manual Maintenance

### Local Build Testing

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/note-gen-aur.git
cd note-gen-aur

# Download source
makepkg -f

# Install
sudo pacman -U note-gen-*.pkg.tar.zst
```

### Manual Version Update

```bash
# Update version number
sed -i 's/^pkgver=.*/pkgver=NEW_VERSION/' PKGBUILD
sed -i 's/^pkgrel=.*/pkgrel=1/' PKGBUILD

# Generate checksums
makepkg -g

# Update checksums in PKGBUILD
makepkg --geninteg

# Generate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# Commit changes
git add PKGBUILD .SRCINFO
git commit -m "Update to NEW_VERSION"
git push
```

## 🔑 Configuration Requirements

### GitHub Secrets

To enable full automation, configure the following Secrets in your repository settings:

- `AUR_SSH_KEY`: SSH private key for AUR repository

### AUR Setup

1. Create AUR SSH key pair:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/aur_key
   ```

2. Add public key to AUR:
   - Copy `aur_key.pub` content to AUR account's SSH key settings

3. Add private key to GitHub Secrets:
   - Copy `aur_key` content as `AUR_SSH_KEY` Secret

## 🆘 Troubleshooting

### Build Failures

1. Check if dependencies are complete
2. Verify Rust toolchain version
3. Check Node.js and pnpm versions
4. Review detailed errors in build logs

### AUR Submission Failures

1. Verify SSH key configuration
2. Check for AUR package name conflicts
3. Ensure PKGBUILD syntax is correct
4. Validate .SRCINFO format

### Version Detection Issues

1. Check upstream GitHub API accessibility
2. Verify version number format parsing
3. Manually check version number comparison logic

## 📋 Maintenance Checklist

Regularly check the following:

- [ ] Automation workflows are running normally
- [ ] No user complaints about AUR package
- [ ] Build dependencies are up to date
- [ ] Security vulnerability scanning
- [ ] Version monitoring is timely and accurate

## 🤝 Contributing

Found issues or improvement suggestions? Welcome to submit Issues or Pull Requests!

### Emergency Handling

If automation fails:

1. Manually execute update process
2. Check GitHub Actions logs
3. Reply to user feedback on AUR page
4. Manually rollback to stable version if necessary

## 📄 License

This maintenance repository follows the MIT License. The NoteGen software itself is bound by its original license.