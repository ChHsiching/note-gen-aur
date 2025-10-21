#!/bin/bash

# AUR 包设置检查脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查必需文件
check_files() {
    log_step "检查必需文件..."

    local required_files=("PKGBUILD" ".SRCINFO" "README.md" "SETUP.md")
    local missing_files=()

    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            log_info "✅ $file"
        else
            log_error "❌ $file"
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -ne 0 ]; then
        log_error "缺少必需文件: ${missing_files[*]}"
        return 1
    fi
}

# 检查脚本权限
check_scripts() {
    log_step "检查脚本权限..."

    local scripts=("scripts/deploy-to-aur.sh" "scripts/check-setup.sh")

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                log_info "✅ $script (可执行)"
            else
                log_warn "⚠️ $script (不可执行)"
                chmod +x "$script"
                log_info "已设置执行权限"
            fi
        else
            log_error "❌ $script"
        fi
    done
}

# 检查 GitHub Actions 工作流
check_workflows() {
    log_step "检查 GitHub Actions 工作流..."

    local workflows=("check-upstream.yml" "update-aur.yml" "deploy-aur.yml")

    for workflow in "${workflows[@]}"; do
        if [ -f ".github/workflows/$workflow" ]; then
            log_info "✅ .github/workflows/$workflow"
        else
            log_error "❌ .github/workflows/$workflow"
        fi
    done
}

# 检查 PKGBUILD 语法
check_pkgbuild() {
    log_step "检查 PKGBUILD 语法..."

    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck PKGBUILD; then
            log_info "✅ PKGBUILD 语法检查通过"
        else
            log_warn "⚠️ PKGBUILD 可能有语法问题"
        fi
    else
        log_warn "⚠️ 未安装 shellcheck，跳过语法检查"
    fi
}

# 检查版本信息
check_version() {
    log_step "检查版本信息..."

    if [ -f "PKGBUILD" ]; then
        local pkgver=$(grep '^pkgver=' PKGBUILD | cut -d'=' -f2)
        local pkgrel=$(grep '^pkgrel=' PKGBUILD | cut -d'=' -f2)
        log_info "当前版本: $pkgver-$pkgrel"

        # 检查上游版本
        if command -v curl >/dev/null 2>&1; then
            local latest_version=$(curl -s https://api.github.com/repos/codexu/note-gen/releases/latest | \
              grep '"tag_name"' | cut -d'"' -f4 | sed 's/note-gen-v//' 2>/dev/null)
            if [ -n "$latest_version" ]; then
                log_info "上游版本: $latest_version"
                if [ "$latest_version" = "$pkgver" ]; then
                    log_info "✅ 版本是最新的"
                else
                    log_warn "⚠️ 有新版本可用: $latest_version"
                fi
            else
                log_warn "⚠️ 无法获取上游版本信息"
            fi
        fi
    fi
}

# 检查 .SRCINFO
check_srcinfo() {
    log_step "检查 .SRCINFO..."

    if [ -f ".SRCINFO" ]; then
        local pkgver=$(grep '^pkgver = ' .SRCINFO | head -1 | cut -d'=' -f2 | xargs)
        local srcinfo_pkgver=$(grep '^pkgver=' PKGBUILD | cut -d'=' -f2)

        if [ "$pkgver" = "$srcinfo_pkgver" ]; then
            log_info "✅ .SRCINFO 与 PKGBUILD 版本一致"
        else
            log_warn "⚠️ .SRCINFO 版本 ($pkgver) 与 PKGBUILD 版本 ($srcinfo_pkgver) 不一致"
        fi
    fi
}

# 检查 Git 仓库状态
check_git() {
    log_step "检查 Git 仓库状态..."

    if [ -d ".git" ]; then
        log_info "✅ Git 仓库已初始化"

        # 检查是否有未提交的变更
        if [ -n "$(git status --porcelain)" ]; then
            log_warn "⚠️ 有未提交的变更"
            git status --short
        else
            log_info "✅ 没有未提交的变更"
        fi
    else
        log_error "❌ Git 仓库未初始化"
    fi
}

# 检查构建依赖
check_build_deps() {
    log_step "检查构建依赖..."

    local deps=("rust" "cargo" "nodejs" "npm" "pnpm")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            local version=$("$dep" --version 2>/dev/null || echo "unknown")
            log_info "✅ $dep ($version)"
        else
            log_warn "⚠️ $dep (未安装)"
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_warn "缺少构建依赖: ${missing_deps[*]}"
        log_info "运行: sudo pacman -S ${missing_deps[*]}"
    fi
}

# 主函数
main() {
    log_info "开始 AUR 包设置检查..."
    echo

    check_files
    check_scripts
    check_workflows
    check_pkgbuild
    check_version
    check_srcinfo
    check_git
    check_build_deps

    echo
    log_info "检查完成！"
    log_info "请查看 README.md 和 SETUP.md 获取详细的设置说明。"
}

# 执行主函数
main "$@"