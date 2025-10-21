#!/bin/bash

# AUR部署脚本
# 需要预先配置AUR SSH密钥

set -e

AUR_PACKAGE_NAME="note-gen"
AUR_REMOTE="aur@aur.archlinux.org:${AUR_PACKAGE_NAME}.git"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要文件
check_files() {
    log_info "检查必要文件..."

    if [ ! -f "PKGBUILD" ]; then
        log_error "PKGBUILD 文件不存在"
        exit 1
    fi

    if [ ! -f ".SRCINFO" ]; then
        log_error ".SRCINFO 文件不存在"
        exit 1
    fi
}

# 验证包构建
validate_package() {
    log_info "验证包构建..."

    if ! makepkg -f --noconfirm; then
        log_error "包构建失败"
        exit 1
    fi

    log_info "✅ 包构建验证成功"
}

# 克隆AUR仓库
clone_aur_repo() {
    log_info "克隆AUR仓库..."

    if [ -d "$AUR_PACKAGE_NAME" ]; then
        rm -rf "$AUR_PACKAGE_NAME"
    fi

    git clone "$AUR_REMOTE" "$AUR_PACKAGE_NAME"
    if [ $? -ne 0 ]; then
        log_error "克隆AUR仓库失败"
        exit 1
    fi

    log_info "✅ AUR仓库克隆成功"
}

# 同步文件到AUR仓库
sync_files() {
    log_info "同步文件到AUR仓库..."

    # 复制必要文件
    cp PKGBUILD "$AUR_PACKAGE_NAME/"
    cp .SRCINFO "$AUR_PACKAGE_NAME/"

    # 检查是否有其他需要复制的文件
    for file in *.install *.patch; do
        if [ -f "$file" ]; then
            cp "$file" "$AUR_PACKAGE_NAME/"
            log_info "复制 $file"
        fi
    done
}

# 提交到AUR
commit_to_aur() {
    log_info "提交到AUR..."

    cd "$AUR_PACKAGE_NAME"

    # 配置Git用户信息
    git config user.name "AUR Maintainer Bot"
    git config user.email "aur-bot@example.com"

    # 检查是否有变更
    if git diff --quiet && git diff --cached --quiet; then
        log_warn "没有变更需要提交"
        cd ..
        return 0
    fi

    # 添加文件
    git add PKGBUILD .SRCINFO *.install *.patch 2>/dev/null || true

    # 获取版本信息
    VERSION=$(grep '^pkgver=' PKGBUILD | cut -d'=' -f2)
    PKGREL=$(grep '^pkgrel=' PKGBUILD | cut -d'=' -f2)

    # 提交变更
    git commit -m "Update to $VERSION-$PKGREL"

    # 推送到AUR
    git push

    cd ..

    log_info "✅ 成功提交到AUR"
}

# 主函数
main() {
    log_info "开始部署到AUR..."

    check_files
    validate_package
    clone_aur_repo
    sync_files
    commit_to_aur

    log_info "🎉 AUR部署完成"
}

# 执行主函数
main "$@"