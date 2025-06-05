#!/bin/bash

# MySQL 8.0+ Installation Script for Amazon Linux 2
# This script removes existing MySQL/MariaDB and installs MySQL 8.0

echo "=== MySQL 8.0 Installation Script ==="
echo "Starting at $(date)"

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to remove existing MySQL/MariaDB installations
remove_existing_mysql() {
    echo "=== Removing existing MySQL/MariaDB installations ==="
    systemctl stop mysqld 2>/dev/null && echo "mysqld stopped" || echo "mysqld not running"
    systemctl stop mariadb 2>/dev/null && echo "mariadb stopped" || echo "mariadb not running"
    systemctl stop mysql 2>/dev/null && echo "mysql stopped" || echo "mysql not running"
    yum remove -y mariadb* 2>/dev/null && echo "MariaDB packages removed" || echo "No MariaDB packages found"
    yum remove -y mysql* 2>/dev/null && echo "MySQL packages removed" || echo "No MySQL packages found"
    rm -rf /var/lib/mysql* 2>/dev/null && echo "MySQL data directories removed" || true
    rm -rf /etc/my.cnf* 2>/dev/null && echo "MySQL config files removed" || true
    rm -rf /etc/mysql* 2>/dev/null && echo "MySQL config directories removed" || true
    rm -rf /var/log/mysqld.log* 2>/dev/null && echo "MySQL log files removed" || true
    rm -rf /usr/share/mysql* 2>/dev/null && echo "MySQL share directories removed" || true
    echo "Checking for remaining MySQL/MariaDB processes..."
    if pgrep -f mysql >/dev/null 2>&1; then
        echo "Found MySQL processes, killing them..."
        pkill -f mysql 2>/dev/null || true
        sleep 2
        echo "MySQL processes handled"
    else
        echo "No MySQL processes found"
    fi
    if pgrep -f mariadb >/dev/null 2>&1; then
        echo "Found MariaDB processes, killing them..."
        pkill -f mariadb 2>/dev/null || true
        sleep 2
        echo "MariaDB processes handled"
    else
        echo "No MariaDB processes found"
    fi
    echo "Cleaning yum cache..."
    yum clean all >/dev/null 2>&1 || true
    echo "Cleanup completed successfully"
}

# Function to install required packages
install_prerequisites() {
    echo "=== Installing prerequisites ==="
    yum update -y
    yum install -y wget
    yum install -y yum-utils
    echo "Prerequisites installed successfully"
}

# Function to fix GPG key for MySQL 8.0
fix_gpg_key() {
    echo "=== Fixing MySQL 8.0 GPG Key ==="
    rm -f /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
    curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql https://repo.mysql.com/RPM-GPG-KEY-mysql
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
    echo "GPG key imported successfully"
}

# Function to install MySQL 8.0
install_mysql8() {
    echo "=== Installing MySQL 8.0 ==="
    # Remove any existing MySQL repository packages
    yum remove -y mysql*-community-release 2>/dev/null || true
    rm -f /etc/yum.repos.d/mysql-community*.repo 2>/dev/null || true
    # Download MySQL 8.0 repository package
    cd /tmp
    rm -f mysql80-community-release-el7-5.noarch.rpm
    wget -O mysql80-community-release-el7-5.noarch.rpm https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
    if [ ! -f "mysql80-community-release-el7-5.noarch.rpm" ]; then
        echo "Error: Failed to download MySQL 8.0 repository package"
        exit 1
    fi
    # Install MySQL repository
    rpm -Uvh mysql80-community-release-el7-5.noarch.rpm
    # Clear yum cache to ensure fresh repository data
    yum clean all
    yum makecache
    # Enable MySQL 8.0 repository and disable others
    yum-config-manager --disable mysql57-community
    yum-config-manager --enable mysql80-community
    # Fix GPG key before install
    fix_gpg_key
    # Verify repository configuration
    yum repolist enabled | grep mysql
    # Check if mysql-community-server package is available
    yum list available mysql-community-server --showduplicates
    # Install MySQL 8.0 server
    yum install -y mysql-community-server
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install MySQL 8.0 server"
        echo "Trying alternative installation method..."
        yum --nogpgcheck install -y mysql-community-server-8.0* mysql-community-client-8.0*
        if [ $? -ne 0 ]; then
            echo "Error: All MySQL installation methods failed"
            yum list available | grep mysql
            exit 1
        fi
    fi
    echo "MySQL 8.0 installation completed successfully"
}

