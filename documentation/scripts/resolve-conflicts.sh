#!/bin/bash

# Merge Conflict Resolution Helper Script
# This script helps automate the process of resolving merge conflicts
# with the upstream Azure REST API Specs repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ${1}${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from your azure-rest-api-specs directory."
    exit 1
fi

print_header "Azure REST API Specs - Merge Conflict Resolver"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
print_info "Current branch: ${CURRENT_BRANCH}"

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    print_error "You are on the main branch. Please switch to your feature branch first."
    exit 1
fi

# Check if upstream is configured
if ! git remote | grep -q "^upstream$"; then
    print_warning "Upstream remote not configured."
    read -p "Would you like to add https://github.com/Azure/azure-rest-api-specs.git as upstream? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote add upstream https://github.com/Azure/azure-rest-api-specs.git
        print_success "Upstream remote added successfully"
    else
        print_error "Cannot proceed without upstream remote."
        exit 1
    fi
fi

# Fetch upstream changes
print_info "Fetching latest changes from upstream..."
git fetch upstream

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning "You have uncommitted changes."
    read -p "Would you like to stash them? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash push -m "Auto-stash before conflict resolution $(date)"
        print_success "Changes stashed successfully"
        STASHED=true
    else
        print_error "Please commit or stash your changes before proceeding."
        exit 1
    fi
fi

# Ask user which method to use
print_header "Choose Resolution Method"
echo "1. Rebase (recommended - cleaner history)"
echo "2. Merge (preserves all history)"
echo ""
read -p "Enter your choice (1 or 2): " -n 1 -r
echo

if [[ $REPLY = "1" ]]; then
    METHOD="rebase"
    print_info "Using rebase method..."
    
    # Perform rebase
    if git rebase upstream/main; then
        print_success "Rebase completed successfully with no conflicts!"
    else
        print_warning "Conflicts detected during rebase."
        print_header "Conflict Resolution Required"
        
        # List conflicted files
        CONFLICTED_FILES=$(git diff --name-only --diff-filter=U)
        
        if [ -z "$CONFLICTED_FILES" ]; then
            print_success "No conflicted files found."
        else
            echo "Conflicted files:"
            echo "$CONFLICTED_FILES" | while read file; do
                echo -e "  ${RED}✗${NC} $file"
            done
            echo ""
            
            print_info "To resolve conflicts:"
            echo "  1. Open each file and resolve conflicts manually"
            echo "  2. Remove conflict markers (<<<<<<<, =======, >>>>>>>)"
            echo "  3. Stage resolved files: git add <file>"
            echo "  4. Continue rebase: git rebase --continue"
            echo ""
            echo "Or abort rebase: git rebase --abort"
            echo ""
            
            read -p "Open conflicts in default editor? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if command -v code > /dev/null; then
                    echo "$CONFLICTED_FILES" | xargs code
                elif command -v vim > /dev/null; then
                    echo "$CONFLICTED_FILES" | xargs vim
                else
                    echo "$CONFLICTED_FILES" | xargs ${EDITOR:-nano}
                fi
            fi
            
            exit 0
        fi
    fi
    
elif [[ $REPLY = "2" ]]; then
    METHOD="merge"
    print_info "Using merge method..."
    
    # Perform merge
    if git merge upstream/main; then
        print_success "Merge completed successfully with no conflicts!"
    else
        print_warning "Conflicts detected during merge."
        print_header "Conflict Resolution Required"
        
        # List conflicted files
        CONFLICTED_FILES=$(git diff --name-only --diff-filter=U)
        
        if [ -z "$CONFLICTED_FILES" ]; then
            print_success "No conflicted files found."
        else
            echo "Conflicted files:"
            echo "$CONFLICTED_FILES" | while read file; do
                echo -e "  ${RED}✗${NC} $file"
            done
            echo ""
            
            print_info "To resolve conflicts:"
            echo "  1. Open each file and resolve conflicts manually"
            echo "  2. Remove conflict markers (<<<<<<<, =======, >>>>>>>)"
            echo "  3. Stage resolved files: git add <file>"
            echo "  4. Complete merge: git commit"
            echo ""
            echo "Or abort merge: git merge --abort"
            echo ""
            
            read -p "Open conflicts in default editor? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if command -v code > /dev/null; then
                    echo "$CONFLICTED_FILES" | xargs code
                elif command -v vim > /dev/null; then
                    echo "$CONFLICTED_FILES" | xargs vim
                else
                    echo "$CONFLICTED_FILES" | xargs ${EDITOR:-nano}
                fi
            fi
            
            exit 0
        fi
    fi
else
    print_error "Invalid choice. Exiting."
    exit 1
fi

# If we got here, there were no conflicts
print_header "Next Steps"

if [ "$METHOD" = "rebase" ]; then
    print_info "Your branch has been rebased successfully!"
    echo ""
    echo "To push your changes:"
    echo "  git push origin $CURRENT_BRANCH --force-with-lease"
    echo ""
    print_warning "Note: --force-with-lease is required after rebasing"
else
    print_info "Your branch has been merged successfully!"
    echo ""
    echo "To push your changes:"
    echo "  git push origin $CURRENT_BRANCH"
fi

# Restore stashed changes if any
if [ "$STASHED" = true ]; then
    echo ""
    print_info "Restoring stashed changes..."
    if git stash pop; then
        print_success "Stashed changes restored successfully"
    else
        print_warning "Conflicts when restoring stash. Please resolve manually."
    fi
fi

echo ""
print_success "Conflict resolution process complete!"
echo ""
print_info "Don't forget to:"
echo "  1. Verify all changes are correct"
echo "  2. Run tests if applicable"
echo "  3. Push your changes to your fork"
echo "  4. Update your Pull Request"
echo ""
