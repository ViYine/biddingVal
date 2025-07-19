#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Git推送安全检查工具${NC}"
echo "=================================="

# 检查.gitignore文件是否存在
echo -e "${YELLOW}📋 检查.gitignore文件...${NC}"
if [ -f ".gitignore" ]; then
    echo -e "${GREEN}✅ .gitignore文件存在${NC}"
else
    echo -e "${RED}❌ .gitignore文件不存在！${NC}"
    echo "请创建.gitignore文件以排除敏感文件"
    exit 1
fi

# 检查敏感文件是否被正确排除
echo -e "${YELLOW}🔍 检查敏感文件...${NC}"
sensitive_files=(
    "password.json"
    ".env"
    "*.db"
    "venv/"
    "node_modules/"
    "__pycache__/"
)

all_safe=true
for file in "${sensitive_files[@]}"; do
    if git ls-files | grep -q "$file"; then
        echo -e "${RED}❌ 发现敏感文件: $file${NC}"
        all_safe=false
    else
        echo -e "${GREEN}✅ 安全: $file${NC}"
    fi
done

# 检查是否有硬编码的敏感信息
echo -e "${YELLOW}🔍 检查硬编码敏感信息...${NC}"
sensitive_patterns=(
    "password.*=.*['\"][^'\"]*['\"]"
    "token.*=.*['\"][^'\"]*['\"]"
    "secret.*=.*['\"][^'\"]*['\"]"
    "api_key.*=.*['\"][^'\"]*['\"]"
    "private_key.*=.*['\"][^'\"]*['\"]"
)

# 排除一些目录
exclude_dirs="--exclude-dir=node_modules --exclude-dir=venv --exclude-dir=__pycache__ --exclude-dir=.git"

for pattern in "${sensitive_patterns[@]}"; do
    matches=$(grep -r "$pattern" . $exclude_dirs 2>/dev/null | grep -v ".gitignore" | grep -v "check_git_security.sh" || true)
    if [ -n "$matches" ]; then
        echo -e "${RED}❌ 发现硬编码敏感信息:${NC}"
        echo "$matches"
        all_safe=false
    fi
done

# 检查环境变量示例文件
echo -e "${YELLOW}📝 检查环境变量配置...${NC}"
if [ -f "env.example" ]; then
    echo -e "${GREEN}✅ env.example文件存在${NC}"
else
    echo -e "${YELLOW}⚠️  env.example文件不存在，建议创建${NC}"
fi

# 检查是否有.env文件被跟踪
if git ls-files | grep -q "\.env$"; then
    echo -e "${RED}❌ .env文件被Git跟踪！${NC}"
    all_safe=false
else
    echo -e "${GREEN}✅ .env文件未被跟踪${NC}"
fi

# 检查文件大小
echo -e "${YELLOW}📏 检查大文件...${NC}"
large_files=$(find . -type f -size +10M -not -path "./node_modules/*" -not -path "./venv/*" -not -path "./.git/*" 2>/dev/null || true)
if [ -n "$large_files" ]; then
    echo -e "${YELLOW}⚠️  发现大文件（>10MB）:${NC}"
    echo "$large_files"
    echo "建议检查这些文件是否需要提交"
fi

# 最终检查结果
echo ""
echo -e "${BLUE}🔍 安全检查结果...${NC}"
if [ "$all_safe" = true ]; then
    echo -e "${GREEN}🎉 安全检查通过！可以安全推送到Git${NC}"
    echo ""
    echo -e "${BLUE}📋 建议的推送命令:${NC}"
    echo "git add ."
    echo "git commit -m 'feat: 股票数据可视化系统'"
    echo "git push origin main"
else
    echo -e "${RED}❌ 安全检查失败！请修复上述问题后再推送${NC}"
    echo ""
    echo -e "${YELLOW}💡 修复建议:${NC}"
    echo "1. 确保所有敏感文件都在.gitignore中"
    echo "2. 移除硬编码的敏感信息，使用环境变量"
    echo "3. 检查是否有大文件需要排除"
    exit 1
fi

echo ""
echo -e "${BLUE}📚 安全最佳实践:${NC}"
echo "• 使用环境变量存储敏感信息"
echo "• 定期更新API Token"
echo "• 不要在代码中硬编码密码"
echo "• 使用.env.example作为环境变量模板"
echo "• 定期检查.gitignore配置" 