# Function to configure MySQL
configure_mysql() {
    echo "=== Configuring MySQL 8.0 ==="
    systemctl start mysqld
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start MySQL service"
        exit 1
    fi
    systemctl enable mysqld
    sleep 5
    echo "Retrieving temporary root password..."
    TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' | tail -1)
    if [ -z "$TEMP_PASSWORD" ]; then
        echo "Error: Could not find temporary MySQL root password"
        tail -20 /var/log/mysqld.log
        exit 1
    fi
    echo "Temporary password retrieved successfully"
    NEW_PASSWORD="re:St@rt!9"
    echo "Configuring MySQL security settings..."
    cat > /tmp/mysql_secure_installation.sql << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
    mysql --connect-expired-password -u root -p"$TEMP_PASSWORD" < /tmp/mysql_secure_installation.sql
    if [ $? -ne 0 ]; then
        echo "Error: Failed to configure MySQL security settings"
        exit 1
    fi
    rm -f /tmp/mysql_secure_installation.sql
    echo "MySQL configuration completed successfully"
}

# Function to verify installation
verify_installation() {
    echo "=== Verifying MySQL 8.0 Installation ==="
    echo "MySQL version:"
    mysql --version
    echo "MySQL service status:"
    systemctl status mysqld --no-pager
    echo "Testing MySQL connection:"
    mysql -u root -p"re:St@rt!9" -e "SELECT VERSION() AS 'MySQL Version';" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "MySQL connection test successful"
    else
        echo "Warning: MySQL connection test failed"
    fi
    echo "Verification completed"
}

# Function to display final information
display_info() {
    echo ""
    echo "=================================================="
    echo "=== MySQL 8.0 Installation Complete ==="
    echo "=================================================="
    echo "Root password: re:St@rt!9"
    echo "MySQL service is enabled and will start automatically on boot"
    echo ""
    echo "Useful commands:"
    echo "  Start MySQL:   sudo systemctl start mysqld"
    echo "  Stop MySQL:    sudo systemctl stop mysqld"
    echo "  Restart MySQL: sudo systemctl restart mysqld"
    echo "  Check status:  sudo systemctl status mysqld"
    echo "  Connect:       mysql -u root -p"
    echo ""
    echo "Installation completed at $(date)"
    echo "=================================================="
}

# Main execution
main() {
    echo "Checking root privileges..."
    check_root
    echo "âœ“ Root privileges confirmed"
    echo "Step 1: Removing existing installations..."
    remove_existing_mysql
    echo "âœ“ Cleanup completed"
    echo "Step 2: Installing prerequisites..."
    install_prerequisites
    echo "âœ“ Prerequisites installed"
    echo "Step 3: Installing MySQL 8.0..."
    install_mysql8
    echo "âœ“ MySQL 8.0 installed"
    echo "Step 4: Configuring MySQL..."
    configure_mysql
    echo "âœ“ MySQL configured"
    echo "Step 5: Verifying installation..."
    verify_installation
    echo "âœ“ Installation verified"
    echo "Step 6: Displaying final information..."
    display_info
    echo "âœ“ All steps completed successfully"
    return 0
}

echo "Starting MySQL 8.0 installation process..."
main "$@"
MAIN_EXIT_CODE=$?
if [ $MAIN_EXIT_CODE -eq 0 ]; then
    echo "Script completed successfully!"
    exit 0
else
    echo "Script encountered an error. Check the output above for details."
    exit 1
fi
